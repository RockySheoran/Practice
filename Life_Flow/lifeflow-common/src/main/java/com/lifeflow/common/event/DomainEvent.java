package com.lifeflow.common.event;

import java.io.Serializable;

/**
 * Base class for all domain events in LifeFlow
 */
public abstract class DomainEvent implements Serializable {

    /**
     * Get the event type (e.g., "BLOOD_NEEDED", "DONOR_ACCEPTED")
     */
    public abstract String getEventType();

    /**
     * Get the aggregate ID associated with this event
     */
    public abstract String getAggregateId();
}
