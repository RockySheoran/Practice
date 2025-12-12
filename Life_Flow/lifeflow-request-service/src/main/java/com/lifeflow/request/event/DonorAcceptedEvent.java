package com.lifeflow.request.event;

import com.lifeflow.common.event.DomainEvent;
import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DonorAcceptedEvent extends DomainEvent {

    private String requestId;
    private String responseId;
    private String donorId;
    private Integer arrivalEtaMinutes;
    private LocalDateTime scheduledPickupTime;
    private LocalDateTime timestamp;
    
    @Override
    public String getEventType() {
        return "DONOR_ACCEPTED";
    }
    
    @Override
    public String getAggregateId() {
        return requestId;
    }
}
