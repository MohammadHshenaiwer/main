package com.university.swap.service;

import com.university.swap.dto.SendSwapRequest;
import com.university.swap.enums.OfferStatus;
import com.university.swap.enums.RequestStatus;
import com.university.swap.exception.ResourceNotFoundException;
import com.university.swap.exception.SwapException;
import com.university.swap.model.*;
import com.university.swap.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SwapRequestService {

    private final SwapRequestRepository requestRepo;
    private final SwapOfferRepository offerRepo;
    private final StudentRepository studentRepo;
    private final SectionRepository sectionRepo;
    private final EnrollmentRepository enrollmentRepo;

    // ── Accept a direct trade instantly (from the board) ───────
    @Transactional
    public void acceptDirectTrade(com.university.swap.dto.DirectAcceptRequest dto) {
        SwapOffer offer = offerRepo.findById(dto.getOfferId())
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found: " + dto.getOfferId()));

        if (offer.getStatus() != OfferStatus.OPEN)
            throw new SwapException("This offer is no longer open.");

        // Rule: accepter must match the targetStudent if it's not null
        if (offer.getTargetStudent() != null && !offer.getTargetStudent().getStudentId().equals(dto.getAccepterStudentId())) {
            throw new SwapException("This offer is directed to a specific student.");
        }

        // Rule: accepter must have the exact target section the offer wanted
        if (!offer.getWantSection().getSectionId().equals(dto.getOfferedSectionId())) {
            throw new SwapException("You are not offering the exact section this student wants.");
        }

        Student accepter = studentRepo.findById(dto.getAccepterStudentId())
                .orElseThrow(() -> new ResourceNotFoundException("Accepter not found: " + dto.getAccepterStudentId()));

        Section offeredSection = sectionRepo.findById(dto.getOfferedSectionId())
                .orElseThrow(() -> new ResourceNotFoundException("Section not found: " + dto.getOfferedSectionId()));

        // Create an accepted SwapRequest record so the trade history exists
        SwapRequest request = new SwapRequest();
        request.setOffer(offer);
        request.setSender(accepter);
        request.setReceiver(offer.getStudent());
        request.setSenderSection(offeredSection);
        request.setStatus(RequestStatus.ACCEPTED);
        request.setResolvedAt(LocalDateTime.now());
        SwapRequest savedRequest = requestRepo.save(request);

        // ── EXECUTE THE SWAP ───────────────────────────────────
        Long receiverSectionId = offer.getHaveSection().getSectionId(); // what the offerer had
        Long senderSectionId   = dto.getOfferedSectionId(); // what the accepter is giving
        Long offererId         = offer.getStudent().getStudentId();
        Long accepterId        = dto.getAccepterStudentId();

        enrollmentRepo.findActiveByStudentAndSection(offererId, receiverSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: The offer owner is no longer enrolled in their section."));

        enrollmentRepo.findActiveByStudentAndSection(accepterId, senderSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: You are no longer enrolled in your section."));

        // Swap both enrollments atomically
        int u1 = enrollmentRepo.updateStudentSection(offererId, receiverSectionId, senderSectionId);
        int u2 = enrollmentRepo.updateStudentSection(accepterId, senderSectionId, receiverSectionId);

        if (u1 == 0 || u2 == 0)
            throw new SwapException("Swap failed: Could not update enrollments. Please try again.");

        // Update offer status
        offer.setStatus(OfferStatus.COMPLETED);
        offerRepo.save(offer);

        // Auto-reject any pending requests on this offer
        requestRepo.rejectOtherRequests(offer.getOfferId(), savedRequest.getRequestId());
    }

    // ── Send a direct request to a specific student ────────────
    // NEW LOGIC:
    //   Student B sees Student A's offer on the board
    //   Student B picks which of THEIR sections to offer
    //   Student B enters Student A's ID and sends
    @Transactional
    public SwapRequest sendRequest(SendSwapRequest dto) {

        // Load sender, receiver, offer, senderSection
        Student sender = studentRepo.findById(dto.getSenderId())
                .orElseThrow(() -> new ResourceNotFoundException("Sender not found: " + dto.getSenderId()));

        Student receiver = studentRepo.findById(dto.getReceiverId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Student with ID " + dto.getReceiverId() + " not found. Please check the ID."));

        SwapOffer offer = offerRepo.findById(dto.getOfferId())
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found: " + dto.getOfferId()));

        Section senderSection = sectionRepo.findById(dto.getSenderSectionId())
                .orElseThrow(() -> new ResourceNotFoundException("Section not found: " + dto.getSenderSectionId()));

        // Rule: cannot send to yourself
        if (dto.getSenderId().equals(dto.getReceiverId()))
            throw new SwapException("You cannot send a request to yourself.");

        // Rule: offer must be OPEN
        if (offer.getStatus() != OfferStatus.OPEN)
            throw new SwapException("This offer is no longer open.");

        // Rule: sender must actually own senderSection
        enrollmentRepo.findActiveByStudentAndSection(dto.getSenderId(), dto.getSenderSectionId())
                .orElseThrow(() -> new SwapException(
                        "You are not enrolled in the section you are trying to offer."));

        // Rule: no duplicate pending requests
        if (requestRepo.hasPendingRequest(dto.getOfferId(), dto.getSenderId()))
            throw new SwapException("You already have a pending request for this offer.");

        // Create request
        SwapRequest request = new SwapRequest();
        request.setOffer(offer);
        request.setSender(sender);
        request.setReceiver(receiver);
        request.setSenderSection(senderSection);
        request.setStatus(RequestStatus.PENDING);

        // Set offer to PENDING so no new requests come in
        offer.setStatus(OfferStatus.PENDING);
        offerRepo.save(offer);

        return requestRepo.save(request);
    }

    // ── Accept a request → executes the swap ───────────────────
    // This is the CRITICAL method — runs in one transaction
    // If anything fails, NOTHING changes in the database
    @Transactional
    public void acceptRequest(Long requestId, Long acceptingStudentId) {

        SwapRequest request = requestRepo.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Request not found: " + requestId));

        SwapOffer offer = request.getOffer();

        // Only the receiver (offer owner) can accept
        if (!request.getReceiver().getStudentId().equals(acceptingStudentId))
            throw new SwapException("You are not authorized to accept this request.");

        if (request.getStatus() != RequestStatus.PENDING)
            throw new SwapException("This request is no longer pending.");

        // ── EXECUTE THE SWAP ───────────────────────────────────
        Long receiverSectionId = offer.getHaveSection().getSectionId();
        Long senderSectionId   = request.getSenderSection().getSectionId();
        Long receiverId        = acceptingStudentId;
        Long senderId          = request.getSender().getStudentId();

        // Re-verify both are still enrolled (safety check right before swap)
        enrollmentRepo.findActiveByStudentAndSection(receiverId, receiverSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: You are no longer enrolled in your section."));

        enrollmentRepo.findActiveByStudentAndSection(senderId, senderSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: The other student is no longer enrolled in their section."));

        // Swap both enrollments atomically
        int u1 = enrollmentRepo.updateStudentSection(receiverId, receiverSectionId, senderSectionId);
        int u2 = enrollmentRepo.updateStudentSection(senderId,   senderSectionId,   receiverSectionId);

        if (u1 == 0 || u2 == 0)
            throw new SwapException("Swap failed: Could not update enrollments. Please try again.");

        // Update statuses
        request.setStatus(RequestStatus.ACCEPTED);
        request.setResolvedAt(LocalDateTime.now());
        offer.setStatus(OfferStatus.COMPLETED);

        requestRepo.save(request);
        offerRepo.save(offer);

        // Auto-reject all other pending requests on this offer
        requestRepo.rejectOtherRequests(offer.getOfferId(), requestId);
    }

    // ── Reject a request ───────────────────────────────────────
    @Transactional
    public void rejectRequest(Long requestId, Long studentId) {
        SwapRequest request = requestRepo.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Request not found: " + requestId));

        if (!request.getReceiver().getStudentId().equals(studentId))
            throw new SwapException("You are not authorized to reject this request.");

        if (request.getStatus() != RequestStatus.PENDING)
            throw new SwapException("This request is no longer pending.");

        request.setStatus(RequestStatus.REJECTED);
        request.setResolvedAt(LocalDateTime.now());
        requestRepo.save(request);

        // Re-open the offer
        request.getOffer().setStatus(OfferStatus.OPEN);
        offerRepo.save(request.getOffer());
    }

    // ── Cancel a request (by the sender) ──────────────────────
    @Transactional
    public void cancelRequest(Long requestId, Long studentId) {
        SwapRequest request = requestRepo.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Request not found: " + requestId));

        if (!request.getSender().getStudentId().equals(studentId))
            throw new SwapException("You can only cancel your own requests.");

        if (request.getStatus() != RequestStatus.PENDING)
            throw new SwapException("Only pending requests can be cancelled.");

        request.setStatus(RequestStatus.CANCELLED);
        request.setResolvedAt(LocalDateTime.now());
        requestRepo.save(request);

        // Re-open the offer
        request.getOffer().setStatus(OfferStatus.OPEN);
        offerRepo.save(request.getOffer());
    }

    // ── Get incoming requests ──────────────────────────────────
    public List<SwapRequest> getIncoming(Long studentId) {
        return requestRepo.findByReceiver_StudentIdOrderBySentAtDesc(studentId);
    }

    // ── Get sent requests ──────────────────────────────────────
    public List<SwapRequest> getSent(Long studentId) {
        return requestRepo.findBySender_StudentIdOrderBySentAtDesc(studentId);
    }
}
