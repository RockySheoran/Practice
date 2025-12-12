package com.lifeflow.donor.service;

import com.lifeflow.donor.dto.CreateHospitalDTO;
import com.lifeflow.donor.dto.HospitalProfileDTO;
import com.lifeflow.donor.entity.HospitalProfile;
import com.lifeflow.donor.repository.HospitalRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class HospitalService {

    private final HospitalRepository hospitalRepository;

    /**
     * Register new hospital
     */
    @Transactional
    public HospitalProfile registerHospital(CreateHospitalDTO dto) {
        log.info("Registering hospital: {}", dto.getHospitalName());

        String hospitalId = "hosp-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        HospitalProfile hospital = HospitalProfile.builder()
                .hospitalId(hospitalId)
                .userId(dto.getUserId())
                .hospitalName(dto.getHospitalName())
                .address(dto.getAddress())
                .city(dto.getCity())
                .state(dto.getState())
                .pincode(dto.getPincode())
                .contactPhone(dto.getContactPhone())
                .emergencyContact(dto.getEmergencyContact())
                .bloodBankCapacity(dto.getBloodBankCapacity())
                .operatingHoursStart(dto.getOperatingHoursStart())
                .operatingHoursEnd(dto.getOperatingHoursEnd())
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .website(dto.getWebsite())
                .description(dto.getDescription())
                .status(HospitalProfile.HospitalStatus.PENDING_VERIFICATION)
                .build();

        HospitalProfile savedHospital = hospitalRepository.save(hospital);

        log.info("Hospital registered with ID: {}", hospitalId);

        return savedHospital;
    }

    /**
     * Get hospital by ID
     */
    public HospitalProfile getHospitalById(String hospitalId) {
        log.info("Fetching hospital: {}", hospitalId);

        return hospitalRepository.findById(hospitalId)
                .orElseThrow(() -> new RuntimeException("Hospital not found: " + hospitalId));
    }

    /**
     * Update hospital profile
     */
    @Transactional
    public HospitalProfile updateHospital(String hospitalId, HospitalProfileDTO updateDTO) {
        log.info("Updating hospital: {}", hospitalId);

        HospitalProfile hospital = getHospitalById(hospitalId);

        if (updateDTO.getHospitalName() != null) {
            hospital.setHospitalName(updateDTO.getHospitalName());
        }
        if (updateDTO.getAddress() != null) {
            hospital.setAddress(updateDTO.getAddress());
        }
        if (updateDTO.getBloodBankCapacity() != null) {
            hospital.setBloodBankCapacity(updateDTO.getBloodBankCapacity());
        }
        if (updateDTO.getOperatingHoursStart() != null) {
            hospital.setOperatingHoursStart(updateDTO.getOperatingHoursStart());
        }
        if (updateDTO.getOperatingHoursEnd() != null) {
            hospital.setOperatingHoursEnd(updateDTO.getOperatingHoursEnd());
        }

        return hospitalRepository.save(hospital);
    }

    /**
     * List all hospitals
     */
    public Page<HospitalProfile> listHospitals(Pageable pageable) {
        log.info("Listing hospitals");
        return hospitalRepository.findAll(pageable);
    }

    /**
     * Verify hospital by admin
     */
    @Transactional
    public void verifyHospital(String hospitalId, String adminId) {
        log.info("Verifying hospital: {} by admin: {}", hospitalId, adminId);

        HospitalProfile hospital = getHospitalById(hospitalId);
        hospital.setStatus(HospitalProfile.HospitalStatus.ACTIVE);
        hospital.setRegistrationVerified(true);
        hospital.setVerifiedByAdmin(adminId);
        hospital.setVerifiedAt(LocalDateTime.now());

        hospitalRepository.save(hospital);

        log.info("Hospital verified: {}", hospitalId);
    }

    /**
     * Get performance report
     */
    public Object getPerformanceReport(String hospitalId, Integer days) {
        log.info("Generating performance report for hospital: {} for {} days", hospitalId, days);

        HospitalProfile hospital = getHospitalById(hospitalId);

        // TODO: Query REQUEST_DB for statistics
        return new Object() {
            public String hospitalId = hospital.getHospitalId();
            public String hospitalName = hospital.getHospitalName();
            public Integer period = days;
            public Integer totalRequests = 0;
            public Integer fulfilledRequests = 0;
            public Integer operationalEfficiencyScore = 90;
        };
    }

    /**
     * Get hospital dashboard
     */
    public Object getHospitalDashboard(String hospitalId) {
        log.info("Generating dashboard for hospital: {}", hospitalId);

        HospitalProfile hospital = getHospitalById(hospitalId);

        // TODO: Aggregate data from multiple services
        return new Object() {
            public String hospitalId = hospital.getHospitalId();
            public String hospitalName = hospital.getHospitalName();
            public Object todayStats = new Object() {
                public Integer totalRequests = 5;
                public Integer fulfilledRequests = 4;
                public Integer averageResponseTime = 18;
            };
        };
    }

    /**
     * Find nearby hospitals
     */
    public List<?> findNearbyHospitals(Double latitude, Double longitude, Double radiusKm) {
        log.info("Finding hospitals near ({}, {}) within {} km", latitude, longitude, radiusKm);

        List<HospitalProfile> allHospitals = hospitalRepository.findByStatus(
                HospitalProfile.HospitalStatus.ACTIVE);

        return allHospitals.stream()
                .filter(h -> h.calculateDistance(latitude, longitude) <= radiusKm)
                .collect(Collectors.toList());
    }
}
