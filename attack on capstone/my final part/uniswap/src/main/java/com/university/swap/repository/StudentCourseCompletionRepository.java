package com.university.swap.repository;

import com.university.swap.model.StudentCourseCompletion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface StudentCourseCompletionRepository extends JpaRepository<StudentCourseCompletion, Long> {

    @Query("SELECT COUNT(c) > 0 FROM StudentCourseCompletion c " +
            "WHERE c.student.studentId = :studentId " +
            "AND c.course.courseId = :courseId " +
            "AND LOWER(TRIM(c.status)) IN ('passed', 'completed')")
    boolean hasStudentPassedCourse(@Param("studentId") Long studentId,
            @Param("courseId") Long courseId);

    @Query("SELECT COUNT(c) > 0 FROM StudentCourseCompletion c " +
            "WHERE c.student.studentId = :studentId " +
            "AND TRIM(c.course.courseCode) = TRIM(:courseCode) " +
            "AND LOWER(TRIM(c.status)) IN ('passed', 'completed')")
    boolean hasStudentPassedCourseByCode(@Param("studentId") Long studentId,
            @Param("courseCode") String courseCode);

    // Get all completed course codes for a student (for frontend eligibility display)
    @Query("SELECT c.course.courseCode FROM StudentCourseCompletion c " +
            "WHERE c.student.studentId = :studentId " +
            "AND LOWER(TRIM(c.status)) IN ('passed', 'completed')")
    java.util.List<String> findCompletedCourseCodesByStudent(@Param("studentId") Long studentId);

    @Query("SELECT c.course.courseId FROM StudentCourseCompletion c " +
            "WHERE c.student.studentId = :studentId " +
            "AND LOWER(TRIM(c.status)) IN ('passed', 'completed')")
    java.util.List<Long> findPassedCourseIdsByStudent(@Param("studentId") Long studentId);
}
