package com.lifeflow.donor.controller;

import com.lifeflow.common.dto.ApiResponse;
import com.lifeflow.donor.dto.HospitalProfileDTO;
import com.lifeflow.donor.dto.CreateHospitalDTO;
import com.lifeflow.donor.entity.HospitalProfile;
import com.lifeflow.donor.service.HospitalService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@Slf4j
@RestController
@RequestMapping("/api/v1/hospitals")
@RequiredArgsConstructor
public class HospitalController {

    private final HospitalService hospitalService;

    /**
     * Register new hospital
     * POST /api/v1/hospitals/register
     */
    @PostMapping("/register")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<HospitalProfileDTO>> registerHospital(
            @Valid @RequestBody CreateHospitalDTO createHospitalDTO) {
        
        log.info("Registering new hospital: {}", createHospitalDTO.getHospitalName());
        
        HospitalProfile hospital = hospitalService.registerHospital(createHospitalDTO);
        
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(
                        "Hospital registered successfully",
                        HospitalProfileDTO.fromEntity(hospital)
                ));
    }

    /**
     * Get hospital profile
     * GET /api/v1/hospitals/{hospitalId}
     */
    @GetMapping("/{hospitalId}")
    public ResponseEntity<ApiResponse<HospitalProfileDTO>> getHospital(
            @PathVariable String hospitalId) {
        
        log.info("Fetching hospital profile: {}", hospitalId);
        
        HospitalProfile hospital = hospitalService.getHospitalById(hospitalId);
        
        return ResponseEntity.ok(ApiResponse.success(
                "Hospital profile retrieved",
                HospitalProfileDTO.fromEntity(hospital)
        ));
    }

    /**
     * Get hospital dashboard
     * GET /api/v1/hospitals/{hospitalId}/dashboard
     */
    @GetMapping("/{hospitalId}/dashboard")
    @PreAuthorize("hasRole('HOSPITAL')")
    public ResponseEntity<ApiResponse<?>> getHospitalDashboard(
            @PathVariable String hospitalId) {
        
        log.info("Fetching dashboard for hospital: {}", hospitalId);
        
        var dashboard = hospitalService.getHospitalDashboard(hospitalId);
        
        return ResponseEntity.ok(ApiResponse.success(
                "Dashboard retrieved",
                dashboard
        ));
    }

    /**
     * Update hospital profile
     * PUT /api/v1/hospitals/{hospitalId}/profile
     */
    @PutMapping("/{hospitalId}/profile")
    @PreAuthorize("hasRole('HOSPITAL') or hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<HospitalProfileDTO>> updateHospital(
            @PathVariable String hospitalId,
            @Valid @RequestBody HospitalProfileDTO updateDTO) {
        
        log.info("Updating hospital profile: {}", hospitalId);
        
        HospitalProfile hospital = hospitalService.updateHospital(hospitalId, updateDTO);
        
        return ResponseEntity.ok(ApiResponse.success(
                "Hospital profile updated",
                HospitalProfileDTO.fromEntity(hospital)
        ));
    }

    /**
     * List all hospitals (paginated)
     * GET /api/v1/hospitals?page=0&size=20
     */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Page<HospitalProfileDTO>>> listHospitals(
            Pageable pageable) {
        
        log.info("Listing hospitals with pagination: page={}, size={}", 
                pageable.getPageNumber(), pageable.getPageSize());
        
        Page<HospitalProfile> hospitals = hospitalService.listHospitals(pageable);
        Page<HospitalProfileDTO> dtos = hospitals.map(HospitalProfileDTO::fromEntity);
        
        return ResponseEntity.ok(ApiResponse.success(
                "Hospitals retrieved",
                dtos
        ));
    }

    /**
     * Get hospital performance report
     * GET /api/v1/hospitals/{hospitalId}/performance?days=30
     */
    @GetMapping("/{hospitalId}/performance")
    @PreAuthorize("hasRole('HOSPITAL') or hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<?>> getHospitalPerformance(
            @PathVariable String hospitalId,
            @RequestParam(defaultValue = "30") Integer days) {
        
        log.info("Fetching performance report for hospital: {} for {} days",
                hospitalId, days);
        
        var performance = hospitalService.getPerformanceReport(hospitalId, days);
        
        return ResponseEntity.ok(ApiResponse.success(
                "Performance report retrieved",
                performance
        ));
    }

    /**
     * Verify hospital (Admin only)
     * PUT /api/v1/hospitals/{hospitalId}/verify
     */
    @PutMapping("/{hospitalId}/verify")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<String>> verifyHospital(
            @PathVariable String hospitalId,
            @RequestParam String adminId) {
        
        log.info("Verifying hospital: {} by admin: {}", hospitalId, adminId);
        
        hospitalService.verifyHospital(hospitalId, adminId);
        
        return ResponseEntity.ok(ApiResponse.success(
                "Hospital verified successfully",
                hospitalId
        ));
    }

    /**
     * Get nearby hospitals (for reference/transfers)
     * GET /api/v1/hospitals/nearby?lat=28.5&lon=77.3&radius=10
     */
    @GetMapping("/nearby")
    public ResponseEntity<ApiResponse<?>> getNearbyHospitals(
            @RequestParam Double latitude,
            @RequestParam Double longitude,
            @RequestParam(defaultValue = "10") Double radiusKm) {
        
        log.info("Finding hospitals near lat={}, lon={} within {} km",
                latitude, longitude, radiusKm);
        
        var nearbyHospitals = hospitalService.findNearbyHospitals(latitude, longitude, radiusKm);
        
        return ResponseEntity.ok(ApiResponse.success(
                "Nearby hospitals retrieved",
                nearbyHospitals
        ));
    }
}
