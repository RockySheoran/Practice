package com.lifeflow.gateway.client;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * Service-to-Service Communication Client
 * Handles synchronous REST calls between microservices
 * Used when services need real-time data from other services
 * 
 * Examples:
 * 1. Blood Request Service calls Inventory Service to check stock
 * 2. Donor Service calls Geolocation Service to find nearby blood banks
 * 3. Request Service calls Notification Service to send alerts
 */
@Slf4j
@Component
public class ServiceToServiceClient {

    @Autowired
    private RestTemplate restTemplate;

    // Service URLs (Docker Compose internal network)
    private static final String IDENTITY_SERVICE_URL = "http://identity-service:8001";
    private static final String DONOR_SERVICE_URL = "http://donor-service:8002";
    private static final String INVENTORY_SERVICE_URL = "http://inventory-service:8003";
    private static final String REQUEST_SERVICE_URL = "http://request-service:8004";
    private static final String GEOLOCATION_SERVICE_URL = "http://geolocation-service:8005";
    private static final String NOTIFICATION_SERVICE_URL = "http://notification-service:8006";
    private static final String CAMP_SERVICE_URL = "http://camp-service:8007";
    private static final String ANALYTICS_SERVICE_URL = "http://analytics-service:8008";

    // ===== INVENTORY SERVICE CALLS =====
    
    /**
     * Check blood availability in inventory
     * Called by: Request Service, Camp Service
     */
    public BloodStockResponse checkBloodStock(String bloodType) {
        try {
            String url = UriComponentsBuilder.fromHttpUrl(INVENTORY_SERVICE_URL)
                .path("/api/internal/inventory/check-stock")
                .queryParam("bloodType", bloodType)
                .toUriString();

            ResponseEntity<BloodStockResponse> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                createServiceHeaders(),
                BloodStockResponse.class
            );

            return response.getBody();
        } catch (Exception e) {
            log.error("Error checking blood stock: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Reserve blood bags for a request
     * Called by: Request Service
     * 
     * @param requestId Blood request ID
     * @param bloodType Blood type to reserve
     * @param quantity Number of units
     */
    public ReservationResponse reserveBlood(String requestId, String bloodType, Integer quantity) {
        try {
            String url = INVENTORY_SERVICE_URL + "/api/internal/inventory/reserve";
            
            ReservationRequest request = new ReservationRequest();
            request.setRequestId(requestId);
            request.setBloodType(bloodType);
            request.setQuantity(quantity);

            HttpEntity<ReservationRequest> entity = new HttpEntity<>(request, createServiceHeaders());
            ResponseEntity<ReservationResponse> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                entity,
                ReservationResponse.class
            );

            return response.getBody();
        } catch (Exception e) {
            log.error("Error reserving blood: {}", e.getMessage());
            return null;
        }
    }

    // ===== DONOR SERVICE CALLS =====
    
    /**
     * Get donor medical history and eligibility
     * Called by: Request Service, Identity Service
     */
    public DonorEligibilityResponse checkDonorEligibility(String donorId) {
        try {
            String url = DONOR_SERVICE_URL + "/api/internal/donors/" + donorId + "/eligibility";

            ResponseEntity<DonorEligibilityResponse> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                createServiceHeaders(),
                DonorEligibilityResponse.class
            );

            return response.getBody();
        } catch (Exception e) {
            log.error("Error checking donor eligibility: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Get donor contact information
     * Called by: Notification Service
     */
    public DonorContactResponse getDonorContact(String donorId) {
        try {
            String url = DONOR_SERVICE_URL + "/api/internal/donors/" + donorId + "/contact";

            ResponseEntity<DonorContactResponse> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                createServiceHeaders(),
                DonorContactResponse.class
            );

            return response.getBody();
        } catch (Exception e) {
            log.error("Error getting donor contact: {}", e.getMessage());
            return null;
        }
    }

    // ===== GEOLOCATION SERVICE CALLS =====
    
    /**
     * Calculate distance between two locations
     * Called by: Request Service, Camp Service
     */
    public DistanceResponse calculateDistance(String fromLocation, String toLocation) {
        try {
            String url = UriComponentsBuilder.fromHttpUrl(GEOLOCATION_SERVICE_URL)
                .path("/api/internal/distance")
                .queryParam("from", fromLocation)
                .queryParam("to", toLocation)
                .toUriString();

            ResponseEntity<DistanceResponse> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                createServiceHeaders(),
                DistanceResponse.class
            );

            return response.getBody();
        } catch (Exception e) {
            log.error("Error calculating distance: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Find nearby blood banks
     * Called by: Request Service, Donor Service
     */
    public NearbyLocationsResponse findNearbyBloodBanks(Double latitude, Double longitude, Integer radiusKm) {
        try {
            String url = UriComponentsBuilder.fromHttpUrl(GEOLOCATION_SERVICE_URL)
                .path("/api/internal/locations/nearby")
                .queryParam("lat", latitude)
                .queryParam("lon", longitude)
                .queryParam("radius", radiusKm)
                .queryParam("type", "BLOOD_BANK")
                .toUriString();

            ResponseEntity<NearbyLocationsResponse> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                createServiceHeaders(),
                NearbyLocationsResponse.class
            );

            return response.getBody();
        } catch (Exception e) {
            log.error("Error finding nearby blood banks: {}", e.getMessage());
            return null;
        }
    }

    // ===== NOTIFICATION SERVICE CALLS =====
    
    /**
     * Send notification to donor
     * Called by: Request Service, Camp Service, Analytics Service
     */
    public NotificationResponse sendNotification(String userId, NotificationRequest notificationRequest) {
        try {
            String url = NOTIFICATION_SERVICE_URL + "/api/internal/notifications/send";

            HttpEntity<NotificationRequest> entity = new HttpEntity<>(notificationRequest, createServiceHeaders());
            ResponseEntity<NotificationResponse> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                entity,
                NotificationResponse.class
            );

            return response.getBody();
        } catch (Exception e) {
            log.error("Error sending notification: {}", e.getMessage());
            return null;
        }
    }

    // ===== ANALYTICS SERVICE CALLS =====
    
    /**
     * Record donation for analytics
     * Called by: Donor Service, Request Service
     */
    public void recordDonation(String donorId, DonationAnalyticsRequest request) {
        try {
            String url = ANALYTICS_SERVICE_URL + "/api/internal/analytics/donations/record";

            HttpEntity<DonationAnalyticsRequest> entity = new HttpEntity<>(request, createServiceHeaders());
            restTemplate.exchange(
                url,
                HttpMethod.POST,
                entity,
                Void.class
            );
        } catch (Exception e) {
            log.error("Error recording donation: {}", e.getMessage());
        }
    }

    /**
     * Update donor reward points
     * Called by: Donor Service
     */
    public void updateRewardPoints(String donorId, Integer points) {
        try {
            String url = ANALYTICS_SERVICE_URL + "/api/internal/analytics/rewards/update";

            RewardUpdateRequest request = new RewardUpdateRequest();
            request.setDonorId(donorId);
            request.setPoints(points);

            HttpEntity<RewardUpdateRequest> entity = new HttpEntity<>(request, createServiceHeaders());
            restTemplate.exchange(
                url,
                HttpMethod.POST,
                entity,
                Void.class
            );
        } catch (Exception e) {
            log.error("Error updating reward points: {}", e.getMessage());
        }
    }

    // ===== IDENTITY SERVICE CALLS =====
    
    /**
     * Validate user role for authorization
     * Called by: All services (for role-based access control)
     */
    public UserAuthResponse validateUserRole(String userId, String requiredRole) {
        try {
            String url = UriComponentsBuilder.fromHttpUrl(IDENTITY_SERVICE_URL)
                .path("/api/internal/auth/validate-role")
                .queryParam("userId", userId)
                .queryParam("role", requiredRole)
                .toUriString();

            ResponseEntity<UserAuthResponse> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                createServiceHeaders(),
                UserAuthResponse.class
            );

            return response.getBody();
        } catch (Exception e) {
            log.error("Error validating user role: {}", e.getMessage());
            return null;
        }
    }

    // ===== HELPER METHODS =====

    /**
     * Create HTTP headers for internal service-to-service communication
     * Includes correlation ID for distributed tracing
     */
    private HttpEntity<?> createServiceHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Internal-Call", "true");
        headers.set("X-Service-Name", "API-GATEWAY");
        headers.set("Content-Type", "application/json");
        // In production, add service authentication token here
        // headers.set("X-Service-Token", serviceToken);
        return new HttpEntity<>(headers);
    }

