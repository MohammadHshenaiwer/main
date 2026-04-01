package com.university.swap.service;

import com.university.swap.dto.CreateOfferRequest;
import com.university.swap.enums.OfferStatus;
import com.university.swap.enums.SwapType;
import com.university.swap.exception.ResourceNotFoundException;
import com.university.swap.exception.SwapException;
import com.university.swap.model.*;
import com.university.swap.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SwapOfferService {

    private final SwapOfferRepository offerRepo;
    private final StudentRepository studentRepo;
    private final EnrollmentRepository enrollmentRepo;
    private final SectionRepository sectionRepo;
    private final StudentCourseCompletionRepository completionRepo;
    private final CourseRepository courseRepo;

    // ── Get all open offers (Swap Board) ──────────────────────
    public List<SwapOffer> getAllOpenOffers(Long currentStudentId) {
        return offerRepo.findAllOpenExcludingStudent(currentStudentId);
    }

    // ── Get my own offers ──────────────────────────────────────
    public List<SwapOffer> getMyOffers(Long studentId) {
        return offerRepo.findByStudent_StudentIdOrderByCreatedAtDesc(studentId);
    }

    // ── Create a new offer ─────────────────────────────────────
    @Transactional
    public SwapOffer createOffer(CreateOfferRequest req) {

        // 1. Student must exist
        Student student = studentRepo.findById(req.getStudentId())
                .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + req.getStudentId()));

        // 2. Section must exist
        Section haveSection = sectionRepo.findById(req.getHaveSectionId())
                .orElseThrow(() -> new ResourceNotFoundException("Section not found: " + req.getHaveSectionId()));

        // 3. Student must actually be enrolled in that section
        enrollmentRepo.findActiveByStudentAndSection(req.getStudentId(), req.getHaveSectionId())
                .orElseThrow(() -> new SwapException(
                        "You are not enrolled in section " + haveSection.getSectionNumber()
                                + " of " + haveSection.getCourse().getCourseName()));

        // ── CASE 1: Cannot offer a course you already completed ──
        if (completionRepo.hasStudentPassedCourse(req.getStudentId(), haveSection.getCourse().getCourseId())) {
            throw new SwapException(
                    "❌ You already completed " + haveSection.getCourse().getCourseName() + ". You cannot offer it for swap.");
        }

        // 4. wantSection must exist
        if (req.getWantSectionId() == null)
            throw new SwapException("Please select what course/section you want to receive.");

        Section wantSection = sectionRepo.findById(req.getWantSectionId())
                .orElseThrow(
                        () -> new ResourceNotFoundException("Target Section not found: " + req.getWantSectionId()));

        // 4.1 Allow multiple offers from the same offered section, but block exact duplicate pairs
        if (offerRepo.hasActiveOfferForSamePair(req.getStudentId(), req.getHaveSectionId(), req.getWantSectionId())) {
            throw new SwapException(
                    "You already have an active offer with the same offered and wanted sections.");
        }

        // ── CASE 2: Cannot request a course you already completed ──
        if (completionRepo.hasStudentPassedCourse(req.getStudentId(), wantSection.getCourse().getCourseId())) {
            throw new SwapException(
                    "❌ You already completed " + wantSection.getCourse().getCourseName() + ". No need to swap for it.");
        }

        // ── CASE 3: Prerequisite check ──
        checkPrerequisite(req.getStudentId(), wantSection.getCourse());

        // ── CASE 4: Cannot swap for the same section you have ──
        if (req.getHaveSectionId().equals(req.getWantSectionId())) {
            throw new SwapException("❌ You cannot swap a section for itself.");
        }

        // ── CASE 5: For COURSE_SWAP — cannot request a course you're already enrolled in ──
        if (req.getSwapType() == SwapType.COURSE_SWAP) {
            if (enrollmentRepo.isEnrolledInCourse(req.getStudentId(), wantSection.getCourse().getCourseId())) {
                throw new SwapException(
                        "❌ You are already enrolled in " + wantSection.getCourse().getCourseName()
                                + ". You cannot swap for it.");
            }
        }

        // ── CASE 6: Time conflict check on offer creation ──
        checkTimeConflictForOffer(req.getStudentId(), wantSection, req.getHaveSectionId());

        // 5. Check if targeting a specific student
        Student targetStudent = null;
        if (req.getTargetStudentId() != null) {
            targetStudent = studentRepo.findById(req.getTargetStudentId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Target student not found: " + req.getTargetStudentId()));
        }

        // 6. Build and save
        SwapOffer offer = new SwapOffer();
        offer.setStudent(student);
        offer.setSwapType(req.getSwapType());
        offer.setHaveSection(haveSection);
        offer.setWantSection(wantSection);
        offer.setTargetStudent(targetStudent);
        offer.setStatus(OfferStatus.OPEN);

        return offerRepo.save(offer);
    }

    // ── Cancel an offer ────────────────────────────────────────
    @Transactional
    public void cancelOffer(Long offerId, Long studentId) {
        SwapOffer offer = offerRepo.findById(offerId)
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found: " + offerId));

        if (!offer.getStudent().getStudentId().equals(studentId))
            throw new SwapException("You can only cancel your own offers.");

        if (offer.getStatus() == OfferStatus.COMPLETED)
            throw new SwapException("Cannot cancel a completed swap.");

        offer.setStatus(OfferStatus.CANCELLED);
        offerRepo.save(offer);
    }

    // ══════════════════════════════════════════════════════════
    // PRIVATE HELPERS
    // ══════════════════════════════════════════════════════════

    /**
     * Check if the student has completed the prerequisite course for the given course.
     */
    public void checkPrerequisite(Long studentId, Course course) {
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

    /**
     * Check if the wanted section has a time conflict with the student's current schedule
     * (excluding the section they are giving up).
     */
    private void checkTimeConflictForOffer(Long studentId, Section wantSection, Long haveSectionId) {
        if (wantSection.getDayOfWeek() == null || wantSection.getStartTime() == null) return;

        List<Enrollment> enrollments = enrollmentRepo.findAllActiveByStudent(studentId);

        for (Enrollment e : enrollments) {
            Section existing = e.getSection();

            // Skip the section they're giving up (won't conflict after swap)
            if (existing.getSectionId().equals(haveSectionId)) continue;
            if (existing.getDayOfWeek() == null || existing.getStartTime() == null) continue;

            if (daysOverlap(existing.getDayOfWeek(), wantSection.getDayOfWeek()) &&
                timesOverlap(existing.getStartTime(), existing.getEndTime(),
                             wantSection.getStartTime(), wantSection.getEndTime())) {
                throw new SwapException(
                        "❌ Time conflict: " + wantSection.getCourse().getCourseName()
                                + " (" + wantSection.getSchedule() + ")"
                                + " clashes with " + existing.getCourse().getCourseName()
                                + " (" + existing.getSchedule() + ")");
            }
        }
    }

    private boolean daysOverlap(String days1, String days2) {
        for (String d : days1.split("/")) {
            if (days2.contains(d)) return true;
        }
        return false;
    }

    private boolean timesOverlap(java.time.LocalTime s1, java.time.LocalTime e1,
                                  java.time.LocalTime s2, java.time.LocalTime e2) {
        return s1.isBefore(e2) && s2.isBefore(e1);
    }
}
