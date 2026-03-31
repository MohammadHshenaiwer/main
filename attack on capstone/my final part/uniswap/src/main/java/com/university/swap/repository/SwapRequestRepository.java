package com.university.swap.repository;

import com.university.swap.model.SwapRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SwapRequestRepository extends JpaRepository<SwapRequest, Long> {

    // Incoming requests for a student (they are the receiver)
    List<SwapRequest> findByReceiver_StudentIdOrderBySentAtDesc(Long receiverId);

    // Requests sent by a student
    List<SwapRequest> findBySender_StudentIdOrderBySentAtDesc(Long senderId);

    // Auto-reject all other pending requests on same offer after one is accepted
    @Modifying
    @Query("UPDATE SwapRequest r SET r.status = 'REJECTED', r.resolvedAt = CURRENT_TIMESTAMP " +
           "WHERE r.offer.offerId = :offerId AND r.requestId != :acceptedRequestId AND r.status = 'PENDING'")
    void rejectOtherRequests(@Param("offerId") Long offerId, @Param("acceptedRequestId") Long acceptedRequestId);

    // Check if sender already has a pending request for this offer
    @Query("SELECT COUNT(r) > 0 FROM SwapRequest r WHERE r.offer.offerId = :offerId " +
           "AND r.sender.studentId = :senderId AND r.status = 'PENDING'")
    boolean hasPendingRequest(@Param("offerId") Long offerId, @Param("senderId") Long senderId);

    // Cancel all pending requests for a list of offers (cascade when offers are cancelled)
    @Modifying
    @Query("UPDATE SwapRequest r SET r.status = 'CANCELLED', r.resolvedAt = CURRENT_TIMESTAMP " +
            "WHERE r.offer.offerId IN :offerIds AND r.status = 'PENDING'")
    void cancelPendingRequestsForOffers(@Param("offerIds") List<Long> offerIds);

    // Find pending requests sent by a student using a specific section
    @Query("SELECT DISTINCT r.offer.offerId FROM SwapRequest r WHERE r.sender.studentId = :studentId " +
            "AND r.senderSection.sectionId = :sectionId AND r.status = 'PENDING'")
    List<Long> findPendingOfferIdsBySenderAndSection(@Param("studentId") Long studentId,
                                                     @Param("sectionId") Long sectionId);

    // Cancel pending requests sent by a student using a specific section
    @Modifying
    @Query("UPDATE SwapRequest r SET r.status = 'CANCELLED', r.resolvedAt = CURRENT_TIMESTAMP " +
            "WHERE r.sender.studentId = :studentId AND r.senderSection.sectionId = :sectionId " +
            "AND r.status = 'PENDING'")
    int cancelPendingRequestsBySenderAndSection(@Param("studentId") Long studentId,
                                                @Param("sectionId") Long sectionId);
}