    private HttpEntity<Void> createServiceHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Internal-Call", "true");
        headers.set("X-Service-Name", "API-GATEWAY");
        headers.set("Content-Type", "application/json");
        return new HttpEntity<>(headers);
    }

    // ===== DTO CLASSES FOR REQUESTS/RESPONSES =====

    @Data
    public static class BloodStockResponse {
        private String bloodType;
        private Integer availableUnits;
        private String expiryDate;
        private Boolean available;
    }

    @Data
    public static class ReservationRequest {
        private String requestId;
        private String bloodType;
        private Integer quantity;
    }

    @Data
    public static class ReservationResponse {
        private Boolean success;
        private String reservationId;
        private String message;
    }

    @Data
    public static class DonorEligibilityResponse {
        private String donorId;
        private Boolean eligible;
        private String reason;
        private String nextEligibleDate;
    }

    @Data
    public static class DonorContactResponse {
        private String donorId;
        private String phone;
        private String email;
        private String emergencyContact;
    }

    @Data
    public static class DistanceResponse {
        private Double distanceKm;
        private Integer durationMinutes;
        private String route;
    }

    @Data
    public static class NearbyLocationsResponse {
        private java.util.List<LocationInfo> locations;
        
        @Data
        public static class LocationInfo {
            private String id;
            private String name;
            private Double latitude;
            private Double longitude;
            private Double distanceKm;
        }
    }

    @Data
    public static class NotificationRequest {
        private String userId;
        private String type; // SMS, EMAIL, PUSH
        private String subject;
        private String message;
    }

    @Data
    public static class NotificationResponse {
        private Boolean success;
        private String notificationId;
    }

    @Data
    public static class DonationAnalyticsRequest {
        private String donorId;
        private String bloodType;
        private String donationDate;
        private Integer units;
    }

    @Data
    public static class RewardUpdateRequest {
        private String donorId;
        private Integer points;
    }

    @Data
    public static class UserAuthResponse {
        private Boolean authorized;
        private String userId;
    }
}
