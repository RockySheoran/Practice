package com.lifeflow.gateway.config;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayConfig {

    /**
     * Configure routes for all microservices
     */
    @Bean
    public RouteLocator routeLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                // Identity Service Routes
                .route("identity-service", r -> r
                        .path("/api/v1/auth/**", "/api/v1/users/**")
                        .uri("lb://identity-service"))

                // Donor Service Routes
                .route("donor-service", r -> r
                        .path("/api/v1/donors/**", "/api/v1/eligibility/**", "/api/v1/gamification/**")
                        .uri("lb://donor-service"))

                // Inventory Service Routes
                .route("inventory-service", r -> r
                        .path("/api/v1/inventory/**", "/api/v1/stock/**")
                        .uri("lb://inventory-service"))

                // Request Service Routes (Emergency Requests)
                .route("request-service", r -> r
                        .path("/api/v1/requests/**", "/api/v1/responses/**")
                        .uri("lb://request-service"))

                // Geolocation Service Routes
                .route("geolocation-service", r -> r
                        .path("/api/v1/geo/**", "/api/v1/tracking/**")
                        .uri("lb://geolocation-service"))

                // Notification Service Routes
                .route("notification-service", r -> r
                        .path("/api/v1/notifications/**")
                        .uri("lb://notification-service"))

                // Analytics Service Routes
                .route("analytics-service", r -> r
                        .path("/api/v1/analytics/**", "/api/v1/dashboard/**", "/api/v1/reports/**")
                        .uri("lb://analytics-service"))

                .build();
    }
}
