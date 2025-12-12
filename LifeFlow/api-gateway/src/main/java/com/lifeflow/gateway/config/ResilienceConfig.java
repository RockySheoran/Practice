package com.lifeflow.gateway.config;

import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;
import io.github.resilience4j.circuitbreaker.CircuitBreakerRegistry;
import io.github.resilience4j.core.registry.EntryAddedEvent;
import io.github.resilience4j.core.registry.EntryRemovedEvent;
import io.github.resilience4j.core.registry.RegistryEventConsumer;
import io.github.resilience4j.retry.Retry;
import io.github.resilience4j.retry.RetryConfig;
import io.github.resilience4j.retry.RetryRegistry;
import io.github.resilience4j.timelimiter.TimeLimiter;
import io.github.resilience4j.timelimiter.TimeLimiterConfig;
import io.github.resilience4j.timelimiter.TimeLimiterRegistry;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;
import java.util.concurrent.TimeoutException;

/**
 * Resilience4j Configuration for Circuit Breakers
 * Handles service failures gracefully
 * 
 * Benefits:
 * 1. Fast fail - don't wait for dead services
 * 2. Fallback - return cached/default data
 * 3. Automatic recovery - periodic retry attempts
 * 4. Monitoring - track service health
 */
@Slf4j
@Configuration
public class ResilienceConfig {

    /**
     * Circuit Breaker Configuration
     * Opens circuit when service fails repeatedly
     * Prevents cascading failures
     */
    @Bean
    public CircuitBreakerRegistry circuitBreakerRegistry() {
        CircuitBreakerConfig defaultConfig = CircuitBreakerConfig.custom()
            // Open circuit after 5 failed calls
            .failureRateThreshold(50.0f)
            .slowCallRateThreshold(50.0f)
            .slowCallDurationThreshold(Duration.ofSeconds(2))
            // Wait 30 seconds before trying again
            .waitDurationInOpenState(Duration.ofSeconds(30))
            // Try 3 calls to verify if service recovered
            .permittedNumberOfCallsInHalfOpenState(3)
            // Record last 100 calls
            .slidingWindowType(CircuitBreakerConfig.SlidingWindowType.COUNT_BASED)
            .slidingWindowSize(100)
            // Register exceptions that trigger circuit break
            .recordExceptions(Exception.class)
            // Ignore certain exceptions
            .ignoreExceptions(IllegalArgumentException.class)
            .build();

        CircuitBreakerRegistry registry = CircuitBreakerRegistry.of(defaultConfig);
        registry.getEventPublisher()
            .onEntryAdded(event -> log.info("Circuit Breaker added: {}", event.getAddedEntry().getName()))
            .onEntryRemoved(event -> log.info("Circuit Breaker removed: {}", event.getRemovedEntry().getName()));

        return registry;
    }

    /**
     * Retry Configuration
     * Automatically retry failed requests
     */
    @Bean
    public RetryRegistry retryRegistry() {
        RetryConfig defaultConfig = RetryConfig.custom()
            // Retry up to 3 times
            .maxAttempts(3)
            // Wait 1 second between retries
            .waitDuration(Duration.ofMillis(1000))
            // Use exponential backoff (1s, 2s, 4s...)
            .intervalFunction(io.github.resilience4j.core.IntervalFunction
                .ofExponentialBackoff(1000, 2))
            // Retry on these exceptions
            .retryOnException(e -> !(e instanceof IllegalArgumentException))
            .failAfterMaxAttempts(true)
            .build();

        RetryRegistry registry = RetryRegistry.of(defaultConfig);
        registry.getEventPublisher()
            .onEntryAdded(event -> log.info("Retry policy added: {}", event.getAddedEntry().getName()))
            .onEntryRemoved(event -> log.info("Retry policy removed: {}", event.getRemovedEntry().getName()));

        return registry;
    }

    /**
     * Time Limiter Configuration
     * Prevents hanging requests
     */
    @Bean
    public TimeLimiterRegistry timeLimiterRegistry() {
        TimeLimiterConfig defaultConfig = TimeLimiterConfig.custom()
            // Timeout after 5 seconds
            .timeoutDuration(Duration.ofSeconds(5))
            // Cancel running task when timeout
            .cancelRunningFuture(true)
            .build();

        TimeLimiterRegistry registry = TimeLimiterRegistry.of(defaultConfig);
        registry.getEventPublisher()
            .onEntryAdded(event -> log.info("Time Limiter added: {}", event.getAddedEntry().getName()))
            .onEntryRemoved(event -> log.info("Time Limiter removed: {}", event.getRemovedEntry().getName()));

        return registry;
    }

    /**
     * Service-specific Circuit Breakers
     */
    @Bean
    public CircuitBreaker inventoryServiceCB(CircuitBreakerRegistry registry) {
        return registry.circuitBreaker("inventory-service", CircuitBreakerConfig.custom()
            .failureRateThreshold(50.0f)
            .slowCallRateThreshold(50.0f)
            .slowCallDurationThreshold(Duration.ofSeconds(2))
            .waitDurationInOpenState(Duration.ofSeconds(30))
            .permittedNumberOfCallsInHalfOpenState(3)
            .slidingWindowSize(100)
            .recordExceptions(Exception.class)
            .build());
    }

    @Bean
    public CircuitBreaker donorServiceCB(CircuitBreakerRegistry registry) {
        return registry.circuitBreaker("donor-service", CircuitBreakerConfig.custom()
            .failureRateThreshold(50.0f)
            .slowCallRateThreshold(50.0f)
            .slowCallDurationThreshold(Duration.ofSeconds(3))
            .waitDurationInOpenState(Duration.ofSeconds(30))
            .permittedNumberOfCallsInHalfOpenState(3)
            .slidingWindowSize(100)
            .recordExceptions(Exception.class)
            .build());
    }

    @Bean
    public CircuitBreaker geolocationServiceCB(CircuitBreakerRegistry registry) {
        return registry.circuitBreaker("geolocation-service", CircuitBreakerConfig.custom()
            .failureRateThreshold(40.0f)
            .slowCallRateThreshold(40.0f)
            .slowCallDurationThreshold(Duration.ofSeconds(4))
            .waitDurationInOpenState(Duration.ofSeconds(45))
            .permittedNumberOfCallsInHalfOpenState(3)
            .slidingWindowSize(100)
            .recordExceptions(Exception.class)
            .build());
    }

    @Bean
    public CircuitBreaker notificationServiceCB(CircuitBreakerRegistry registry) {
        return registry.circuitBreaker("notification-service", CircuitBreakerConfig.custom()
            .failureRateThreshold(60.0f) // More lenient - notifications not critical
            .slowCallRateThreshold(60.0f)
            .slowCallDurationThreshold(Duration.ofSeconds(5))
            .waitDurationInOpenState(Duration.ofSeconds(60))
            .permittedNumberOfCallsInHalfOpenState(3)
            .slidingWindowSize(100)
            .recordExceptions(Exception.class)
            .build());
    }

    @Bean
    public CircuitBreaker analyticsServiceCB(CircuitBreakerRegistry registry) {
        return registry.circuitBreaker("analytics-service", CircuitBreakerConfig.custom()
            .failureRateThreshold(70.0f) // Very lenient - analytics not critical
            .slowCallRateThreshold(70.0f)
            .slowCallDurationThreshold(Duration.ofSeconds(5))
            .waitDurationInOpenState(Duration.ofSeconds(60))
            .permittedNumberOfCallsInHalfOpenState(3)
            .slidingWindowSize(100)
            .recordExceptions(Exception.class)
            .build());
    }
}
