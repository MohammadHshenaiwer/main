package com.university.swap.model;

import com.university.swap.enums.OfferStatus;
import com.university.swap.enums.SwapType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

// ================================================
// SwapOffer.java
//
// NEW LOGIC:
//   - Student picks ONE of their enrolled courses (haveSection)
//   - Student types freely what they WANT (wantCourseName)
//     e.g. "English 1" or "Programming 2"
//   - The offer is posted on the board
//   - Other students can see it and send a direct request
// ================================================

@Entity
@Table(name = "swap_offers")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SwapOffer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "offer_id")
    private Long offerId;

    // Student who posted this offer
    @ManyToOne
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    // Type: SECTION_SWAP or COURSE_SWAP
    @Enumerated(EnumType.STRING)
    @Column(name = "swap_type", nullable = false)
    private SwapType swapType;

    // The section the student currently HAS (from their enrollment)
    // Used for both section and course swaps
    @ManyToOne
    @JoinColumn(name = "have_section_id")
    private Section haveSection;

    // What the student WANTS — exact section from catalog
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "want_section_id", nullable = true)
    private Section wantSection;

    // Optional: If trading directly with a specific student
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "target_student_id")
    private Student targetStudent;

    // Status of this offer
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private OfferStatus status = OfferStatus.OPEN;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
