package com.university.swap.controller;

import com.university.swap.dto.ApiResponse;
import com.university.swap.model.Enrollment;
import com.university.swap.repository.EnrollmentRepository;
import com.university.swap.service.EnrollmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/enrollments")
@RequiredArgsConstructor
public class EnrollmentController {

    private final EnrollmentRepository enrollmentRepo;
    private final EnrollmentService enrollmentService;

    // GET /api/enrollments/my?studentId=1
    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<Enrollment>>> getMyEnrollments(@RequestParam Long studentId) {
        List<Enrollment> enrollments = enrollmentRepo.findAllActiveByStudent(studentId);
        return ResponseEntity.ok(ApiResponse.ok("Enrollments retrieved", enrollments));
    }

    // POST /api/enrollments/add?studentId=1&sectionId=5
    @PostMapping("/add")
    public ResponseEntity<ApiResponse<String>> addSection(@RequestParam Long studentId,
                                                           @RequestParam Long sectionId) {
        enrollmentService.addSection(studentId, sectionId);
        return ResponseEntity.ok(ApiResponse.ok("Section added successfully!", null));
    }

    // DELETE /api/enrollments/remove?studentId=1&sectionId=5
    @DeleteMapping("/remove")
    public ResponseEntity<ApiResponse<String>> removeSection(@RequestParam Long studentId,
                                                              @RequestParam Long sectionId) {
        enrollmentService.removeSection(studentId, sectionId);
        return ResponseEntity.ok(ApiResponse.ok("Section removed successfully.", null));
    }
}
