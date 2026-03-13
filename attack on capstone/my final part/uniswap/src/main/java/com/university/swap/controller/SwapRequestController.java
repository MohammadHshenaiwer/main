package com.university.swap.controller;

import com.university.swap.dto.ApiResponse;
import com.university.swap.dto.SendSwapRequest;
import com.university.swap.model.SwapRequest;
import com.university.swap.service.SwapRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/swaps/requests")
@RequiredArgsConstructor
public class SwapRequestController {

    private final SwapRequestService requestService;

    // POST /api/swaps/requests
    @PostMapping
    public ResponseEntity<ApiResponse<SwapRequest>> send(@RequestBody SendSwapRequest dto) {
        return ResponseEntity.ok(ApiResponse.ok("Request sent!", requestService.sendRequest(dto)));
    }

    // POST /api/swaps/requests/accept-direct
    @PostMapping("/accept-direct")
    public ResponseEntity<ApiResponse<Void>> acceptDirect(@RequestBody com.university.swap.dto.DirectAcceptRequest dto) {
        requestService.acceptDirectTrade(dto);
        return ResponseEntity.ok(ApiResponse.ok("Trade Accepted via Direct Offer!", null));
    }

    // GET /api/swaps/requests/incoming?studentId=1
    @GetMapping("/incoming")
    public ResponseEntity<ApiResponse<List<SwapRequest>>> incoming(@RequestParam Long studentId) {
        return ResponseEntity.ok(ApiResponse.ok("Incoming requests", requestService.getIncoming(studentId)));
    }

    // GET /api/swaps/requests/sent?studentId=1
    @GetMapping("/sent")
    public ResponseEntity<ApiResponse<List<SwapRequest>>> sent(@RequestParam Long studentId) {
        return ResponseEntity.ok(ApiResponse.ok("Sent requests", requestService.getSent(studentId)));
    }

    // POST /api/swaps/requests/{id}/accept?studentId=1
    @PostMapping("/{requestId}/accept")
    public ResponseEntity<ApiResponse<Void>> accept(@PathVariable Long requestId, @RequestParam Long studentId) {
        requestService.acceptRequest(requestId, studentId);
        return ResponseEntity.ok(ApiResponse.ok("Swap completed! Enrollments updated.", null));
    }

    // POST /api/swaps/requests/{id}/reject?studentId=1
    @PostMapping("/{requestId}/reject")
    public ResponseEntity<ApiResponse<Void>> reject(@PathVariable Long requestId, @RequestParam Long studentId) {
        requestService.rejectRequest(requestId, studentId);
        return ResponseEntity.ok(ApiResponse.ok("Request rejected.", null));
    }

    // DELETE /api/swaps/requests/{id}?studentId=1
    @DeleteMapping("/{requestId}")
    public ResponseEntity<ApiResponse<Void>> cancel(@PathVariable Long requestId, @RequestParam Long studentId) {
        requestService.cancelRequest(requestId, studentId);
        return ResponseEntity.ok(ApiResponse.ok("Request cancelled.", null));
    }
}
