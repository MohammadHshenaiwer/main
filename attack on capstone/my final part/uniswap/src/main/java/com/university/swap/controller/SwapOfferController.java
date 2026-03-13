package com.university.swap.controller;

import com.university.swap.dto.ApiResponse;
import com.university.swap.dto.CreateOfferRequest;
import com.university.swap.model.SwapOffer;
import com.university.swap.service.SwapOfferService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/swaps/offers")
@RequiredArgsConstructor
public class SwapOfferController {

    private final SwapOfferService offerService;

    // GET /api/swaps/offers?studentId=1
    @GetMapping
    public ResponseEntity<ApiResponse<List<SwapOffer>>> getAll(@RequestParam Long studentId) {
        return ResponseEntity.ok(ApiResponse.ok("Offers retrieved", offerService.getAllOpenOffers(studentId)));
    }

    // GET /api/swaps/offers/my?studentId=1
    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<SwapOffer>>> getMy(@RequestParam Long studentId) {
        return ResponseEntity.ok(ApiResponse.ok("Your offers", offerService.getMyOffers(studentId)));
    }

    // POST /api/swaps/offers
    @PostMapping
    public ResponseEntity<ApiResponse<SwapOffer>> create(@RequestBody CreateOfferRequest req) {
        return ResponseEntity.ok(ApiResponse.ok("Offer created!", offerService.createOffer(req)));
    }

    // DELETE /api/swaps/offers/{id}?studentId=1
    @DeleteMapping("/{offerId}")
    public ResponseEntity<ApiResponse<Void>> cancel(@PathVariable Long offerId, @RequestParam Long studentId) {
        offerService.cancelOffer(offerId, studentId);
        return ResponseEntity.ok(ApiResponse.ok("Offer cancelled.", null));
    }
}
