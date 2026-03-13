package com.university.swap.enums;

public enum OfferStatus {
    OPEN,        // Visible on board, accepting requests
    PENDING,     // A request was sent, waiting for response
    COMPLETED,   // Swap was executed
    CANCELLED    // Student cancelled
}
