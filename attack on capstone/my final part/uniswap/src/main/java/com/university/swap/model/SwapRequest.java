package com.university.swap.model;

import com.university.swap.enums.RequestStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

// ================================================
// SwapRequest.java
//
// A direct request sent from Student B to Student A.
// Student B says: "I saw your offer, I want to swap with you."
// Student B also specifies WHICH of their sections they offer.
// ================================================

@Entity
@Table(name = "swap_requests")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SwapRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "request_id")
    private Long requestId;

    // The offer being responded to
    @ManyToOne
    @JoinColumn(name = "offer_id", nullable = false)
    private SwapOffer offer;

    // Student sending the request (wants to trade)
    @ManyToOne
    @JoinColumn(name = "sender_id", nullable = false)
    private Student sender;

    // Student receiving the request (offer owner)
    @ManyToOne
    @JoinColumn(name = "receiver_id", nullable = false)
    private Student receiver;

    // What the SENDER is offering in return
    // (one of their enrolled sections)
    @ManyToOne
    @JoinColumn(name = "sender_section_id")
    private Section senderSection;

    // Status
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private RequestStatus status = RequestStatus.PENDING;

    @CreationTimestamp
    @Column(name = "sent_at", updatable = false)
    private LocalDateTime sentAt;

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;
}
