package com.lifeflow.request.event;

import com.lifeflow.common.event.DomainEvent;
import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BloodNeededEvent extends DomainEvent {

    private String requestId;
    private String bloodType;
    private Double unitsRequired;
    private String urgencyLevel;
    private String hospitalId;
    private Integer deadlineMinutes;
    private LocalDateTime timestamp;
    
    @Override
    public String getEventType() {
        return "BLOOD_NEEDED";
    }
    
    @Override
    public String getAggregateId() {
        return requestId;
    }
}
