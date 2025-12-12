package com.lifeflow.request.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "blood_requests", indexes = {
    @Index(name = "idx_hospital_id", columnList = "hospital_id"),
    @Index(name = "idx_blood_type_needed", columnList = "blood_type_needed"),
    @Index(name = "idx_status", columnList = "status"),
    @Index(name = "idx_urgency_level", columnList = "urgency_level"),
    @Index(name = "idx_created_at", columnList = "created_at"),
    @Index(name = "idx_deadline_timestamp", columnList = "deadline_timestamp")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BloodRequest {

    @Id
    @Column(length = 50)
    private String requestId;

    @Column(nullable = false, length = 50)
    private String hospitalId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private BloodType bloodTypeNeeded;

    @Column(nullable = false)
    private Double unitsRequired;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private UrgencyLevel urgencyLevel;

    @Column(name = "urgency_numeric_score")
    private Integer urgencyNumericScore;

    @Column(name = "patient_age")
    private Integer patientAge;

    @Enumerated(EnumType.STRING)
    @Column(name = "patient_gender", length = 10)
    private Gender patientGender;

    @Column(name = "patient_condition", length = 500)
    private String patientCondition;

    @Column(length = 100)
    private String procedureType;

    @Column(name = "procedure_scheduled_time")
    private LocalDateTime procedureScheduledTime;

    @Column(name = "deadline_minutes")
    private Integer deadlineMinutes;

    @Column(name = "deadline_timestamp")
    private LocalDateTime deadlineTimestamp;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private RequestStatus status = RequestStatus.PENDING;

    @Column(name = "blood_bank_stock_checked")
    private Boolean bloodBankStockChecked = false;

    @Column(name = "donor_search_initiated")
    private Boolean donorSearchInitiated = false;

    @Column(name = "gps_location_hospital", length = 100)
    private String gpsLocationHospital;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "fulfilled_at")
    private LocalDateTime fulfilledAt;

    @Column(name = "cancelled_at")
    private LocalDateTime cancelledAt;

    @Column(name = "cancellation_reason", length = 500)
    private String cancellationReason;

    @Column(columnDefinition = "TEXT")
    private String notes;

    // Enums
    public enum BloodType {
        O_POSITIVE, O_NEGATIVE, A_POSITIVE, A_NEGATIVE,
        B_POSITIVE, B_NEGATIVE, AB_POSITIVE, AB_NEGATIVE
    }

    public enum UrgencyLevel {
        CRITICAL, HIGH, MEDIUM, LOW
    }

    public enum RequestStatus {
        PENDING, MATCHED, ACCEPTED, FULFILLED,
        PARTIAL_FULFILLED, CANCELLED, EXPIRED
    }

    public enum Gender {
        M, F, OTHER
    }

    // Methods
    public boolean isCritical() {
        return urgencyLevel == UrgencyLevel.CRITICAL;
    }

    public boolean isExpired() {
        return deadlineTimestamp != null && LocalDateTime.now().isAfter(deadlineTimestamp);
    }

    public int getRemainingMinutes() {
        if (deadlineTimestamp == null) return 0;
        return (int) ((deadlineTimestamp.getTime() - System.currentTimeMillis()) / 60000);
    }
}
