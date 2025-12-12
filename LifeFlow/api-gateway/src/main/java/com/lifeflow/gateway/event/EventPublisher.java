package com.lifeflow.gateway.event;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.core.AmqpTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Event Publisher for Asynchronous Communication
 * Uses RabbitMQ to publish events to other services
 * Services subscribe to events they care about
 * 
 * Benefits of async communication:
 * 1. Services don't need to wait for responses
 * 2. Better scalability and resilience
 * 3. Decouples services - easier to add/remove services
 * 4. Natural event propagation across system
 */
@Slf4j
@Component
public class EventPublisher {

    @Autowired
    private AmqpTemplate amqpTemplate;

    @Autowired
    private ObjectMapper objectMapper;

    // RabbitMQ topic exchange
    private static final String EXCHANGE = "lifeflow-exchange";

    // Event routing keys (topics)
    public static class EventTopics {
        public static final String USER_REGISTERED = "event.user.registered";
        public static final String USER_VERIFIED = "event.user.verified";
        public static final String DONOR_REGISTERED = "event.donor.registered";
        public static final String BLOOD_DONATED = "event.blood.donated";
        public static final String DONATION_COMPLETED = "event.donation.completed";
        public static final String BLOOD_REQUESTED = "event.blood.requested";
        public static final String BLOOD_REQUEST_FULFILLED = "event.blood.request.fulfilled";
        public static final String BLOOD_REQUEST_CANCELLED = "event.blood.request.cancelled";
        public static final String BLOOD_RESERVED = "event.blood.reserved";
        public static final String BLOOD_RELEASED = "event.blood.released";
        public static final String STOCK_LOW = "event.stock.low";
        public static final String BLOOD_EXPIRED = "event.blood.expired";
        public static final String TRANSPORT_STARTED = "event.transport.started";
        public static final String TRANSPORT_COMPLETED = "event.transport.completed";
        public static final String CAMP_CREATED = "event.camp.created";
        public static final String CAMP_REGISTRATION = "event.camp.registration";
        public static final String CAMP_COMPLETED = "event.camp.completed";
        public static final String EMERGENCY_REQUEST = "event.emergency.request";
    }

    // ===== USER EVENTS =====

