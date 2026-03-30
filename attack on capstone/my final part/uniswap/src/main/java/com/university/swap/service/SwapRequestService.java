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
    private final CourseRepository courseRepo;

    // ── Accept a direct trade instantly (from the board) ───────
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

        Student accepter = studentRepo.findById(dto.getAccepterStudentId())
                .orElseThrow(() -> new ResourceNotFoundException("Accepter not found: " + dto.getAccepterStudentId()));

        Section offeredSection = sectionRepo.findById(dto.getOfferedSectionId())
                .orElseThrow(() -> new ResourceNotFoundException("Section not found: " + dto.getOfferedSectionId()));

        Long receiverSectionId = offer.getHaveSection().getSectionId();
        Long senderSectionId = dto.getOfferedSectionId();
        Long offererId = offer.getStudent().getStudentId();
        Long accepterId = dto.getAccepterStudentId();

        Long offererCourseId = offer.getHaveSection().getCourse().getCourseId();
        Long accepterCourseId = offeredSection.getCourse().getCourseId();

        // ── CASE 1: Cannot accept to GET a course already completed ──
        if (completionRepo.hasStudentPassedCourse(offererId, accepterCourseId)) {
            throw new SwapException(
                    "❌ You already completed " + offeredSection.getCourse().getCourseName()
                            + ". You cannot swap to get it again.");
        }
        if (completionRepo.hasStudentPassedCourse(accepterId, offererCourseId)) {
            throw new SwapException(
                    "❌ You already completed " + offer.getHaveSection().getCourse().getCourseName()
                            + ". You cannot swap to get it again.");
        }

        // ── CASE 2: Prerequisite check ──
        checkPrerequisite(offererId, offeredSection.getCourse());
        checkPrerequisite(accepterId, offer.getHaveSection().getCourse());

        // Verify both still enrolled
        enrollmentRepo.findActiveByStudentAndSection(offererId, receiverSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: The offer owner is no longer enrolled in their section."));
        enrollmentRepo.findActiveByStudentAndSection(accepterId, senderSectionId)
                .orElseThrow(() -> new SwapException("Swap failed: You are no longer enrolled in your section."));

        // ── CASE 3: Time conflict check ──
        checkTimeConflict(offererId, senderSectionId, receiverSectionId);
        checkTimeConflict(accepterId, receiverSectionId, senderSectionId);

        // Save request record
        SwapRequest request = new SwapRequest();
        request.setOffer(offer);
        request.setSender(accepter);
        request.setReceiver(offer.getStudent());
        request.setSenderSection(offeredSection);
        request.setStatus(RequestStatus.ACCEPTED);
        request.setResolvedAt(LocalDateTime.now());
        SwapRequest savedRequest = requestRepo.save(request);

        // Swap both enrollments atomically
        int u1 = enrollmentRepo.updateStudentSection(offererId, receiverSectionId, senderSectionId);
        int u2 = enrollmentRepo.updateStudentSection(accepterId, senderSectionId, receiverSectionId);

        if (u1 == 0 || u2 == 0)
            throw new SwapException("Swap failed: Could not update enrollments. Please try again.");

        offer.setStatus(OfferStatus.COMPLETED);
        offerRepo.save(offer);
        requestRepo.rejectOtherRequests(offer.getOfferId(), savedRequest.getRequestId());

        // ── CASCADE: Cancel stale offers/requests for the sections that were traded ──
        cascadeCancelOffersAndRequests(offererId, receiverSectionId, offer.getOfferId());
        cascadeCancelOffersAndRequests(accepterId, senderSectionId, offer.getOfferId());
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

        // Sender must be enrolled in the section they're offering
        enrollmentRepo.findActiveByStudentAndSection(dto.getSenderId(), dto.getSenderSectionId())
                .orElseThrow(() -> new SwapException("You are not enrolled in the section you are trying to offer."));

        // ── CASE 1: Sender cannot offer a course they already completed ──
        if (completionRepo.hasStudentPassedCourse(dto.getSenderId(), senderSection.getCourse().getCourseId())) {
            throw new SwapException(
                    "❌ You already completed " + senderSection.getCourse().getCourseName()
                            + ". You cannot offer it for swap.");
        }

        // ── CASE 1b: Sender cannot request a course they already completed ──
        Long wantedCourseId = offer.getHaveSection().getCourse().getCourseId();
        if (completionRepo.hasStudentPassedCourse(dto.getSenderId(), wantedCourseId)) {
            throw new SwapException(
                    "❌ You already completed " + offer.getHaveSection().getCourse().getCourseName()
                            + ". No need to swap for it.");
        }

        // ── CASE 2: Prerequisite check ──
        checkPrerequisite(dto.getSenderId(), offer.getHaveSection().getCourse());

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

        Long receiverCourseId = offer.getHaveSection().getCourse().getCourseId();
        Long senderCourseId = request.getSenderSection().getCourse().getCourseId();

        // ── CASE 1: Cannot accept to GET a course already completed ──
        if (completionRepo.hasStudentPassedCourse(receiverId, senderCourseId)) {
            throw new SwapException(
                    "❌ You already completed " + request.getSenderSection().getCourse().getCourseName()
                            + ". You cannot swap to get it again.");
        }
        if (completionRepo.hasStudentPassedCourse(senderId, receiverCourseId)) {
            throw new SwapException(
                    "❌ The other student already completed " + offer.getHaveSection().getCourse().getCourseName()
                            + ". Swap not allowed.");
        }

        // ── CASE 2: Prerequisite check ──
        checkPrerequisite(receiverId, request.getSenderSection().getCourse());
        checkPrerequisite(senderId, offer.getHaveSection().getCourse());

        // Verify both still enrolled
        enrollmentRepo.findActiveByStudentAndSection(receiverId, receiverSectionId)
                .orElseThrow(() -> new SwapException("Swap failed: You are no longer enrolled in your section."));
        enrollmentRepo.findActiveByStudentAndSection(senderId, senderSectionId)
                .orElseThrow(() -> new SwapException(
                        "Swap failed: The other student is no longer enrolled in their section."));

        // ── CASE 3: Time conflict check ──
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

        // ── CASCADE: Cancel stale offers/requests for the sections that were traded ──
        cascadeCancelOffersAndRequests(receiverId, receiverSectionId, offer.getOfferId());
        cascadeCancelOffersAndRequests(senderId, senderSectionId, offer.getOfferId());
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

    // ══════════════════════════════════════════════════════════
    // PRIVATE HELPERS
    // ══════════════════════════════════════════════════════════

    private void checkPrerequisite(Long studentId, Course course) {
        String prereqCode = course.getPrerequisiteCourseCode();
        if (prereqCode == null || prereqCode.isBlank()) return;

        if (!completionRepo.hasStudentPassedCourseByCode(studentId, prereqCode)) {
            String prereqName = courseRepo.findByCourseCode(prereqCode)
                    .map(Course::getCourseName)
                    .orElse(prereqCode);
            throw new SwapException(
                    "❌ You cannot swap for " + course.getCourseName()
                            + " because you haven't completed the prerequisite: " + prereqName);
        }
    }

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

    /**
     * After a swap completes, cancel all other open/pending offers where either student
     * offered the section they just gave away. Also cancel pending requests on those offers.
     */
    private void cascadeCancelOffersAndRequests(Long studentId, Long sectionId, Long excludeOfferId) {
        List<Long> offerIds = offerRepo.findOpenOfferIdsByStudentAndHaveSection(studentId, sectionId, excludeOfferId);

        if (!offerIds.isEmpty()) {
            // First cancel pending requests on those offers
            requestRepo.cancelPendingRequestsForOffers(offerIds);
            // Then cancel the offers themselves
            offerRepo.cancelOpenOffersByStudentAndHaveSection(studentId, sectionId, excludeOfferId);
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