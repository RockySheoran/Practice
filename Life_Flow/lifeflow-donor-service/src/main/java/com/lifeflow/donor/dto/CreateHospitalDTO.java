package com.lifeflow.donor.dto;

import lombok.*;
import jakarta.validation.constraints.*;
import java.time.LocalTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateHospitalDTO {

    @NotBlank(message = "User ID is required")
    private String userId;

    @NotBlank(message = "Hospital name is required")
    @Size(min = 3, max = 200, message = "Hospital name must be between 3-200 characters")
    private String hospitalName;

    @NotBlank(message = "Address is required")
    private String address;

    @NotBlank(message = "City is required")
    private String city;

    @NotBlank(message = "State is required")
    private String state;

    @NotBlank(message = "Pincode is required")
    @Pattern(regexp = "\\d{5,10}", message = "Invalid pincode")
    private String pincode;

    @NotBlank(message = "Contact phone is required")
    @Pattern(regexp = "\\+?\\d{10,15}", message = "Invalid phone number")
    private String contactPhone;

    @Pattern(regexp = "\\+?\\d{10,15}", message = "Invalid emergency contact")
    private String emergencyContact;

    @NotNull(message = "Blood bank capacity is required")
    @Positive(message = "Blood bank capacity must be positive")
    private Integer bloodBankCapacity;

    @NotNull(message = "Operating hours start is required")
    private LocalTime operatingHoursStart;

    @NotNull(message = "Operating hours end is required")
    private LocalTime operatingHoursEnd;

    @NotNull(message = "Latitude is required")
    @DecimalMin(value = "-90.0", message = "Invalid latitude")
    @DecimalMax(value = "90.0", message = "Invalid latitude")
    private Double latitude;

    @NotNull(message = "Longitude is required")
    @DecimalMin(value = "-180.0", message = "Invalid longitude")
    @DecimalMax(value = "180.0", message = "Invalid longitude")
    private Double longitude;

    private String website;
    private String description;
}
