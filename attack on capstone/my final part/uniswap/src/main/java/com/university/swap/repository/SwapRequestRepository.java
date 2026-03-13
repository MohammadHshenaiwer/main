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
}
