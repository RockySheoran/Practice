package com.lifeflow.request.dto;

import lombok.*;
import jakarta.validation.constraints.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateRequestDTO {

    @NotBlank(message = "Hospital ID is required")
    private String hospitalId;

    @NotBlank(message = "Blood type is required")
    @Pattern(regexp = "O_POSITIVE|O_NEGATIVE|A_POSITIVE|A_NEGATIVE|B_POSITIVE|B_NEGATIVE|AB_POSITIVE|AB_NEGATIVE",
             message = "Invalid blood type")
    private String bloodType;

    @NotNull(message = "Units required is mandatory")
    @DecimalMin(value = "0.1", message = "Units must be at least 0.1")
    private Double unitsRequired;

    @NotBlank(message = "Urgency level is required")
    @Pattern(regexp = "CRITICAL|HIGH|MEDIUM|LOW", message = "Invalid urgency level")
    private String urgencyLevel;

    @Min(value = 1, message = "Patient age must be positive")
    private Integer patientAge;

    private String patientCondition;

    @NotNull(message = "Deadline minutes is required")
    @Min(value = 5, message = "Minimum deadline is 5 minutes")
    @Max(value = 1440, message = "Maximum deadline is 1440 minutes (24 hours)")
    private Integer deadlineMinutes;

    private String gpsLocation;

    private String procedureType;
}
