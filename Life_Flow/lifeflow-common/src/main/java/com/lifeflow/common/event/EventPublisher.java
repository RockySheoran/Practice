package com.lifeflow.common.event;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Component;
import com.fasterxml.jackson.databind.ObjectMapper;

@Slf4j
@Component
@RequiredArgsConstructor
public class EventPublisher {

    private final RabbitTemplate rabbitTemplate;
    private final ObjectMapper objectMapper;

    /**
     * Publish a domain event to RabbitMQ event bus
     */
    public void publishEvent(DomainEvent event) {
        try {
            String eventType = event.getEventType();
            String exchangeName = "lifeflow.events";
            String routingKey = "event." + eventType.toLowerCase();
            
            String eventJson = objectMapper.writeValueAsString(event);
            
            rabbitTemplate.convertAndSend(exchangeName, routingKey, eventJson);
            
            log.info("Event published: {} with key: {}", eventType, routingKey);
            
        } catch (Exception e) {
            log.error("Failed to publish event: {}", event.getEventType(), e);
            throw new RuntimeException("Event publishing failed", e);
        }
    }
}
