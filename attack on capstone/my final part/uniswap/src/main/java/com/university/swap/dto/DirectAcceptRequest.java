package com.university.swap.dto;

import lombok.Data;

@Data
public class DirectAcceptRequest {
    private Long offerId;
    private Long accepterStudentId;
    private Long offeredSectionId;
}
