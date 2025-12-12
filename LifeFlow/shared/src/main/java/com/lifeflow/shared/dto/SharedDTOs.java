package com.lifeflow.shared.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.time.LocalDate;

/**
 * SHARED DTOs - Used across multiple microservices
 * These define the contract for inter-service communication
 * 
 * Versioning: All DTOs should have @version annotation
 * When changing DTO, increment version and create migration
 */

// ===== USER/IDENTITY DTOs =====

/**
 * User DTO - Shared across ALL services
 * Identity Service owns this entity
 * Other services reference via userId
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    private String userId;
    private String email;
    private String username;
    private String phone;
    private String role;                    // ADMIN, DONOR, HOSPITAL, BLOOD_BANK
    private String userType;                // Same as role
    private String firstName;
    private String lastName;
    private Boolean active;
    private Boolean verified;
    private LocalDateTime createdAt;
    private LocalDateTime lastLogin;
    private String status;                  // PENDING, ACTIVE, SUSPENDED, DEACTIVATED
}

/**
 * User Authentication Response
 * Returned by Identity Service after login
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponseDTO {
    private String token;                   // JWT token
    private String userId;
    private String email;
    private String role;
    private String userType;
    private Long expiresIn;                 // In milliseconds (86400000 = 24 hours)
    private LocalDateTime expiresAt;
}

// ===== DONOR DTOs =====

/**
 * Donor DTO - Owned by Donor Service
 * Referenced by: Request Service, Camp Service, Analytics Service
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DonorDTO {
    private String donorId;
    private String userId;                  // ← Reference to User
    private String firstName;
    private String lastName;
    private String bloodType;               // A+, A-, B+, B-, AB+, AB-, O+, O-
    private LocalDate dateOfBirth;
    private String gender;                  // M/F/Other
    private String phone;
    private String email;
    private String address;
    private Double weight;                  // in kg
    private Boolean eligible;               // Is donor eligible to donate now?
    private LocalDateTime lastDonationDate;
    private Integer totalDonations;
    private String verificationStatus;      // PENDING, VERIFIED, REJECTED
    private LocalDateTime createdAt;
}

/**
 * Donor Eligibility Check
 * Returned by Donor Service when Request Service asks
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DonorEligibilityDTO {
    private String donorId;
    private Boolean eligible;
    private String reason;                  // If not eligible, why?
    private LocalDate nextEligibleDate;     // When can they donate again?
    private String bloodType;
    private String lastCheckAt;
}

/**
 * Donor Medical History
 * Private - only accessible to Donor Service and authorized personnel
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MedicalHistoryDTO {
    private String historyId;
    private String donorId;
    private Boolean hasChronicDisease;
    private Boolean onMedication;
    private String medications;
    private Boolean recentVaccine;
    private LocalDate vaccineDate;
    private Boolean previousBloodTransfusion;
    private String allergies;
    private String notes;
    private LocalDateTime lastCheckedAt;
}

// ===== BLOOD INVENTORY DTOs =====

/**
 * Blood Bag DTO - Owned by Inventory Service
 * Referenced by: Request Service, Geolocation Service, Notification Service
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BloodBagDTO {
    private String bagId;                   // Unique identifier
    private String bloodType;               // A+, B-, O+, AB-
    private String bloodBankId;             // Which bank has this bag
    private LocalDateTime collectedDate;
    private LocalDateTime expiryDate;
    private String status;                  // AVAILABLE, RESERVED, IN_USE, EXPIRED, DISPOSED
    private Integer quantity;               // Units (typically 450ml)
    private String location;                // Which fridge/storage location
    private String donorId;                 // Who donated this
    private String collectionCenter;
    private String testStatus;              // NOT_TESTED, PASSED, FAILED
    private LocalDateTime testedAt;
}

/**
 * Blood Stock Summary
 * Returned by Inventory Service for queries
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BloodStockDTO {
    private String bloodType;
    private Integer availableUnits;
    private Integer reservedUnits;
    private Integer inUseUnits;
    private Integer totalUnits;
    private LocalDateTime lastUpdated;
    private String nextScheduledDrive;
    private Integer daysUntilCritical;
}

/**
 * Blood Bank Location
 * Owned by Inventory Service
 * Referenced by: Geolocation Service, Request Service
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BloodBankDTO {
    private String bloodBankId;
    private String name;
    private String address;
    private Double latitude;
    private Double longitude;
    private String phone;
    private String email;
    private String managerId;               // User ID of manager
    private String operatingHours;
    private Boolean available24x7;
    private Integer capacity;               // Max bags storage
    private String status;                  // ACTIVE, INACTIVE, CLOSED
}

// ===== BLOOD REQUEST DTOs =====

/**
 * Blood Request DTO - Owned by Request Service
 * Referenced by: Inventory Service, Geolocation Service, Notification Service, Analytics Service
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BloodRequestDTO {
    private String requestId;
    private String requestingUserId;        // Hospital/doctor who requested
    private String bloodType;
    private Integer unitsNeeded;
    private String hospitalId;              // Which hospital
    private String patientName;
    private String patientAge;
    private String patientCondition;        // Surgery, trauma, bleeding, etc.
    private LocalDateTime requestDate;
    private String urgency;                 // ROUTINE, URGENT, EMERGENCY
    private String status;                  // PENDING, MATCHED, FULFILLED, CANCELLED, EXPIRED
    private LocalDateTime targetDeliveryTime;
    private String deliveryAddress;
    private Integer deliveryContactPhone;
    private LocalDateTime fulfilledAt;
    private String fulfilledByBagId;        // Which blood bag was used
}

/**
 * Blood Request Fulfillment
 * Record of what happened to request
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BloodRequestFulfillmentDTO {
    private String fulfillmentId;
    private String requestId;
    private String bloodBagId;
    private String sourceBloodBank;
    private String transportId;             // How it was transported
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
    private Integer unitsDelivered;
    private String status;                  // IN_TRANSIT, DELIVERED, FAILED
    private String notes;
}

// ===== TRANSPORT/LOGISTICS DTOs =====

/**
 * Transport DTO - Owned by Geolocation Service
 * Tracks how blood is transported from bank to hospital
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransportDTO {
    private String transportId;
    private String requestId;               // ← Links to blood request
    private String vehicleId;
    private String driverId;                // User ID
    private String driverName;
    private String driverPhone;
    private Double currentLatitude;
    private Double currentLongitude;
    private String currentLocation;
    private Double destinationLatitude;
    private Double destinationLongitude;
    private String destinationAddress;
    private LocalDateTime startTime;
    private LocalDateTime estimatedArrival;
    private LocalDateTime actualArrival;
    private String status;                  // PENDING, IN_TRANSIT, ARRIVED, DELIVERED, FAILED
    private Double distanceKm;
    private Integer durationMinutes;
    private String temperature;             // Current temperature of blood
    private String temperatureAlert;        // If temperature out of range
}

/**
 * Location DTO
 * Used by Geolocation Service to store locations
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LocationDTO {
    private String locationId;
    private String name;                    // Blood bank, hospital, donor, etc.
    private Double latitude;
    private Double longitude;
    private String address;
    private String type;                    // BLOOD_BANK, HOSPITAL, DONOR_HOME, CAMP
    private String phone;
    private String contactPerson;
    private String status;                  // ACTIVE, INACTIVE
}

// ===== NOTIFICATION DTOs =====

/**
 * Notification DTO - Owned by Notification Service
 * Created by other services when they need to notify users
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDTO {
    private String notificationId;
    private String userId;                  // ← Who to notify
    private String type;                    // SMS, EMAIL, PUSH, WHATSAPP, IN_APP
    private String subject;
    private String message;
    private String status;                  // PENDING, SENT, FAILED, DELIVERED
    private LocalDateTime createdAt;
    private LocalDateTime sentAt;
    private String failureReason;           // If failed, why?
    private Integer retryCount;
}

/**
 * Notification Preference DTO
 * How user wants to be notified
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationPreferenceDTO {
    private String preferenceId;
    private String userId;
    private Boolean emailNotifications;
    private Boolean smsNotifications;
    private Boolean pushNotifications;
    private Boolean whatsappNotifications;
    private Boolean bloodRequestAlerts;
    private Boolean donationReminders;
    private Boolean campNotifications;
    private String quietHoursStart;         // Time in HH:mm format
    private String quietHoursEnd;
}

// ===== CAMP DTOs =====

/**
 * Camp DTO - Owned by Camp Service
 * Blood donation camps (drives)
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CampDTO {
    private String campId;
    private String name;
    private String location;
    private Double latitude;
    private Double longitude;
    private LocalDate campDate;
    private String startTime;               // HH:mm
    private String endTime;                 // HH:mm
    private String organizerId;             // User ID
    private String organizerName;
    private String description;
    private Integer expectedDonors;
    private String status;                  // PLANNED, ONGOING, COMPLETED, CANCELLED
    private Integer actualDonors;
    private Integer successfulDonations;
    private String contactPhone;
}

/**
 * Camp Registration DTO
 * Who is registered for which camp
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CampRegistrationDTO {
    private String registrationId;
    private String campId;
    private String donorId;
    private LocalDateTime registeredAt;
    private String status;                  // REGISTERED, ATTENDED, DONATED, NO_SHOW
    private LocalDateTime attendedAt;
    private String notes;
}

// ===== ANALYTICS DTOs =====

/**
 * Donor Reward DTO - Owned by Analytics Service
 * Tracks reward points for donors
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DonorRewardDTO {
    private String rewardId;
    private String donorId;
    private Integer points;                 // Total reward points
    private Integer level;                  // 1: Bronze, 2: Silver, 3: Gold, 4: Platinum
    private LocalDateTime lastPointsEarned;
    private String badge;                   // Current badge
    private Integer donationCount;          // Total donations
    private LocalDateTime createdAt;
}

/**
 * Donation Analytics Record
 * For tracking and analysis
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DonationAnalyticsDTO {
    private String analyticsId;
    private String donorId;
    private String donationDate;
    private String bloodType;
    private Integer units;
    private String campName;
    private String bloodBankId;
    private Integer pointsAwarded;
    private String status;                  // SUCCESS, FAILURE
}

/**
 * Blood Request Analytics
 * For tracking requests and fulfillment
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RequestAnalyticsDTO {
    private String analyticsId;
    private String requestId;
    private String urgency;                 // ROUTINE, URGENT, EMERGENCY
    private String bloodType;
    private Integer unitsRequested;
    private LocalDateTime requestedAt;
    private LocalDateTime fulfilledAt;
    private Integer fulfillmentTimeMinutes;
    private String status;                  // FULFILLED, TIMEOUT, CANCELLED
    private String region;
}

// ===== ERROR/RESPONSE DTOs =====

/**
 * Standard API Response
 * All endpoints should return this format
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponseDTO<T> {
    private Boolean success;
    private String message;
    private T data;
    private Integer statusCode;
    private LocalDateTime timestamp;
    private String correlationId;           // For distributed tracing
}

/**
 * Error Response
 * Standard error format
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ErrorResponseDTO {
    private String error;
    private String message;
    private Integer statusCode;
    private String path;
    private LocalDateTime timestamp;
    private String correlationId;
}

// ===== EVENT DTOs =====

/**
 * Base Event DTO
 * All events should extend this
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BaseEventDTO {
    private String eventId;
    private String eventType;
    private String source;                  // Which service published this
    private LocalDateTime timestamp;
    private String correlationId;           // For tracing related events
}

/**
 * Blood Donated Event DTO
 * Published when donation is recorded
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BloodDonatedEventDTO extends BaseEventDTO {
    private String donorId;
    private String bloodType;
    private Integer units;
    private String bloodBankId;
    private String campId;
    private LocalDateTime donationDate;
}
