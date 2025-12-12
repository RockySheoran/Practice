package com.lifeflow.request.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "request_responses", indexes = {
    @Index(name = "idx_request_id", columnList = "request_id"),
    @Index(name = "idx_donor_id", columnList = "donor_id"),
    @Index(name = "idx_hospital_id", columnList = "hospital_id"),
    @Index(name = "idx_response_status", columnList = "response_status")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RequestResponse {

    @Id
    @Column(length = 50)
    private String responseId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "request_id", nullable = false)
    private BloodRequest request;

    @Column(name = "donor_id", nullable = false, length = 50)
    private String donorId;

    @Column(name = "hospital_id", nullable = false, length = 50)
    private String hospitalId;

    @Enumerated(EnumType.STRING)
    @Column(name = "response_status", nullable = false, length = 30)
    private ResponseStatus responseStatus = ResponseStatus.PENDING;

    @Column(name = "donor_can_arrive_in_minutes")
    private Integer donorCanArriveInMinutes;

    @Column(name = "scheduled_pickup_time")
    private LocalDateTime scheduledPickupTime;

    @Column(name = "actual_pickup_time")
    private LocalDateTime actualPickupTime;

    @Column(name = "confirmed_by_donor_at")
    private LocalDateTime confirmedByDonorAt;

    @Column(name = "confirmation_code", length = 50)
    private String confirmationCode;

    @Column(name = "confirmation_otp", length = 10)
    private String confirmationOtp;

    @Column(name = "donor_arrival_at_center")
    private LocalDateTime donorArrivalAtCenter;

    @Column(name = "collection_completed_at")
    private LocalDateTime collectionCompletedAt;

    @Column(name = "rejection_reason", length = 500)
    private String rejectionReason;

    @CreationTimestamp
    @Column(name = "response_created_at", nullable = false, updatable = false)
    private LocalDateTime responseCreatedAt;

    @UpdateTimestamp
    @Column(name = "response_updated_at", nullable = false)
    private LocalDateTime responseUpdatedAt;

    @Column(name = "points_offered")
    private Integer pointsOffered = 100;

    @Column(name = "points_claimed_at")
    private LocalDateTime pointsClaimedAt;

    @Column(name = "blood_bag_assigned_id", length = 100)
    private String bloodBagAssignedId;

    @Column(name = "matched_score")
    private Integer matchedScore;

    public enum ResponseStatus {
        PENDING, ACCEPTED, REJECTED, NO_RESPONSE, CANCELLED
    }

    public boolean isAccepted() {
        return responseStatus == ResponseStatus.ACCEPTED;
    }

    public boolean isPending() {
        return responseStatus == ResponseStatus.PENDING;
    }
}
