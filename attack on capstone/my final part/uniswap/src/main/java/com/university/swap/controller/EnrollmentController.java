package com.university.swap.controller;

import com.university.swap.dto.ApiResponse;
import com.university.swap.model.Enrollment;
import com.university.swap.repository.EnrollmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// ================================================
// EnrollmentController.java
// Gives the frontend the list of sections a student
// is enrolled in — used to populate the dropdowns
// on Create Offer and Send Request pages.
// ================================================

@RestController
@RequestMapping("/api/enrollments")
@RequiredArgsConstructor
public class EnrollmentController {

    private final EnrollmentRepository enrollmentRepo;

    // GET /api/enrollments/my?studentId=1
    // Returns all active enrollments for the student
    // Frontend uses this to populate "What do you HAVE?" dropdown
    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<Enrollment>>> getMyEnrollments(@RequestParam Long studentId) {
        List<Enrollment> enrollments = enrollmentRepo.findAllActiveByStudent(studentId);
        return ResponseEntity.ok(ApiResponse.ok("Enrollments retrieved", enrollments));
    }
}
