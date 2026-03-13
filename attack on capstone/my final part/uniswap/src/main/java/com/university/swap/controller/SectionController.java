package com.university.swap.controller;

import com.university.swap.dto.ApiResponse;
import com.university.swap.model.Section;
import com.university.swap.repository.SectionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/sections")
@RequiredArgsConstructor
public class SectionController {

    private final SectionRepository sectionRepo;

    @GetMapping
    public ResponseEntity<ApiResponse<List<Section>>> getAllSections() {
        return ResponseEntity.ok(ApiResponse.ok("Sections retrieved", sectionRepo.findAll()));
    }
}
