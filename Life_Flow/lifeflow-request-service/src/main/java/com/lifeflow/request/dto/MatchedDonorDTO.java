package com.lifeflow.request.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MatchedDonorDTO {

    private String donorId;
    private String donorName;
    private String bloodType;
    private String phoneNumber;
    private Integer age;
    private Double weight;
    private String donorLocation;
    private Double distanceKm;
    
    // Scoring components
    private Integer compatibilityScore; // 0-40
    private Integer distanceScore;      // 0-30
    private Integer reliabilityScore;   // 0-20 (based on donation history)
    private Integer finalMatchScore;    // 0-100 total
    
    // Availability
    private Integer estimatedArrivalMinutes;
    private Boolean isOnline;
    private Long totalDonations;
    private String lastDonationDate;
    
    // Gamification
    private Integer totalPoints;
    private String badgeLevel;
}
