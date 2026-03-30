package com.university.swap.repository;

import com.university.swap.model.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EnrollmentRepository extends JpaRepository<Enrollment, Long> {

    // Check if student is enrolled in a specific section
    @Query("SELECT e FROM Enrollment e WHERE e.student.studentId = :studentId " +
           "AND e.section.sectionId = :sectionId AND e.status = 'ACTIVE'")
    Optional<Enrollment> findActiveByStudentAndSection(
            @Param("studentId") Long studentId,
            @Param("sectionId") Long sectionId);

    // Get all active enrollments for a student (for the dropdown)
    @Query("SELECT e FROM Enrollment e WHERE e.student.studentId = :studentId AND e.status = 'ACTIVE'")
    List<Enrollment> findAllActiveByStudent(@Param("studentId") Long studentId);

    // Swap two students' sections atomically
    @Modifying
    @Query("UPDATE Enrollment e SET e.section.sectionId = :newSectionId " +
           "WHERE e.student.studentId = :studentId " +
           "AND e.section.sectionId = :oldSectionId AND e.status = 'ACTIVE'")
    int updateStudentSection(
            @Param("studentId") Long studentId,
            @Param("oldSectionId") Long oldSectionId,
            @Param("newSectionId") Long newSectionId);

    // Delete an enrollment by student and section
    @Modifying
    @Query("DELETE FROM Enrollment e WHERE e.student.studentId = :studentId " +
           "AND e.section.sectionId = :sectionId AND e.status = 'ACTIVE'")
    int deleteByStudentAndSection(@Param("studentId") Long studentId,
                                  @Param("sectionId") Long sectionId);

    // Check if student is enrolled in any active section of a specific course
    @Query("SELECT COUNT(e) > 0 FROM Enrollment e WHERE e.student.studentId = :studentId " +
           "AND e.section.course.courseId = :courseId AND e.status = 'ACTIVE'")
    boolean isEnrolledInCourse(@Param("studentId") Long studentId,
                                @Param("courseId") Long courseId);
}
