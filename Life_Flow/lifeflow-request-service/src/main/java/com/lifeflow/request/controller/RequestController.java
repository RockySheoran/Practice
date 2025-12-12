package com.lifeflow.request.controller;

import com.lifeflow.common.dto.ApiResponse;
import com.lifeflow.request.dto.CreateRequestDTO;
import com.lifeflow.request.dto.RequestResponseDTO;
import com.lifeflow.request.entity.BloodRequest;
import com.lifeflow.request.service.RequestService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/v1/requests")
@RequiredArgsConstructor
public class RequestController {

    private final RequestService requestService;

    /**
     * Create an emergency blood request
     * POST /api/v1/requests/create
     */
    @PostMapping("/create")
    @PreAuthorize("hasAnyRole('HOSPITAL', 'ADMIN')")
    public ResponseEntity<ApiResponse<RequestResponseDTO>> createRequest(
            @Valid @RequestBody CreateRequestDTO createRequestDTO) {
        
        log.info("Emergency blood request received from hospital: {} for blood type: {}",
                createRequestDTO.getHospitalId(), createRequestDTO.getBloodType());
        
        BloodRequest request = requestService.createEmergencyRequest(createRequestDTO);
        
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(
                        "Emergency request created and donor search initiated",
                        RequestResponseDTO.fromEntity(request)
                ));
    }

    /**
     * Get request details by ID
     * GET /api/v1/requests/{requestId}
     */
    @GetMapping("/{requestId}")
    public ResponseEntity<ApiResponse<RequestResponseDTO>> getRequest(
            @PathVariable String requestId) {
        
        log.info("Fetching request details: {}", requestId);
        
        BloodRequest request = requestService.getRequestById(requestId);
        
        return ResponseEntity.ok(ApiResponse.success(
                "Request details retrieved",
                RequestResponseDTO.fromEntity(request)
        ));
    }

    /**
     * Get all active requests
     * GET /api/v1/requests/active
     */
    @GetMapping("/active")
    @PreAuthorize("hasAnyRole('HOSPITAL', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<RequestResponseDTO>>> getActiveRequests() {
        
        log.info("Fetching all active requests");
        
        List<BloodRequest> requests = requestService.getActiveRequests();
        
        return ResponseEntity.ok(ApiResponse.success(
                "Active requests retrieved",
                requests.stream()
                        .map(RequestResponseDTO::fromEntity)
                        .toList()
        ));
    }

    /**
     * Accept a request response (donor accepts)
     * POST /api/v1/requests/{requestId}/accept-response
     */
    @PostMapping("/{requestId}/accept-response/{responseId}")
    @PreAuthorize("hasRole('DONOR')")
    public ResponseEntity<ApiResponse<String>> acceptResponse(
            @PathVariable String requestId,
            @PathVariable String responseId,
            @RequestParam Integer arrivalMinutes) {
        
        log.info("Donor accepting response for request: {} with ETA: {} minutes",
                requestId, arrivalMinutes);
        
        requestService.acceptResponse(responseId, arrivalMinutes);
        
        return ResponseEntity.ok(ApiResponse.success(
                "Response accepted. Please proceed to collection center",
                responseId
        ));
    }

    /**
     * Cancel a request
     * DELETE /api/v1/requests/{requestId}
     */
    @DeleteMapping("/{requestId}")
    @PreAuthorize("hasAnyRole('HOSPITAL', 'ADMIN')")
    public ResponseEntity<ApiResponse<String>> cancelRequest(
            @PathVariable String requestId,
            @RequestParam(required = false) String reason) {
        
        log.warn("Request cancellation initiated for: {} - Reason: {}", requestId, reason);
        
        requestService.cancelRequest(requestId, reason);
        
        return ResponseEntity.ok(ApiResponse.success(
                "Request cancelled successfully",
                requestId
        ));
    }

    /**
     * Get matching donors for a request
     * GET /api/v1/requests/{requestId}/matched-donors
     */
    @GetMapping("/{requestId}/matched-donors")
    @PreAuthorize("hasAnyRole('HOSPITAL', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<?>>> getMatchedDonors(
            @PathVariable String requestId) {
        
        log.info("Fetching matched donors for request: {}", requestId);
        
        List<?> matchedDonors = requestService.getMatchedDonors(requestId);
        
        return ResponseEntity.ok(ApiResponse.success(
                "Matched donors retrieved",
                matchedDonors
        ));
    }
}
