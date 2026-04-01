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
           "AND e.section.sectionId = :sectionId " +
           "AND UPPER(COALESCE(e.status, '')) = 'ACTIVE' " +
           "ORDER BY e.enrollmentId ASC")
    List<Enrollment> findActiveRowsByStudentAndSection(
            @Param("studentId") Long studentId,
            @Param("sectionId") Long sectionId);

    default Optional<Enrollment> findActiveByStudentAndSection(Long studentId, Long sectionId) {
        List<Enrollment> rows = findActiveRowsByStudentAndSection(studentId, sectionId);
        return rows.isEmpty() ? Optional.empty() : Optional.of(rows.get(0));
    }

    // Get all active enrollments for a student (for the dropdown)
    @Query(value = "SELECT * FROM enrollments e WHERE e.enrollment_id IN (" +
                   "SELECT MIN(e2.enrollment_id) FROM enrollments e2 " +
                   "WHERE e2.student_id = :studentId " +
                   "AND UPPER(COALESCE(e2.status, '')) = 'ACTIVE' " +
                   "GROUP BY e2.section_id) ORDER BY e.enrollment_id", nativeQuery = true)
    List<Enrollment> findDistinctActiveRowsByStudent(@Param("studentId") Long studentId);

    default List<Enrollment> findAllActiveByStudent(Long studentId) {
        return findDistinctActiveRowsByStudent(studentId);
    }

    // Swap two students' sections atomically
    @Modifying
    @Query("UPDATE Enrollment e SET e.section.sectionId = :newSectionId " +
           "WHERE e.student.studentId = :studentId " +
           "AND e.section.sectionId = :oldSectionId " +
           "AND UPPER(COALESCE(e.status, '')) = 'ACTIVE'")
    int updateStudentSection(
            @Param("studentId") Long studentId,
            @Param("oldSectionId") Long oldSectionId,
            @Param("newSectionId") Long newSectionId);

    // Delete an enrollment by student and section
    @Modifying
    @Query("DELETE FROM Enrollment e WHERE e.student.studentId = :studentId " +
           "AND e.section.sectionId = :sectionId " +
           "AND UPPER(COALESCE(e.status, '')) = 'ACTIVE'")
    int deleteByStudentAndSection(@Param("studentId") Long studentId,
                                  @Param("sectionId") Long sectionId);

    // Check if student is enrolled in any active section of a specific course
    @Query("SELECT COUNT(e) > 0 FROM Enrollment e WHERE e.student.studentId = :studentId " +
           "AND e.section.course.courseId = :courseId " +
           "AND UPPER(COALESCE(e.status, '')) = 'ACTIVE'")
    boolean isEnrolledInCourse(@Param("studentId") Long studentId,
                                 @Param("courseId") Long courseId);

    @Modifying
    @Query(value = "DELETE FROM enrollments e USING enrollments d " +
                   "WHERE e.enrollment_id > d.enrollment_id " +
                   "AND e.student_id = d.student_id " +
                   "AND e.section_id = d.section_id " +
                   "AND UPPER(COALESCE(e.status, '')) = 'ACTIVE' " +
                   "AND UPPER(COALESCE(d.status, '')) = 'ACTIVE'", nativeQuery = true)
    int deleteDuplicateActiveEnrollments();
}
