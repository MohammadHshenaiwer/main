package com.university.swap.enums;

public enum RequestStatus {
    PENDING,    // Sent, waiting for response
    ACCEPTED,   // Accepted → swap executed
    REJECTED,   // Receiver rejected
    CANCELLED   // Sender cancelled
}
