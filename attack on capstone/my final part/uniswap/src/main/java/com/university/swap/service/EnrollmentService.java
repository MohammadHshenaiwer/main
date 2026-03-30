package com.university.swap.service;

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
public class EnrollmentService {

    private final EnrollmentRepository enrollmentRepo;
    private final StudentRepository studentRepo;
    private final SectionRepository sectionRepo;
    private final StudentCourseCompletionRepository completionRepo;
    private final CourseRepository courseRepo;
    private final SwapOfferRepository offerRepo;
    private final SwapRequestRepository requestRepo;

    // ── Add a section to student's schedule ────────────────────
    @Transactional
    public void addSection(Long studentId, Long sectionId) {

        Student student = studentRepo.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + studentId));

        Section section = sectionRepo.findById(sectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Section not found: " + sectionId));

        Course course = section.getCourse();

        // 1. Can't add if already enrolled in this exact section
        if (enrollmentRepo.findActiveByStudentAndSection(studentId, sectionId).isPresent()) {
            throw new SwapException("You are already enrolled in this section.");
        }

        // 2. Can't add if already enrolled in another section of the same course
        if (enrollmentRepo.isEnrolledInCourse(studentId, course.getCourseId())) {
            throw new SwapException("You are already enrolled in a section of " + course.getCourseName() + ".");
        }

        // 3. Can't add a course you already completed
        if (completionRepo.hasStudentPassedCourse(studentId, course.getCourseId())) {
            throw new SwapException("You already completed " + course.getCourseName() + ".");
        }

        // 4. Prerequisite check
        String prereqCode = course.getPrerequisiteCourseCode();
        if (prereqCode != null && !prereqCode.isBlank()) {
            if (!completionRepo.hasStudentPassedCourseByCode(studentId, prereqCode)) {
                String prereqName = courseRepo.findByCourseCode(prereqCode)
                        .map(Course::getCourseName)
                        .orElse(prereqCode);
                throw new SwapException("You haven't completed the prerequisite: " + prereqName);
            }
        }

        // 5. Time conflict check
        if (section.getDayOfWeek() != null && section.getStartTime() != null) {
            List<Enrollment> enrollments = enrollmentRepo.findAllActiveByStudent(studentId);
            for (Enrollment e : enrollments) {
                Section existing = e.getSection();
                if (existing.getDayOfWeek() == null || existing.getStartTime() == null) continue;

                if (daysOverlap(existing.getDayOfWeek(), section.getDayOfWeek()) &&
                    timesOverlap(existing.getStartTime(), existing.getEndTime(),
                                 section.getStartTime(), section.getEndTime())) {
                    throw new SwapException("Time conflict with " + existing.getCourse().getCourseName()
                            + " (" + existing.getSchedule() + ")");
                }
            }
        }

        // 6. Create enrollment
        Enrollment enrollment = new Enrollment();
        enrollment.setStudent(student);
        enrollment.setSection(section);
        enrollment.setStatus("ACTIVE");
        enrollmentRepo.save(enrollment);
    }

    // ── Remove a section from student's schedule ──────────────
    @Transactional
    public void removeSection(Long studentId, Long sectionId) {

        studentRepo.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + studentId));

        enrollmentRepo.findActiveByStudentAndSection(studentId, sectionId)
                .orElseThrow(() -> new SwapException("You are not enrolled in this section."));

        // Cascade: cancel any open offers where this student offered this section
        List<Long> offerIds = offerRepo.findAllOpenOfferIdsByStudentAndHaveSection(studentId, sectionId);
        if (!offerIds.isEmpty()) {
            requestRepo.cancelPendingRequestsForOffers(offerIds);
            offerRepo.cancelAllOpenOffersByStudentAndHaveSection(studentId, sectionId);
        }

        // Delete the enrollment
        int deleted = enrollmentRepo.deleteByStudentAndSection(studentId, sectionId);
        if (deleted == 0) {
            throw new SwapException("Failed to remove section. Please try again.");
        }
    }

    // ── Time conflict helpers ─────────────────────────────────
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
