package com.lifeflow.request.repository;

import com.lifeflow.request.entity.BloodRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface BloodRequestRepository extends JpaRepository<BloodRequest, String> {

    /**
     * Find requests by status
     */
    List<BloodRequest> findByStatusIn(List<BloodRequest.RequestStatus> statuses);

    /**
     * Find active requests for a hospital
     */
    @Query("SELECT br FROM BloodRequest br WHERE br.hospitalId = :hospitalId " +
           "AND br.status IN ('PENDING', 'MATCHED', 'ACCEPTED')")
    List<BloodRequest> findActiveByHospitalId(@Param("hospitalId") String hospitalId);

    /**
     * Find critical requests
     */
    @Query("SELECT br FROM BloodRequest br WHERE br.urgencyLevel = 'CRITICAL' " +
           "AND br.status != 'FULFILLED' AND br.deadlineTimestamp > :now")
    List<BloodRequest> findCriticalRequests(@Param("now") LocalDateTime now);

    /**
     * Find expired requests
     */
    @Query("SELECT br FROM BloodRequest br WHERE br.deadlineTimestamp < :now " +
           "AND br.status NOT IN ('FULFILLED', 'CANCELLED')")
    List<BloodRequest> findExpiredRequests(@Param("now") LocalDateTime now);

    /**
     * Find requests by blood type and status
     */
    List<BloodRequest> findByBloodTypeNeededAndStatus(
            BloodRequest.BloodType bloodType,
            BloodRequest.RequestStatus status);

    /**
     * Find requests created in last N hours
     */
    @Query("SELECT br FROM BloodRequest br WHERE br.createdAt > :fromTime")
    List<BloodRequest> findRecentRequests(@Param("fromTime") LocalDateTime fromTime);
}
