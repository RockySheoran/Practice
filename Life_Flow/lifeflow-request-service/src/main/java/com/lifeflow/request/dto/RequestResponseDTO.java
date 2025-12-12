package com.lifeflow.request.dto;

import com.lifeflow.request.entity.BloodRequest;
import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RequestResponseDTO {

    private String requestId;
    private String hospitalId;
    private String bloodType;
    private Double unitsRequired;
    private String urgencyLevel;
    private String patientCondition;
    private String status;
    private LocalDateTime deadlineTimestamp;
    private Integer remainingMinutes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer matchedDonorsCount;

    public static RequestResponseDTO fromEntity(BloodRequest request) {
        return RequestResponseDTO.builder()
                .requestId(request.getRequestId())
                .hospitalId(request.getHospitalId())
                .bloodType(request.getBloodTypeNeeded().toString())
                .unitsRequired(request.getUnitsRequired())
                .urgencyLevel(request.getUrgencyLevel().toString())
                .patientCondition(request.getPatientCondition())
                .status(request.getStatus().toString())
                .deadlineTimestamp(request.getDeadlineTimestamp())
                .remainingMinutes(request.getRemainingMinutes())
                .createdAt(request.getCreatedAt())
                .updatedAt(request.getUpdatedAt())
                .build();
    }
}
