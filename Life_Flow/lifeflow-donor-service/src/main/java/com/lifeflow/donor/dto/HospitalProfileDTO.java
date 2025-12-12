package com.lifeflow.donor.dto;

import com.lifeflow.donor.entity.HospitalProfile;
import lombok.*;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HospitalProfileDTO {

    private String hospitalId;
    private String userId;
    private String hospitalName;
    private String address;
    private String city;
    private String state;
    private String pincode;
    private String contactPhone;
    private String emergencyContact;
    private Integer bloodBankCapacity;
    private LocalTime operatingHoursStart;
    private LocalTime operatingHoursEnd;
    private Double latitude;
    private Double longitude;
    private String website;
    private String description;
    private String status;
    private Boolean registrationVerified;
    private LocalDateTime verifiedAt;
    private LocalDateTime createdAt;

    public static HospitalProfileDTO fromEntity(HospitalProfile hospital) {
        return HospitalProfileDTO.builder()
                .hospitalId(hospital.getHospitalId())
                .userId(hospital.getUserId())
                .hospitalName(hospital.getHospitalName())
                .address(hospital.getAddress())
                .city(hospital.getCity())
                .state(hospital.getState())
                .pincode(hospital.getPincode())
                .contactPhone(hospital.getContactPhone())
                .emergencyContact(hospital.getEmergencyContact())
                .bloodBankCapacity(hospital.getBloodBankCapacity())
                .operatingHoursStart(hospital.getOperatingHoursStart())
                .operatingHoursEnd(hospital.getOperatingHoursEnd())
                .latitude(hospital.getLatitude())
                .longitude(hospital.getLongitude())
                .website(hospital.getWebsite())
                .description(hospital.getDescription())
                .status(hospital.getStatus().toString())
                .registrationVerified(hospital.getRegistrationVerified())
                .verifiedAt(hospital.getVerifiedAt())
                .createdAt(hospital.getCreatedAt())
                .build();
    }
}
