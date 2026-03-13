package com.university.swap.repository;

import com.university.swap.model.SwapOffer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SwapOfferRepository extends JpaRepository<SwapOffer, Long> {

    // All open offers EXCEPT the current student's own, AND either public or targeted at this student
    @Query("SELECT o FROM SwapOffer o WHERE o.status = 'OPEN' AND o.student.studentId != :studentId AND (o.targetStudent IS NULL OR o.targetStudent.studentId = :studentId)")
    List<SwapOffer> findAllOpenExcludingStudent(@Param("studentId") Long studentId);

    // All offers by a specific student
    List<SwapOffer> findByStudent_StudentIdOrderByCreatedAtDesc(Long studentId);
}
