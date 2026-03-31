package com.university.swap.repository;

import com.university.swap.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, Long> {
    Optional<Student> findByEmail(String email);
    Optional<Student> findByEmailIgnoreCase(String email);
    Optional<Student> findByStudentNumber(String studentNumber);

    @Query("SELECT s FROM Student s WHERE LOWER(TRIM(s.studentNumber)) = LOWER(TRIM(:studentNumber))")
    Optional<Student> findByStudentNumberNormalized(@Param("studentNumber") String studentNumber);
}
