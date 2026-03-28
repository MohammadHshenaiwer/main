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

        if (offer.getTargetStudent() != null
                && !offer.getTargetStudent().getStudentId().equals(dto.getAccepterStudentId()))
            throw new SwapException("This offer is directed to a specific student.");

        if (!offer.getWantSection().getSectionId().equals(dto.getOfferedSectionId()))
            throw new SwapException("You are not offering the exact section this student wants.");

        Student accepter = studentRepo.findById(dto.getAccepterStudentId())
                .orElseThrow(() -> new ResourceNotFoundException("Accepter not found: " + dto.getAccepterStudentId()));

        Section offeredSection = sectionRepo.findById(dto.getOfferedSectionId())
                .orElseThrow(() -> new ResourceNotFoundException("Section not found: " + dto.getOfferedSectionId()));

        SwapRequest request = new SwapRequest();
        request.setOffer(offer);
        request.setSender(accepter);
        request.setReceiver(offer.getStudent());
        request.setSenderSection(offeredSection);
        request.setStatus(RequestStatus.ACCEPTED);
        request.setResolvedAt(LocalDateTime.now());
        SwapRequest savedRequest = requestRepo.save(request);

        Long receiverSectionId = offer.getHaveSection().getSectionId();
        Long senderSectionId = dto.getOfferedSectionId();
        Long offererId = offer.getStudent().getStudentId();
        Long accepterId = dto.getAccepterStudentId();

        enrollmentRepo.findActiveByStudentAndSection(offererId, receiverSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: The offer owner is no longer enrolled in their section."));

        enrollmentRepo.findActiveByStudentAndSection(accepterId, senderSectionId)
                .orElseThrow(() -> new SwapException("Swap failed: You are no longer enrolled in your section."));

        // ── CHECK TIME CONFLICTS BEFORE SWAPPING ──────────────
        checkTimeConflict(offererId, senderSectionId, receiverSectionId);
        checkTimeConflict(accepterId, receiverSectionId, senderSectionId);

        // Swap both enrollments atomically
        int u1 = enrollmentRepo.updateStudentSection(offererId, receiverSectionId, senderSectionId);
        int u2 = enrollmentRepo.updateStudentSection(accepterId, senderSectionId, receiverSectionId);

        if (u1 == 0 || u2 == 0)
            throw new SwapException("Swap failed: Could not update enrollments. Please try again.");

        offer.setStatus(OfferStatus.COMPLETED);
        offerRepo.save(offer);

        requestRepo.rejectOtherRequests(offer.getOfferId(), savedRequest.getRequestId());
    }

    // ── Send a direct request to a specific student ────────────
    @Transactional
    public SwapRequest sendRequest(SendSwapRequest dto) {

        Student sender = studentRepo.findById(dto.getSenderId())
                .orElseThrow(() -> new ResourceNotFoundException("Sender not found: " + dto.getSenderId()));

        Student receiver = studentRepo.findById(dto.getReceiverId())
                .orElseThrow(
                        () -> new ResourceNotFoundException("Student with ID " + dto.getReceiverId() + " not found."));

        SwapOffer offer = offerRepo.findById(dto.getOfferId())
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found: " + dto.getOfferId()));

        Section senderSection = sectionRepo.findById(dto.getSenderSectionId())
                .orElseThrow(() -> new ResourceNotFoundException("Section not found: " + dto.getSenderSectionId()));

        if (dto.getSenderId().equals(dto.getReceiverId()))
            throw new SwapException("You cannot send a request to yourself.");

        if (offer.getStatus() != OfferStatus.OPEN)
            throw new SwapException("This offer is no longer open.");

        enrollmentRepo.findActiveByStudentAndSection(dto.getSenderId(), dto.getSenderSectionId())
                .orElseThrow(() -> new SwapException("You are not enrolled in the section you are trying to offer."));

        if (requestRepo.hasPendingRequest(dto.getOfferId(), dto.getSenderId()))
            throw new SwapException("You already have a pending request for this offer.");

        SwapRequest request = new SwapRequest();
        request.setOffer(offer);
        request.setSender(sender);
        request.setReceiver(receiver);
        request.setSenderSection(senderSection);
        request.setStatus(RequestStatus.PENDING);

        offer.setStatus(OfferStatus.PENDING);
        offerRepo.save(offer);

        return requestRepo.save(request);
    }

    // ── Accept a request → executes the swap ───────────────────
    @Transactional
    public void acceptRequest(Long requestId, Long acceptingStudentId) {

        SwapRequest request = requestRepo.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Request not found: " + requestId));

        SwapOffer offer = request.getOffer();

        if (!request.getReceiver().getStudentId().equals(acceptingStudentId))
            throw new SwapException("You are not authorized to accept this request.");

        if (request.getStatus() != RequestStatus.PENDING)
            throw new SwapException("This request is no longer pending.");

        Long receiverSectionId = offer.getHaveSection().getSectionId();
        Long senderSectionId = request.getSenderSection().getSectionId();
        Long receiverId = acceptingStudentId;
        Long senderId = request.getSender().getStudentId();

        enrollmentRepo.findActiveByStudentAndSection(receiverId, receiverSectionId)
                .orElseThrow(() -> new SwapException("Swap failed: You are no longer enrolled in your section."));

        enrollmentRepo.findActiveByStudentAndSection(senderId, senderSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: The other student is no longer enrolled in their section."));

        // ── CHECK TIME CONFLICTS BEFORE SWAPPING ──────────────
        checkTimeConflict(receiverId, senderSectionId, receiverSectionId);
        checkTimeConflict(senderId, receiverSectionId, senderSectionId);

        // Swap both enrollments atomically
        int u1 = enrollmentRepo.updateStudentSection(receiverId, receiverSectionId, senderSectionId);
        int u2 = enrollmentRepo.updateStudentSection(senderId, senderSectionId, receiverSectionId);

        if (u1 == 0 || u2 == 0)
            throw new SwapException("Swap failed: Could not update enrollments. Please try again.");

        request.setStatus(RequestStatus.ACCEPTED);
        request.setResolvedAt(LocalDateTime.now());
        offer.setStatus(OfferStatus.COMPLETED);

        requestRepo.save(request);
        offerRepo.save(offer);

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

    // ── TIME CONFLICT CHECKER ──────────────────────────────────
    // studentId = the student receiving the new section
    // incomingId = the section they will GET after the swap
    // swappingOutId = the section they are GIVING UP (excluded from check)
    private void checkTimeConflict(Long studentId, Long incomingId, Long swappingOutId) {
        Section incoming = sectionRepo.findById(incomingId)
                .orElseThrow(() -> new ResourceNotFoundException("Section not found: " + incomingId));

        if (incoming.getDayOfWeek() == null || incoming.getStartTime() == null)
            return;

        List<Enrollment> enrollments = enrollmentRepo.findAllActiveByStudent(studentId);

        for (Enrollment e : enrollments) {
            Section existing = e.getSection();

            // Skip the section being swapped out
            if (existing.getSectionId().equals(swappingOutId))
                continue;

            if (existing.getDayOfWeek() == null || existing.getStartTime() == null)
                continue;

            if (daysOverlap(existing.getDayOfWeek(), incoming.getDayOfWeek()) &&
                    timesOverlap(existing.getStartTime(), existing.getEndTime(),
                            incoming.getStartTime(), incoming.getEndTime())) {

                throw new SwapException(
                        "❌ Time conflict: " +
                                incoming.getCourse().getCourseName() + " (" + incoming.getSchedule() + ")" +
                                " clashes with " +
                                existing.getCourse().getCourseName() + " (" + existing.getSchedule() + ")");
            }
        }
    }

    private boolean daysOverlap(String days1, String days2) {
        for (String d : days1.split("/")) {
            if (days2.contains(d))
                return true;
        }
        return false;
    }

    private boolean timesOverlap(java.time.LocalTime s1, java.time.LocalTime e1,
            java.time.LocalTime s2, java.time.LocalTime e2) {
        return s1.isBefore(e2) && s2.isBefore(e1);
    }
}