package com.university.swap.controller;

import com.university.swap.dto.ApiResponse;
import com.university.swap.exception.ResourceNotFoundException;
import com.university.swap.model.Course;
import com.university.swap.model.Student;
import com.university.swap.model.StudentCourseCompletion;
import com.university.swap.repository.CourseRepository;
import com.university.swap.repository.StudentCourseCompletionRepository;
import com.university.swap.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashSet;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("/api/students")
@RequiredArgsConstructor
public class StudentController {

    private static final int MAX_PROGRAM_YEAR = 4;
    private static final String HTU_EMAIL_DOMAIN = "@htu.edu.jo";
    private static final Set<String> SECOND_YEAR_OVERRIDES = Set.of("22220020", "22001414");
    private static final Set<String> THIRD_YEAR_OVERRIDES = Set.of("23012001", "23012002");

    private final StudentRepository studentRepo;
    private final StudentCourseCompletionRepository completionRepo;
    private final CourseRepository courseRepo;

    // GET /api/students/{id} — verify student exists (used by login)
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Student>> getStudent(@PathVariable Long id) {
        Student student = studentRepo.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + id));
        return ResponseEntity.ok(ApiResponse.ok("Student found", student));
    }

    // GET /api/students/login?identifier=...
    // Also supports legacy param: ?studentNumber=...
    @GetMapping("/login")
    public ResponseEntity<ApiResponse<Student>> loginUser(
            @RequestParam(required = false) String identifier,
            @RequestParam(required = false) String studentNumber) {

        String lookupValue = normalizeIdentifier(identifier != null ? identifier : studentNumber);
        if (lookupValue == null) {
            throw new ResourceNotFoundException("Student not found: missing identifier");
        }

        Student student = findStudentByIdentifier(lookupValue)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + lookupValue));
        return ResponseEntity.ok(ApiResponse.ok("Student found", student));
    }

    // GET /api/students/{id}/completions — list of completed course codes
    @GetMapping("/{id}/completions")
    public ResponseEntity<ApiResponse<List<String>>> getCompletions(@PathVariable Long id) {
        // Verify student exists
        Student student = studentRepo.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + id));
        syncCompletionsByAcademicYear(student);
        List<String> codes = completionRepo.findCompletedCourseCodesByStudent(id);
        return ResponseEntity.ok(ApiResponse.ok("Completed courses", codes));
    }

    private void syncCompletionsByAcademicYear(Student student) {
        Integer studentYear = deriveStudentYear(student.getStudentNumber());
        if (studentYear == null || studentYear <= 1) {
            return;
        }

        Set<Long> passedCourseIds = new HashSet<>(completionRepo.findPassedCourseIdsByStudent(student.getStudentId()));
        List<StudentCourseCompletion> pendingCompletions = new ArrayList<>();
        List<Course> courses = courseRepo.findAll();

        for (Course course : courses) {
            Integer courseYear = deriveCourseYear(course.getCourseCode());
            if (courseYear == null || courseYear >= studentYear) {
                continue;
            }

            if (passedCourseIds.contains(course.getCourseId())) {
                continue;
            }

            StudentCourseCompletion completion = new StudentCourseCompletion();
            completion.setStudent(student);
            completion.setCourse(course);
            completion.setStatus("passed");
            completion.setGrade("P");
            completion.setTerm("Auto-Year");
            pendingCompletions.add(completion);
            passedCourseIds.add(course.getCourseId());
        }

        if (!pendingCompletions.isEmpty()) {
            completionRepo.saveAll(pendingCompletions);
        }
    }

    private java.util.Optional<Student> findStudentByIdentifier(String identifier) {
        String normalized = normalizeIdentifier(identifier);
        if (normalized == null) {
            return java.util.Optional.empty();
        }

        if (isNumeric(normalized)) {
            try {
                Long studentId = Long.parseLong(normalized);
                java.util.Optional<Student> byId = studentRepo.findById(studentId);
                if (byId.isPresent()) {
                    return byId;
                }
            } catch (NumberFormatException ignored) {
            }

            java.util.Optional<Student> byNumber = studentRepo.findByStudentNumberNormalized(normalized);
            if (byNumber.isPresent()) {
                return byNumber;
            }

            return studentRepo.findByEmailIgnoreCase(normalized + HTU_EMAIL_DOMAIN);
        }

        if (normalized.contains("@")) {
            java.util.Optional<Student> byEmail = studentRepo.findByEmailIgnoreCase(normalized);
            if (byEmail.isPresent()) {
                return byEmail;
            }

            String localPart = normalized.substring(0, normalized.indexOf('@')).trim();
            if (!localPart.isEmpty()) {
                return studentRepo.findByStudentNumberNormalized(localPart);
            }

            return java.util.Optional.empty();
        }

        java.util.Optional<Student> byNumber = studentRepo.findByStudentNumberNormalized(normalized);
        if (byNumber.isPresent()) {
            return byNumber;
        }

        java.util.Optional<Student> byEmail = studentRepo.findByEmailIgnoreCase(normalized);
        if (byEmail.isPresent()) {
            return byEmail;
        }

        return studentRepo.findByEmailIgnoreCase(normalized + HTU_EMAIL_DOMAIN);
    }

    private boolean isNumeric(String value) {
        if (value == null || value.isBlank()) {
            return false;
        }

        for (int i = 0; i < value.length(); i++) {
            if (!Character.isDigit(value.charAt(i))) {
                return false;
            }
        }
        return true;
    }

    private String normalizeIdentifier(String value) {
        if (value == null) {
            return null;
        }

        String normalized = value.trim();
        return normalized.isEmpty() ? null : normalized;
    }

    private Integer deriveStudentYear(String studentNumber) {
        if (studentNumber == null) {
            return null;
        }

        String trimmed = studentNumber.trim();
        if (SECOND_YEAR_OVERRIDES.contains(trimmed)) {
            return 2;
        }
        if (THIRD_YEAR_OVERRIDES.contains(trimmed)) {
            return 3;
        }

        if (trimmed.length() < 2 || !Character.isDigit(trimmed.charAt(0)) || !Character.isDigit(trimmed.charAt(1))) {
            return null;
        }

        int intakeYear = 2000 + Integer.parseInt(trimmed.substring(0, 2));
        LocalDate now = LocalDate.now();
        int academicStartYear = now.getMonthValue() >= 9 ? now.getYear() : now.getYear() - 1;
        int derived = academicStartYear - intakeYear + 1;

        if (derived < 1) {
            return 1;
        }
        if (derived > MAX_PROGRAM_YEAR) {
            return MAX_PROGRAM_YEAR;
        }
        return derived;
    }

    private Integer deriveCourseYear(String courseCode) {
        if (courseCode == null) {
            return null;
        }

        String code = courseCode.trim();
        if (code.length() < 6) {
            return null;
        }

        char yearChar = code.charAt(5);
        if (!Character.isDigit(yearChar)) {
            return null;
        }

        int year = Character.getNumericValue(yearChar);
        if (year < 1 || year > MAX_PROGRAM_YEAR) {
            return null;
        }
        return year;
    }
}
