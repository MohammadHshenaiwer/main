package com.university.swap.repository;

import com.university.swap.model.SwapOffer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SwapOfferRepository extends JpaRepository<SwapOffer, Long> {

    // All open offers EXCEPT the current student's own, AND either public or targeted at this student
    @Query("SELECT o FROM SwapOffer o WHERE o.status = 'OPEN' " +
            "AND o.student.studentId != :studentId " +
            "AND (o.targetStudent IS NULL OR o.targetStudent.studentId = :studentId) " +
            "AND EXISTS (SELECT 1 FROM Enrollment e WHERE e.student.studentId = o.student.studentId " +
            "AND e.section.sectionId = o.haveSection.sectionId AND e.status = 'ACTIVE')")
    List<SwapOffer> findAllOpenExcludingStudent(@Param("studentId") Long studentId);

    // All offers by a specific student
    List<SwapOffer> findByStudent_StudentIdOrderByCreatedAtDesc(Long studentId);

    // Find open/pending offer IDs where student offered a specific section (excluding one offer)
    @Query("SELECT o.offerId FROM SwapOffer o WHERE o.student.studentId = :studentId " +
           "AND o.haveSection.sectionId = :sectionId AND o.status IN ('OPEN', 'PENDING') " +
           "AND o.offerId != :excludeOfferId")
    List<Long> findOpenOfferIdsByStudentAndHaveSection(@Param("studentId") Long studentId,
                                                       @Param("sectionId") Long sectionId,
                                                       @Param("excludeOfferId") Long excludeOfferId);

    // Cancel open/pending offers where student offered a specific section (excluding one offer)
    @Modifying
    @Query("UPDATE SwapOffer o SET o.status = 'CANCELLED' " +
           "WHERE o.student.studentId = :studentId AND o.haveSection.sectionId = :sectionId " +
           "AND o.status IN ('OPEN', 'PENDING') AND o.offerId != :excludeOfferId")
    int cancelOpenOffersByStudentAndHaveSection(@Param("studentId") Long studentId,
                                                @Param("sectionId") Long sectionId,
                                                @Param("excludeOfferId") Long excludeOfferId);

    // Cancel ALL open/pending offers where student offered a specific section (no exclusion — used on enrollment delete)
    @Modifying
    @Query("UPDATE SwapOffer o SET o.status = 'CANCELLED' " +
           "WHERE o.student.studentId = :studentId AND o.haveSection.sectionId = :sectionId " +
           "AND o.status IN ('OPEN', 'PENDING')")
    int cancelAllOpenOffersByStudentAndHaveSection(@Param("studentId") Long studentId,
                                                   @Param("sectionId") Long sectionId);

    // Find ALL open/pending offer IDs for a student+section (no exclusion)
    @Query("SELECT o.offerId FROM SwapOffer o WHERE o.student.studentId = :studentId " +
           "AND o.haveSection.sectionId = :sectionId AND o.status IN ('OPEN', 'PENDING')")
    List<Long> findAllOpenOfferIdsByStudentAndHaveSection(@Param("studentId") Long studentId,
                                                          @Param("sectionId") Long sectionId);

    // Check if student already has an active offer for the same offered section
    @Query("SELECT COUNT(o) > 0 FROM SwapOffer o WHERE o.student.studentId = :studentId " +
           "AND o.haveSection.sectionId = :sectionId AND o.status IN ('OPEN', 'PENDING')")
    boolean hasActiveOfferForSection(@Param("studentId") Long studentId,
                                     @Param("sectionId") Long sectionId);

    // Re-open offers that were pending after their request got cancelled
    @Modifying
    @Query("UPDATE SwapOffer o SET o.status = 'OPEN' WHERE o.offerId IN :offerIds AND o.status = 'PENDING'")
    int reopenPendingOffersByIds(@Param("offerIds") List<Long> offerIds);
}
