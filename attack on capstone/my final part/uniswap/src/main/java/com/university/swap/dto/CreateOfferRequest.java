package com.university.swap.dto;

import com.university.swap.enums.SwapType;
import lombok.Data;

// ================================================
// CreateOfferRequest.java
//
// JSON the frontend sends when creating an offer.
//
// Example:
// {
//   "studentId": 1,
//   "swapType": "COURSE_SWAP",
//   "haveSectionId": 3,
//   "wantDescription": "English 1"
// }
// ================================================

@Data
public class CreateOfferRequest {
    private Long studentId;
    private SwapType swapType;
    private Long haveSectionId;       // The section they currently have
    private Long wantSectionId;       // The specific section they want in return
    private Long targetStudentId;     // Optional: The ID of a student to send this request to directly.
}
