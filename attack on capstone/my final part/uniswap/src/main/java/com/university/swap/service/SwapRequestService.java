package com.university.swap.service;

import com.university.swap.dto.DirectAcceptRequest;
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
    private final StudentCourseCompletionRepository completionRepo;
    private final SwapOfferService offerService; // reuse checkPrerequisite

    // ── Send a request ──────────────────────────────────────
    @Transactional
    public SwapRequest sendRequest(SendSwapRequest dto) {

        Student sender = studentRepo.findById(dto.getSenderId())
                .orElseThrow(() -> new ResourceNotFoundException("Sender not found: " + dto.getSenderId()));
        Student receiver = studentRepo.findById(dto.getReceiverId())
                .orElseThrow(() -> new ResourceNotFoundException("Receiver not found: " + dto.getReceiverId()));
        SwapOffer offer = offerRepo.findById(dto.getOfferId())
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found: " + dto.getOfferId()));
        Section senderSection = sectionRepo.findById(dto.getSenderSectionId())
                .orElseThrow(() -> new ResourceNotFoundException("Section not found: " + dto.getSenderSectionId()));

        // 1. Cannot send to yourself
        if (dto.getSenderId().equals(dto.getReceiverId()))
            throw new SwapException("You cannot send a swap request to yourself.");

        // 2. Offer must be open
        if (offer.getStatus() != OfferStatus.OPEN)
            throw new SwapException("This offer is no longer open.");

        // 3. Sender must own the section they are offering
        enrollmentRepo.findActiveByStudentAndSection(dto.getSenderId(), dto.getSenderSectionId())
                .orElseThrow(() -> new SwapException(
                        "You are not enrolled in the section you are trying to offer."));

        // 4. Duplicate request check
        if (requestRepo.hasPendingRequest(dto.getOfferId(), dto.getSenderId()))
            throw new SwapException(
                    "❌ Duplicate request: You already have a pending request for this offer.");

        // 5. Sender cannot offer a course they already completed
        if (completionRepo.hasStudentPassedCourse(dto.getSenderId(), senderSection.getCourse().getCourseId()))
            throw new SwapException(
                    "❌ Already completed: You already passed \""
                            + senderSection.getCourse().getCourseName()
                            + "\". You cannot offer a completed course.");

        // 6. Sender cannot request a course they already completed
        if (completionRepo.hasStudentPassedCourse(dto.getSenderId(), offer.getHaveSection().getCourse().getCourseId()))
            throw new SwapException(
                    "❌ Already completed: You already passed \""
                            + offer.getHaveSection().getCourse().getCourseName()
                            + "\". No need to swap for a course you already completed.");

        // 7. Prerequisite check: sender must qualify for the course they want to get
        offerService.checkPrerequisite(dto.getSenderId(), offer.getHaveSection().getCourse());

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

    // ── Accept a request ────────────────────────────────────
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

        // 1. Receiver cannot accept if they already completed the sender's course
        if (completionRepo.hasStudentPassedCourse(receiverId,
                request.getSenderSection().getCourse().getCourseId()))
            throw new SwapException(
                    "❌ Already completed: You already passed \""
                            + request.getSenderSection().getCourse().getCourseName()
                            + "\". Cannot accept this swap.");

        // 2. Sender cannot get the receiver's course if already completed
        if (completionRepo.hasStudentPassedCourse(senderId,
                offer.getHaveSection().getCourse().getCourseId()))
            throw new SwapException(
                    "❌ Already completed: The other student already passed \""
                            + offer.getHaveSection().getCourse().getCourseName()
                            + "\". Swap not allowed.");

        // 3. Prerequisite check for both directions
        offerService.checkPrerequisite(receiverId, request.getSenderSection().getCourse());
        offerService.checkPrerequisite(senderId, offer.getHaveSection().getCourse());

        // 4. Verify both still enrolled
        enrollmentRepo.findActiveByStudentAndSection(receiverId, receiverSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: You are no longer enrolled in your section."));
        enrollmentRepo.findActiveByStudentAndSection(senderId, senderSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: The other student is no longer enrolled in their section."));

        // 5. Time conflict checks
        checkTimeConflict(receiverId, senderSectionId, receiverSectionId);
        checkTimeConflict(senderId, receiverSectionId, senderSectionId);

        // 6. Execute swap
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

        // 7. Clean up stale offers/requests linked to traded-away sections
        cleanupTradeDependencies(receiverId, receiverSectionId, offer.getOfferId());
        cleanupTradeDependencies(senderId, senderSectionId, offer.getOfferId());
    }

    // ── Accept direct trade from board ──────────────────────
    @Transactional
    public void acceptDirectTrade(DirectAcceptRequest dto) {
        SwapOffer offer = offerRepo.findById(dto.getOfferId())
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found: " + dto.getOfferId()));

        if (offer.getStatus() != OfferStatus.OPEN)
            throw new SwapException("This offer is no longer open.");
        if (offer.getTargetStudent() != null
                && !offer.getTargetStudent().getStudentId().equals(dto.getAccepterStudentId()))
            throw new SwapException("This offer is directed to a specific student.");
        if (!offer.getWantSection().getSectionId().equals(dto.getOfferedSectionId()))
            throw new SwapException("You are not offering the exact section this student wants.");

        Long receiverSectionId = offer.getHaveSection().getSectionId();
        Long senderSectionId = dto.getOfferedSectionId();
        Long offererId = offer.getStudent().getStudentId();
        Long accepterId = dto.getAccepterStudentId();

        // Already completed checks
        if (completionRepo.hasStudentPassedCourse(offererId,
                offer.getWantSection().getCourse().getCourseId()))
            throw new SwapException(
                    "❌ Already completed: The offerer already passed \""
                            + offer.getWantSection().getCourse().getCourseName() + "\".");
        if (completionRepo.hasStudentPassedCourse(accepterId,
                offer.getHaveSection().getCourse().getCourseId()))
            throw new SwapException(
                    "❌ Already completed: You already passed \""
                            + offer.getHaveSection().getCourse().getCourseName() + "\".");

        // Prerequisite checks
        offerService.checkPrerequisite(offererId, offer.getWantSection().getCourse());
        offerService.checkPrerequisite(accepterId, offer.getHaveSection().getCourse());

        // Verify enrollments
        enrollmentRepo.findActiveByStudentAndSection(offererId, receiverSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: The offer owner is no longer enrolled in their section."));
        enrollmentRepo.findActiveByStudentAndSection(accepterId, senderSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: You are no longer enrolled in your section."));

        // Time conflict checks
        checkTimeConflict(offererId, senderSectionId, receiverSectionId);
        checkTimeConflict(accepterId, receiverSectionId, senderSectionId);

        // Save record & execute swap
        Student accepter = studentRepo.findById(accepterId)
                .orElseThrow(() -> new ResourceNotFoundException("Accepter not found"));
        Section offeredSection = sectionRepo.findById(senderSectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Section not found"));

        SwapRequest saved = new SwapRequest();
        saved.setOffer(offer);
        saved.setSender(accepter);
        saved.setReceiver(offer.getStudent());
        saved.setSenderSection(offeredSection);
        saved.setStatus(RequestStatus.ACCEPTED);
        saved.setResolvedAt(LocalDateTime.now());
        saved = requestRepo.save(saved);

        int u1 = enrollmentRepo.updateStudentSection(offererId, receiverSectionId, senderSectionId);
        int u2 = enrollmentRepo.updateStudentSection(accepterId, senderSectionId, receiverSectionId);
        if (u1 == 0 || u2 == 0)
            throw new SwapException("Swap failed: Could not update enrollments.");

        offer.setStatus(OfferStatus.COMPLETED);
        offerRepo.save(offer);
        requestRepo.rejectOtherRequests(offer.getOfferId(), saved.getRequestId());

        // Clean up stale offers/requests linked to traded-away sections
        cleanupTradeDependencies(offererId, receiverSectionId, offer.getOfferId());
        cleanupTradeDependencies(accepterId, senderSectionId, offer.getOfferId());
    }

    // ── Reject ──────────────────────────────────────────────
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

    // ── Cancel ──────────────────────────────────────────────
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

    // ── Get lists ───────────────────────────────────────────
    public List<SwapRequest> getIncoming(Long studentId) {
        return requestRepo.findByReceiver_StudentIdOrderBySentAtDesc(studentId);
    }

    public List<SwapRequest> getSent(Long studentId) {
        return requestRepo.findBySender_StudentIdOrderBySentAtDesc(studentId);
    }

    // ══════════════════════════════════════════════════════
    // PRIVATE HELPERS
    // ══════════════════════════════════════════════════════

    private void checkTimeConflict(Long studentId, Long incomingId, Long swappingOutId) {
        Section incoming = sectionRepo.findById(incomingId)
                .orElseThrow(() -> new ResourceNotFoundException("Section not found: " + incomingId));

        if (incoming.getDayOfWeek() == null || incoming.getStartTime() == null)
            return;

        List<Enrollment> enrollments = enrollmentRepo.findAllActiveByStudent(studentId);
        for (Enrollment e : enrollments) {
            Section existing = e.getSection();
            if (existing.getSectionId().equals(swappingOutId))
                continue;
            if (existing.getDayOfWeek() == null || existing.getStartTime() == null)
                continue;

            if (daysOverlap(existing.getDayOfWeek(), incoming.getDayOfWeek())
                    && timesOverlap(existing.getStartTime(), existing.getEndTime(),
                            incoming.getStartTime(), incoming.getEndTime())) {
                throw new SwapException(
                        "❌ Time conflict: \"" + incoming.getCourse().getCourseName()
                                + "\" (" + incoming.getSchedule() + ") conflicts with \""
                                + existing.getCourse().getCourseName()
                                + "\" (" + existing.getSchedule() + ").");
            }
        }
    }

    private boolean daysOverlap(String d1, String d2) {
        for (String d : d1.split("/"))
            if (d2.contains(d))
                return true;
        return false;
    }

    private boolean timesOverlap(java.time.LocalTime s1, java.time.LocalTime e1,
            java.time.LocalTime s2, java.time.LocalTime e2) {
        return s1.isBefore(e2) && s2.isBefore(e1);
    }

    private void cleanupTradeDependencies(Long studentId, Long tradedOutSectionId, Long keepOfferId) {
        // Cancel this student's other active offers that rely on the section they no longer own
        List<Long> staleOfferIds = offerRepo.findOpenOfferIdsByStudentAndHaveSection(studentId, tradedOutSectionId, keepOfferId);
        if (!staleOfferIds.isEmpty()) {
            requestRepo.cancelPendingRequestsForOffers(staleOfferIds);
            offerRepo.cancelOpenOffersByStudentAndHaveSection(studentId, tradedOutSectionId, keepOfferId);
        }

        // Cancel this student's pending requests where they offered a section they no longer own
        List<Long> impactedOfferIds = requestRepo.findPendingOfferIdsBySenderAndSection(studentId, tradedOutSectionId);
        if (!impactedOfferIds.isEmpty()) {
            requestRepo.cancelPendingRequestsBySenderAndSection(studentId, tradedOutSectionId);
            offerRepo.reopenPendingOffersByIds(impactedOfferIds);
        }
    }
}
