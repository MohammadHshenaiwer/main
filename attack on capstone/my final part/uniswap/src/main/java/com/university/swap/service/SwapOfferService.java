package com.university.swap.service;

import com.university.swap.dto.CreateOfferRequest;
import com.university.swap.enums.OfferStatus;
import com.university.swap.exception.ResourceNotFoundException;
import com.university.swap.exception.SwapException;
import com.university.swap.model.*;
import com.university.swap.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SwapOfferService {

    private final SwapOfferRepository offerRepo;
    private final StudentRepository studentRepo;
    private final EnrollmentRepository enrollmentRepo;
    private final SectionRepository sectionRepo;

    // ── Get all open offers (Swap Board) ──────────────────────
    public List<SwapOffer> getAllOpenOffers(Long currentStudentId) {
        return offerRepo.findAllOpenExcludingStudent(currentStudentId);
    }

    // ── Get my own offers ──────────────────────────────────────
    public List<SwapOffer> getMyOffers(Long studentId) {
        return offerRepo.findByStudent_StudentIdOrderByCreatedAtDesc(studentId);
    }

    // ── Create a new offer ─────────────────────────────────────
    // NEW LOGIC:
    //   Student selects one of their enrolled sections (haveSectionId)
    //   Student types what they want (wantDescription) as free text
    @Transactional
    public SwapOffer createOffer(CreateOfferRequest req) {

        // 1. Student must exist
        Student student = studentRepo.findById(req.getStudentId())
                .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + req.getStudentId()));

        // 2. Section must exist
        Section haveSection = sectionRepo.findById(req.getHaveSectionId())
                .orElseThrow(() -> new ResourceNotFoundException("Section not found: " + req.getHaveSectionId()));

        // 3. Student must actually be enrolled in that section
        enrollmentRepo.findActiveByStudentAndSection(req.getStudentId(), req.getHaveSectionId())
                .orElseThrow(() -> new SwapException(
                        "You are not enrolled in section: " + haveSection.getSectionNumber()
                        + " of " + haveSection.getCourse().getCourseName()));

        // 4. wantSection must exist
        if (req.getWantSectionId() == null) {
            throw new SwapException("Please select what course/section you want to receive.");
        }
        Section wantSection = sectionRepo.findById(req.getWantSectionId())
                .orElseThrow(() -> new ResourceNotFoundException("Target Section not found: " + req.getWantSectionId()));

        // 5. Check if targeting a specific student
        Student targetStudent = null;
        if (req.getTargetStudentId() != null) {
            targetStudent = studentRepo.findById(req.getTargetStudentId())
                    .orElseThrow(() -> new ResourceNotFoundException("Target student not found: " + req.getTargetStudentId()));
        }

        // 6. Build and save
        SwapOffer offer = new SwapOffer();
        offer.setStudent(student);
        offer.setSwapType(req.getSwapType());
        offer.setHaveSection(haveSection);
        offer.setWantSection(wantSection);
        offer.setTargetStudent(targetStudent);
        offer.setStatus(OfferStatus.OPEN);

        return offerRepo.save(offer);
    }

    // ── Cancel an offer ────────────────────────────────────────
    @Transactional
    public void cancelOffer(Long offerId, Long studentId) {
        SwapOffer offer = offerRepo.findById(offerId)
                .orElseThrow(() -> new ResourceNotFoundException("Offer not found: " + offerId));

        if (!offer.getStudent().getStudentId().equals(studentId))
            throw new SwapException("You can only cancel your own offers.");

        if (offer.getStatus() == OfferStatus.COMPLETED)
            throw new SwapException("Cannot cancel a completed swap.");

        offer.setStatus(OfferStatus.CANCELLED);
        offerRepo.save(offer);
    }
}
