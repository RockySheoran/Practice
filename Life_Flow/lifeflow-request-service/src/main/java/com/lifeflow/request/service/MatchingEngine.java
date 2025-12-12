package com.lifeflow.request.service;

import com.lifeflow.request.dto.MatchedDonorDTO;
import com.lifeflow.request.entity.BloodRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Comparator;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class MatchingEngine {

    private final DonorServiceClient donorServiceClient;
    private final InventoryServiceClient inventoryServiceClient;
    private final GeolocationServiceClient geoServiceClient;

    /**
     * Find matched donors for a blood request
     * Algorithm: Score-based matching
     */
    public List<MatchedDonorDTO> findMatchedDonors(BloodRequest request) {
        
        log.info("Starting donor matching for request: {} - Blood Type: {}",
                request.getRequestId(), request.getBloodTypeNeeded());
        
        // Step 1: Check inventory for stock
        boolean stockAvailable = inventoryServiceClient.checkStock(
                request.getBloodTypeNeeded().toString(),
                request.getUnitsRequired());
        
        if (stockAvailable) {
            log.info("Stock available in inventory for request: {}", request.getRequestId());
            return List.of(); // Return empty, use stock instead
        }
        
        // Step 2: Find eligible donors
        List<MatchedDonorDTO> eligibleDonors = donorServiceClient.findEligibleDonors(
                request.getBloodTypeNeeded().toString(),
                request.getUnitsRequired());
        
        log.info("Found {} eligible donors for request: {}",
                eligibleDonors.size(), request.getRequestId());
        
        // Step 3: Calculate compatibility scores
        eligibleDonors.forEach(donor -> {
            int compatibilityScore = calculateCompatibilityScore(request, donor);
            donor.setMatchScore(compatibilityScore);
        });
        
        // Step 4: Get geolocation distances
        String hospitalLocation = request.getGpsLocationHospital();
        eligibleDonors.forEach(donor -> {
            Double distance = geoServiceClient.calculateDistance(
                    donor.getDonorLocation(), hospitalLocation);
            donor.setDistanceKm(distance);
            
            // Distance score (0-30 points, closer is better)
            int distanceScore = calculateDistanceScore(distance);
            donor.setDistanceScore(distanceScore);
        });
        
        // Step 5: Calculate final match score
        eligibleDonors.forEach(donor -> {
            int finalScore = donor.getCompatibilityScore() +
                           donor.getDistanceScore() +
                           donor.getReliabilityScore();
            
            // Apply urgency multiplier for critical requests
            if (request.isCritical()) {
                finalScore = (int) (finalScore * 1.5);
            }
            
            donor.setFinalMatchScore(finalScore);
        });
        
        // Step 6: Sort by final score (descending)
        List<MatchedDonorDTO> rankedDonors = eligibleDonors.stream()
                .sorted(Comparator.comparingInt(MatchedDonorDTO::getFinalMatchScore).reversed())
                .limit(10) // Return top 10 matches
                .toList();
        
        log.info("Ranked {} top donors for request: {}", rankedDonors.size(),
                request.getRequestId());
        
        return rankedDonors;
    }

    /**
     * Calculate compatibility score (0-40 points)
     */
    private int calculateCompatibilityScore(BloodRequest request, MatchedDonorDTO donor) {
        String bloodType = request.getBloodTypeNeeded().toString();
        
        if (bloodType.equals(donor.getBloodType())) {
            return 40; // Exact match
        }
        
        // Check universal compatibility
        if ((bloodType.startsWith("A") || bloodType.startsWith("B") || bloodType.startsWith("AB"))
            && donor.getBloodType().equals("O_POSITIVE")) {
            return 35; // Compatible
        }
        
        if (bloodType.equals("AB_POSITIVE") && 
            (donor.getBloodType().equals("O_POSITIVE") || 
             donor.getBloodType().equals("A_POSITIVE") ||
             donor.getBloodType().equals("B_POSITIVE"))) {
            return 35;
        }
        
        if (bloodType.endsWith("NEGATIVE") && donor.getBloodType().endsWith("NEGATIVE")) {
            return 30; // Both negative
        }
        
        return 10; // Incompatible but may still work in emergency
    }

    /**
     * Calculate distance score (0-30 points, closer is better)
     */
    private int calculateDistanceScore(Double distanceKm) {
        if (distanceKm == null) return 0;
        
        if (distanceKm <= 1) return 30;
        if (distanceKm <= 2) return 25;
        if (distanceKm <= 3) return 20;
        if (distanceKm <= 5) return 15;
        if (distanceKm <= 10) return 10;
        
        return 5;
    }

    // Feign Clients for inter-service communication
    @FeignClient(name = "donor-service", url = "${services.donor-service.url:http://localhost:3002}")
    public interface DonorServiceClient {
        @GetMapping("/api/v1/donors/eligible")
        List<MatchedDonorDTO> findEligibleDonors(
                @RequestParam String bloodType,
                @RequestParam Double units);
    }

    @FeignClient(name = "inventory-service", url = "${services.inventory-service.url:http://localhost:3003}")
    public interface InventoryServiceClient {
        @GetMapping("/api/v1/inventory/check-stock")
        boolean checkStock(
                @RequestParam String bloodType,
                @RequestParam Double units);
    }

    @FeignClient(name = "geolocation-service", url = "${services.geolocation-service.url:http://localhost:3005}")
    public interface GeolocationServiceClient {
        @GetMapping("/api/v1/geo/distance")
        Double calculateDistance(
                @RequestParam String origin,
                @RequestParam String destination);
    }
}
