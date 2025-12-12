package com.lifeflow.donor.repository;

import com.lifeflow.donor.entity.HospitalProfile;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HospitalRepository extends JpaRepository<HospitalProfile, String> {

    /**
     * Find hospital by user ID
     */
    Optional<HospitalProfile> findByUserId(String userId);

    /**
     * Find hospitals by status
     */
    List<HospitalProfile> findByStatus(HospitalProfile.HospitalStatus status);

    /**
     * Find hospitals by city
     */
    Page<HospitalProfile> findByCity(String city, Pageable pageable);

    /**
     * Find active hospitals
     */
    @Query("SELECT h FROM HospitalProfile h WHERE h.status = 'ACTIVE'")
    Page<HospitalProfile> findActiveHospitals(Pageable pageable);

    /**
     * Find verified hospitals
     */
    @Query("SELECT h FROM HospitalProfile h WHERE h.registrationVerified = true")
    List<HospitalProfile> findVerifiedHospitals();

    /**
     * Find hospitals by partial name (search)
     */
    @Query("SELECT h FROM HospitalProfile h WHERE LOWER(h.hospitalName) LIKE LOWER(CONCAT('%', :name, '%'))")
    Page<HospitalProfile> searchByName(@Param("name") String name, Pageable pageable);

    /**
     * Count hospitals by status
     */
    long countByStatus(HospitalProfile.HospitalStatus status);
}