    /**
     * Publish when new user registers
     * Consumed by: Donor Service, Analytics Service
     */
    public void publishUserRegistered(String userId, String email, String userType) {
        UserRegisteredEvent event = new UserRegisteredEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setUserId(userId);
        event.setEmail(email);
        event.setUserType(userType); // donor, hospital, admin
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.USER_REGISTERED, event);
    }

    /**
     * Publish when user verification is complete
     * Consumed by: Donor Service
     */
    public void publishUserVerified(String userId) {
        BaseEvent event = new BaseEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setUserId(userId);
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.USER_VERIFIED, event);
    }

    // ===== DONOR EVENTS =====

    /**
     * Publish when donor profile is registered
     * Consumed by: Analytics Service, Notification Service
     */
    public void publishDonorRegistered(String donorId, String userId, String bloodType) {
        DonorRegisteredEvent event = new DonorRegisteredEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setDonorId(donorId);
        event.setUserId(userId);
        event.setBloodType(bloodType);
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.DONOR_REGISTERED, event);
    }

    // ===== DONATION EVENTS =====

    /**
     * Publish when blood is donated
     * Consumed by: Inventory Service, Analytics Service, Notification Service
     */
    public void publishBloodDonated(String donorId, String bloodType, Integer units, String bloodBankId) {
        BloodDonatedEvent event = new BloodDonatedEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setDonorId(donorId);
        event.setBloodType(bloodType);
        event.setUnits(units);
        event.setBloodBankId(bloodBankId);
        event.setDonationDate(LocalDateTime.now());
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.BLOOD_DONATED, event);
    }

    /**
     * Publish when donation process completes
     * Consumed by: Notification Service, Analytics Service
     */
    public void publishDonationCompleted(String donorId, String donationId, String status) {
        DonationCompletedEvent event = new DonationCompletedEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setDonorId(donorId);
        event.setDonationId(donationId);
        event.setStatus(status);
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.DONATION_COMPLETED, event);
    }

    // ===== BLOOD REQUEST EVENTS =====

    /**
     * Publish when blood request is created
     * Consumed by: Inventory Service, Notification Service, Analytics Service
     */
    public void publishBloodRequested(String requestId, String bloodType, Integer units, String hospitalId) {
        BloodRequestedEvent event = new BloodRequestedEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setRequestId(requestId);
        event.setBloodType(bloodType);
        event.setUnits(units);
        event.setHospitalId(hospitalId);
        event.setIsEmergency(false);
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.BLOOD_REQUESTED, event);
    }

    /**
     * Publish emergency blood request (HIGH PRIORITY)
     * Consumed by: ALL SERVICES - requires immediate action
     */
    public void publishEmergencyRequest(String requestId, String bloodType, Integer units, 
                                       String hospitalId, String patientName) {
        EmergencyRequestEvent event = new EmergencyRequestEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setRequestId(requestId);
        event.setBloodType(bloodType);
        event.setUnits(units);
        event.setHospitalId(hospitalId);
        event.setPatientName(patientName);
        event.setIsEmergency(true);
        event.setPriority("CRITICAL");
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.EMERGENCY_REQUEST, event);
        log.warn("EMERGENCY REQUEST PUBLISHED: {} - {}", requestId, bloodType);
    }

    /**
     * Publish when blood request is fulfilled
     * Consumed by: Hospital Service, Analytics Service, Notification Service
     */
    public void publishBloodRequestFulfilled(String requestId, String bloodBagId, Integer units) {
        BloodRequestFulfilledEvent event = new BloodRequestFulfilledEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setRequestId(requestId);
        event.setBloodBagId(bloodBagId);
        event.setUnits(units);
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.BLOOD_REQUEST_FULFILLED, event);
    }

    /**
     * Publish when blood request is cancelled
     * Consumed by: Inventory Service, Analytics Service
     */
    public void publishBloodRequestCancelled(String requestId, String reason) {
        BloodRequestCancelledEvent event = new BloodRequestCancelledEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setRequestId(requestId);
        event.setReason(reason);
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.BLOOD_REQUEST_CANCELLED, event);
    }

    // ===== INVENTORY EVENTS =====

    /**
     * Publish when blood is reserved
     * Consumed by: Inventory Service (to update stock)
     */
    public void publishBloodReserved(String bloodBagId, String requestId) {
        BloodReservedEvent event = new BloodReservedEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setBloodBagId(bloodBagId);
        event.setRequestId(requestId);
        event.setReservedAt(LocalDateTime.now());
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.BLOOD_RESERVED, event);
    }

    /**
     * Publish when blood is released from reservation
     * Consumed by: Inventory Service (to restore stock)
     */
    public void publishBloodReleased(String bloodBagId) {
        BloodReleasedEvent event = new BloodReleasedEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setBloodBagId(bloodBagId);
        event.setReleasedAt(LocalDateTime.now());
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.BLOOD_RELEASED, event);
    }

    /**
     * Publish low stock alert
     * Consumed by: Notification Service, Analytics Service
     */
    public void publishStockLow(String bloodType, Integer remainingUnits, String bloodBankId) {
        StockLowEvent event = new StockLowEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setBloodType(bloodType);
        event.setRemainingUnits(remainingUnits);
        event.setBloodBankId(bloodBankId);
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.STOCK_LOW, event);
    }

    /**
     * Publish blood expiry alert
     * Consumed by: Notification Service, Analytics Service
     */
    public void publishBloodExpired(String bloodBagId, String bloodType, String bloodBankId) {
        BloodExpiredEvent event = new BloodExpiredEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setBloodBagId(bloodBagId);
        event.setBloodType(bloodType);
        event.setBloodBankId(bloodBankId);
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.BLOOD_EXPIRED, event);
    }

    // ===== LOGISTICS EVENTS =====

    /**
     * Publish when blood transport starts
     * Consumed by: Notification Service, Analytics Service
     */
    public void publishTransportStarted(String transportId, String requestId, String vehicleId) {
        TransportStartedEvent event = new TransportStartedEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setTransportId(transportId);
        event.setRequestId(requestId);
        event.setVehicleId(vehicleId);
        event.setStartedAt(LocalDateTime.now());
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.TRANSPORT_STARTED, event);
    }

    /**
     * Publish when blood transport completes
     * Consumed by: Request Service, Notification Service, Analytics Service
     */
    public void publishTransportCompleted(String transportId, String requestId) {
        TransportCompletedEvent event = new TransportCompletedEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setTransportId(transportId);
        event.setRequestId(requestId);
        event.setCompletedAt(LocalDateTime.now());
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.TRANSPORT_COMPLETED, event);
    }

    // ===== CAMP EVENTS =====

    /**
     * Publish when camp is created
     * Consumed by: Notification Service, Analytics Service
     */
    public void publishCampCreated(String campId, String name, String location, LocalDateTime date) {
        CampCreatedEvent event = new CampCreatedEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setCampId(campId);
        event.setName(name);
        event.setLocation(location);
        event.setCampDate(date);
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.CAMP_CREATED, event);
    }

    /**
     * Publish when donor registers for camp
     * Consumed by: Notification Service, Analytics Service
     */
    public void publishCampRegistration(String campId, String donorId) {
        CampRegistrationEvent event = new CampRegistrationEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setCampId(campId);
        event.setDonorId(donorId);
        event.setRegisteredAt(LocalDateTime.now());
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.CAMP_REGISTRATION, event);
    }

    /**
     * Publish when camp completes
     * Consumed by: Analytics Service, Notification Service
     */
    public void publishCampCompleted(String campId, Integer totalDonors, Integer successfulDonations) {
        CampCompletedEvent event = new CampCompletedEvent();
        event.setEventId(UUID.randomUUID().toString());
        event.setCampId(campId);
        event.setTotalDonors(totalDonors);
        event.setSuccessfulDonations(successfulDonations);
        event.setCompletedAt(LocalDateTime.now());
        event.setTimestamp(LocalDateTime.now());
        
        publishEvent(EventTopics.CAMP_COMPLETED, event);
    }

    // ===== GENERIC EVENT PUBLISHING =====

    /**
     * Publish any event to RabbitMQ
     * 
     * @param routingKey Topic name (e.g., "event.blood.donated")
     * @param event Event object to publish
     */
    private void publishEvent(String routingKey, Object event) {
        try {
            String eventJson = objectMapper.writeValueAsString(event);
            amqpTemplate.convertAndSend(EXCHANGE, routingKey, eventJson);
            log.info("Event published - Topic: {}, EventId: {}", routingKey, 
                ((BaseEvent) event).getEventId());
        } catch (Exception e) {
            log.error("Error publishing event to topic {}: {}", routingKey, e.getMessage());
        }
    }

    // ===== EVENT DTOs =====

    @Data
    public static class BaseEvent {
        protected String eventId;
        protected LocalDateTime timestamp;
    }

    @Data
    public static class UserRegisteredEvent extends BaseEvent {
        private String userId;
        private String email;
        private String userType;
    }

    @Data
    public static class DonorRegisteredEvent extends BaseEvent {
        private String donorId;
        private String userId;
        private String bloodType;
    }

    @Data
    public static class BloodDonatedEvent extends BaseEvent {
        private String donorId;
        private String bloodType;
        private Integer units;
        private String bloodBankId;
        private LocalDateTime donationDate;
    }

    @Data
    public static class DonationCompletedEvent extends BaseEvent {
        private String donorId;
        private String donationId;
        private String status;
    }

    @Data
    public static class BloodRequestedEvent extends BaseEvent {
        private String requestId;
        private String bloodType;
        private Integer units;
        private String hospitalId;
        private Boolean isEmergency;
    }

    @Data
    public static class EmergencyRequestEvent extends BaseEvent {
        private String requestId;
        private String bloodType;
        private Integer units;
        private String hospitalId;
        private String patientName;
        private Boolean isEmergency;
        private String priority;
    }

    @Data
    public static class BloodRequestFulfilledEvent extends BaseEvent {
        private String requestId;
        private String bloodBagId;
        private Integer units;
    }

    @Data
    public static class BloodRequestCancelledEvent extends BaseEvent {
        private String requestId;
        private String reason;
    }

    @Data
    public static class BloodReservedEvent extends BaseEvent {
        private String bloodBagId;
        private String requestId;
        private LocalDateTime reservedAt;
    }

    @Data
    public static class BloodReleasedEvent extends BaseEvent {
        private String bloodBagId;
        private LocalDateTime releasedAt;
    }

    @Data
    public static class StockLowEvent extends BaseEvent {
        private String bloodType;
        private Integer remainingUnits;
        private String bloodBankId;
    }

    @Data
    public static class BloodExpiredEvent extends BaseEvent {
        private String bloodBagId;
        private String bloodType;
        private String bloodBankId;
    }

    @Data
    public static class TransportStartedEvent extends BaseEvent {
        private String transportId;
        private String requestId;
        private String vehicleId;
        private LocalDateTime startedAt;
    }

    @Data
    public static class TransportCompletedEvent extends BaseEvent {
        private String transportId;
        private String requestId;
        private LocalDateTime completedAt;
    }

    @Data
    public static class CampCreatedEvent extends BaseEvent {
        private String campId;
        private String name;
        private String location;
        private LocalDateTime campDate;
    }

    @Data
    public static class CampRegistrationEvent extends BaseEvent {
        private String campId;
        private String donorId;
        private LocalDateTime registeredAt;
    }

    @Data
    public static class CampCompletedEvent extends BaseEvent {
        private String campId;
        private Integer totalDonors;
        private Integer successfulDonations;
        private LocalDateTime completedAt;
    }
}
