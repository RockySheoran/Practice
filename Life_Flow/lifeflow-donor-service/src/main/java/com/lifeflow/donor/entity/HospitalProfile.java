package com.lifeflow.donor.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "hospital_profiles", indexes = {
    @Index(name = "idx_user_id", columnList = "user_id"),
    @Index(name = "idx_hospital_name", columnList = "hospital_name"),
    @Index(name = "idx_city", columnList = "city"),
    @Index(name = "idx_status", columnList = "status")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HospitalProfile {

    @Id
    @Column(length = 50)
    private String hospitalId;

    @Column(name = "user_id", nullable = false, unique = true, length = 50)
    private String userId;

    @Column(name = "hospital_name", nullable = false, length = 200)
    private String hospitalName;

    @Column(columnDefinition = "TEXT")
    private String address;

    @Column(length = 50)
    private String city;

    @Column(length = 50)
    private String state;

    @Column(length = 10)
    private String pincode;

    @Column(name = "contact_phone", length = 20)
    private String contactPhone;

    @Column(name = "emergency_contact", length = 20)
    private String emergencyContact;

    @Column(name = "blood_bank_capacity")
    private Integer bloodBankCapacity;

    @Column(name = "operating_hours_start")
    private LocalTime operatingHoursStart;

    @Column(name = "operating_hours_end")
    private LocalTime operatingHoursEnd;

    @Column(name = "latitude", precision = 10, scale = 8)
    private Double latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private Double longitude;

    @Column(length = 100)
    private String website;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private HospitalStatus status = HospitalStatus.ACTIVE;

    @Column(name = "email_verified")
    private Boolean emailVerified = false;

    @Column(name = "phone_verified")
    private Boolean phoneVerified = false;

    @Column(name = "registration_verified")
    private Boolean registrationVerified = false;

    @Column(name = "verified_by_admin", length = 50)
    private String verifiedByAdmin;

    @Column(name = "verified_at")
    private LocalDateTime verifiedAt;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public enum HospitalStatus {
        ACTIVE, INACTIVE, PENDING_VERIFICATION, SUSPENDED, CLOSED
    }

    public boolean isOperatingNow() {
        LocalTime now = LocalTime.now();
        if (operatingHoursStart == null || operatingHoursEnd == null) {
            return true;
        }
        return now.isAfter(operatingHoursStart) && now.isBefore(operatingHoursEnd);
    }

    public double calculateDistance(double latitude, double longitude) {
        if (this.latitude == null || this.longitude == null) {
            return Double.MAX_VALUE;
        }
        
        double lat1Rad = Math.toRadians(this.latitude);
        double lat2Rad = Math.toRadians(latitude);
        double deltaLat = Math.toRadians(latitude - this.latitude);
        double deltaLon = Math.toRadians(longitude - this.longitude);

        double a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
                   Math.cos(lat1Rad) * Math.cos(lat2Rad) *
                   Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double R = 6371; // Earth's radius in km

        return R * c;
    }
}
