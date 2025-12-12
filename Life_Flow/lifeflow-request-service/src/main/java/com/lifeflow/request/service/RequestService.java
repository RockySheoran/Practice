package com.lifeflow.request.service;

import com.lifeflow.common.event.EventPublisher;
import com.lifeflow.request.dto.CreateRequestDTO;
import com.lifeflow.request.entity.BloodRequest;
import com.lifeflow.request.entity.RequestResponse;
import com.lifeflow.request.event.BloodNeededEvent;
import com.lifeflow.request.event.DonorAcceptedEvent;
import com.lifeflow.request.repository.BloodRequestRepository;
import com.lifeflow.request.repository.RequestResponseRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class RequestService {

    private final BloodRequestRepository requestRepository;
    private final RequestResponseRepository responseRepository;
    private final EventPublisher eventPublisher;
    private final MatchingEngine matchingEngine;

    /**
     * Create emergency blood request and trigger donor matching
     */
    @Transactional
    public BloodRequest createEmergencyRequest(CreateRequestDTO dto) {
        
        log.info("Creating emergency blood request for hospital: {}", dto.getHospitalId());
        
        // Generate unique request ID
        String requestId = "req-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        
        // Calculate deadline
        LocalDateTime deadline = LocalDateTime.now()
                .plusMinutes(dto.getDeadlineMinutes());
        
        // Create blood request entity
        BloodRequest request = BloodRequest.builder()
                .requestId(requestId)
                .hospitalId(dto.getHospitalId())
                .bloodTypeNeeded(BloodRequest.BloodType.valueOf(dto.getBloodType()))
                .unitsRequired(dto.getUnitsRequired())
                .urgencyLevel(BloodRequest.UrgencyLevel.valueOf(dto.getUrgencyLevel()))
                .urgencyNumericScore(calculateUrgencyScore(dto.getUrgencyLevel()))
                .patientAge(dto.getPatientAge())
                .patientCondition(dto.getPatientCondition())
                .deadlineMinutes(dto.getDeadlineMinutes())
                .deadlineTimestamp(deadline)
                .status(BloodRequest.RequestStatus.PENDING)
                .gpsLocationHospital(dto.getGpsLocation())
                .build();
        
        // Save to database
        BloodRequest savedRequest = requestRepository.save(request);
        
        log.info("Emergency request created with ID: {} - Blood Type: {} - Deadline: {}",
                requestId, dto.getBloodType(), deadline);
        
        // Publish event to trigger donor matching
        BloodNeededEvent event = BloodNeededEvent.builder()
                .requestId(requestId)
                .bloodType(dto.getBloodType())
                .unitsRequired(dto.getUnitsRequired())
                .urgencyLevel(dto.getUrgencyLevel())
                .hospitalId(dto.getHospitalId())
                .deadlineMinutes(dto.getDeadlineMinutes())
                .timestamp(LocalDateTime.now())
                .build();
        
        eventPublisher.publishEvent(event);
        
        log.info("BloodNeededEvent published for request: {}", requestId);
        
        return savedRequest;
    }

    /**
     * Accept donor response and initiate pickup scheduling
     */
    @Transactional
    public void acceptResponse(String responseId, Integer arrivalMinutes) {
        
        log.info("Processing acceptance for response: {} with arrival ETA: {} minutes",
                responseId, arrivalMinutes);
        
        RequestResponse response = responseRepository.findById(responseId)
                .orElseThrow(() -> new RuntimeException("Response not found: " + responseId));
        
        // Update response status
        response.setResponseStatus(RequestResponse.ResponseStatus.ACCEPTED);
        response.setConfirmedByDonorAt(LocalDateTime.now());
        response.setScheduledPickupTime(LocalDateTime.now().plusMinutes(arrivalMinutes));
        
        responseRepository.save(response);
        
        // Publish donor accepted event
        DonorAcceptedEvent event = DonorAcceptedEvent.builder()
                .requestId(response.getRequest().getRequestId())
                .responseId(responseId)
                .donorId(response.getDonor().getDonorId())
                .arrivalEtaMinutes(arrivalMinutes)
                .scheduledPickupTime(response.getScheduledPickupTime())
                .timestamp(LocalDateTime.now())
                .build();
        
        eventPublisher.publishEvent(event);
        
        log.info("DonorAcceptedEvent published for response: {} and request: {}",
                responseId, response.getRequest().getRequestId());
    }

    /**
     * Get request by ID
     */
    public BloodRequest getRequestById(String requestId) {
        log.info("Retrieving request: {}", requestId);
        
        return requestRepository.findById(requestId)
                .orElseThrow(() -> new RuntimeException("Request not found: " + requestId));
    }

    /**
     * Get all active requests
     */
    public List<BloodRequest> getActiveRequests() {
        log.info("Fetching all active requests");
        
        return requestRepository.findByStatusIn(List.of(
                BloodRequest.RequestStatus.PENDING,
                BloodRequest.RequestStatus.MATCHED,
                BloodRequest.RequestStatus.ACCEPTED
        ));
    }

    /**
     * Cancel request
     */
    @Transactional
    public void cancelRequest(String requestId, String reason) {
        log.warn("Cancelling request: {} - Reason: {}", requestId, reason);
        
        BloodRequest request = getRequestById(requestId);
        request.setStatus(BloodRequest.RequestStatus.CANCELLED);
        request.setCancelledAt(LocalDateTime.now());
        request.setCancellationReason(reason);
        
        requestRepository.save(request);
        
        log.info("Request cancelled: {}", requestId);
    }

    /**
     * Get matched donors for a request
     */
    public List<?> getMatchedDonors(String requestId) {
        log.info("Retrieving matched donors for request: {}", requestId);
        
        BloodRequest request = getRequestById(requestId);
        
        // Call matching engine to get ranked donors
        return matchingEngine.findMatchedDonors(request);
    }

    /**
     * Calculate urgency score (0-100)
     */
    private Integer calculateUrgencyScore(String urgencyLevel) {
        return switch (urgencyLevel) {
            case "CRITICAL" -> 100;
            case "HIGH" -> 75;
            case "MEDIUM" -> 50;
            case "LOW" -> 25;
            default -> 0;
        };
    }
}
