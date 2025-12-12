package com.lifeflow.gateway.config;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;

/**
 * API Gateway Route Configuration
 * Defines all routes to microservices
 */
@Configuration
public class GatewayRouteConfig {
    
    @Bean
    public RouteLocator routes(RouteLocatorBuilder builder) {
        return builder.routes()
            // ===== IDENTITY & AUTHENTICATION SERVICE (Port 8001) =====
            .route("identity-register", r -> r
                .path("/api/v1/auth/register")
                .and()
                .method(HttpMethod.POST)
                .uri("http://identity-service:8001"))
            
            .route("identity-login", r -> r
                .path("/api/v1/auth/login")
                .and()
                .method(HttpMethod.POST)
                .uri("http://identity-service:8001"))
            
            .route("identity-logout", r -> r
                .path("/api/v1/auth/logout")
                .uri("http://identity-service:8001"))
            
            .route("identity-refresh", r -> r
                .path("/api/v1/auth/refresh-token")
                .uri("http://identity-service:8001"))
            
            .route("identity-kyc", r -> r
                .path("/api/v1/auth/kyc/**")
                .filters(f -> f.stripPrefix(2))
                .uri("http://identity-service:8001"))
            
            .route("identity-users", r -> r
                .path("/api/v1/users/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter()))
                .uri("http://identity-service:8001"))
            
            // ===== DONOR MANAGEMENT SERVICE (Port 8002) =====
            .route("donor-profile", r -> r
                .path("/api/v1/donors/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter())
                    .requestRateLimiter(config -> config
                        .setRateLimiter(new RedisRateLimiter(100, 200))))
                .uri("http://donor-service:8002"))
            
            .route("donor-eligibility", r -> r
                .path("/api/v1/eligibility/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter()))
                .uri("http://donor-service:8002"))
            
            // ===== INVENTORY & BLOOD BANK SERVICE (Port 8003) =====
            .route("inventory-blood", r -> r
                .path("/api/v1/inventory/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter()))
                .uri("http://inventory-service:8003"))
            
            .route("inventory-bags", r -> r
                .path("/api/v1/blood-bags/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter()))
                .uri("http://inventory-service:8003"))
            
            // ===== REQUEST & EMERGENCY SERVICE (Port 8004) =====
            // Emergency requests - NO RATE LIMIT!
            .route("request-emergency", r -> r
                .path("/api/v1/blood-requests")
                .and()
                .method(HttpMethod.POST)
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter())
                    .filter(new EmergencyPriorityFilter()))
                .uri("http://request-service:8004"))
            
            .route("request-standard", r -> r
                .path("/api/v1/blood-requests/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter())
                    .requestRateLimiter(config -> config
                        .setRateLimiter(new RedisRateLimiter(50, 100))))
                .uri("http://request-service:8004"))
            
            // ===== GEOLOCATION & LOGISTICS SERVICE (Port 8005) =====
            .route("geolocation-tracking", r -> r
                .path("/api/v1/tracking/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter()))
                .uri("http://geolocation-service:8005"))
            
            .route("geolocation-distance", r -> r
                .path("/api/v1/distance/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter()))
                .uri("http://geolocation-service:8005"))
            
            // ===== NOTIFICATION SERVICE (Port 8006) =====
            .route("notification-preferences", r -> r
                .path("/api/v1/notifications/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter()))
                .uri("http://notification-service:8006"))
            
            // ===== CAMP & EVENT SERVICE (Port 8007) =====
            .route("camp-management", r -> r
                .path("/api/v1/camps/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter()))
                .uri("http://camp-service:8007"))
            
            // ===== ANALYTICS & GAMIFICATION SERVICE (Port 8008) =====
            .route("analytics-dashboard", r -> r
                .path("/api/v1/analytics/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter()))
                .uri("http://analytics-service:8008"))
            
            .route("analytics-rewards", r -> r
                .path("/api/v1/rewards/**")
                .filters(f -> f
                    .stripPrefix(2)
                    .filter(new JwtAuthenticationFilter()))
                .uri("http://analytics-service:8008"))
            
            .route("analytics-leaderboards", r -> r
                .path("/api/v1/leaderboards")
                .filters(f -> f
                    .stripPrefix(2)
                    .requestRateLimiter(config -> config
                        .setRateLimiter(new RedisRateLimiter(1000, 2000))))
                .uri("http://analytics-service:8008"))
            
            // ===== HEALTH CHECKS =====
            .route("gateway-health", r -> r
                .path("/health")
                .uri("http://localhost:8000"))
            
            .route("services-health", r -> r
                .path("/api/v1/health/**")
                .uri("http://identity-service:8001"))
            
            .build();
    }
}
