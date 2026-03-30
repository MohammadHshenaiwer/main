package com.university.swap.controller;

import com.university.swap.dto.ApiResponse;
import com.university.swap.exception.ResourceNotFoundException;
import com.university.swap.model.Student;
import com.university.swap.repository.StudentCourseCompletionRepository;
import com.university.swap.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
public class StudentController {

    private final StudentRepository studentRepo;
    private final StudentCourseCompletionRepository completionRepo;

    // GET /api/students/{id} — verify student exists (used by login)
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Student>> getStudent(@PathVariable Long id) {
        Student student = studentRepo.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + id));
        return ResponseEntity.ok(ApiResponse.ok("Student found", student));
    }

    // GET /api/students/{id}/completions — list of completed course codes
    @GetMapping("/{id}/completions")
    public ResponseEntity<ApiResponse<List<String>>> getCompletions(@PathVariable Long id) {
        // Verify student exists
        studentRepo.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + id));
        List<String> codes = completionRepo.findCompletedCourseCodesByStudent(id);
        return ResponseEntity.ok(ApiResponse.ok("Completed courses", codes));
    }
}
