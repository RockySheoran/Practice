package com.lifeflow.request.repository;

import com.lifeflow.request.entity.RequestResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface RequestResponseRepository extends JpaRepository<RequestResponse, String> {

    /**
     * Find responses for a request
     */
    List<RequestResponse> findByRequest_RequestId(String requestId);

    /**
     * Find accepted responses for a request
     */
    @Query("SELECT rr FROM RequestResponse rr WHERE rr.request.requestId = :requestId " +
           "AND rr.responseStatus = 'ACCEPTED'")
    List<RequestResponse> findAcceptedByRequestId(@Param("requestId") String requestId);

    /**
     * Find pending responses for a donor
     */
    @Query("SELECT rr FROM RequestResponse rr WHERE rr.donorId = :donorId " +
           "AND rr.responseStatus IN ('PENDING', 'ACCEPTED')")
    List<RequestResponse> findPendingByDonorId(@Param("donorId") String donorId);

    /**
     * Find all responses for a donor
     */
    List<RequestResponse> findByDonorIdOrderByResponseCreatedAtDesc(String donorId);

    /**
     * Count responses by status for a request
     */
    @Query("SELECT COUNT(rr) FROM RequestResponse rr WHERE rr.request.requestId = :requestId " +
           "AND rr.responseStatus = :status")
    long countByRequestIdAndStatus(@Param("requestId") String requestId,
                                   @Param("status") RequestResponse.ResponseStatus status);

    /**
     * Find responses created within time range
     */
    @Query("SELECT rr FROM RequestResponse rr WHERE rr.responseCreatedAt BETWEEN :from AND :to")
    List<RequestResponse> findByTimeRange(@Param("from") LocalDateTime from,
                                          @Param("to") LocalDateTime to);
}
