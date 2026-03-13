package com.university.swap.dto;

import lombok.Data;

// ================================================
// SendSwapRequest.java
//
// JSON the frontend sends when a student sends
// a DIRECT request to another student.
//
// Example:
// {
//   "offerId": 2,
//   "senderId": 3,
//   "receiverId": 1,
//   "senderSectionId": 6
// }
// ================================================

@Data
public class SendSwapRequest {
    private Long offerId;          // Which offer they are responding to
    private Long senderId;         // Student sending the request
    private Long receiverId;       // Student receiving (offer owner)
    private Long senderSectionId;  // Which of sender's sections they are offering
}
