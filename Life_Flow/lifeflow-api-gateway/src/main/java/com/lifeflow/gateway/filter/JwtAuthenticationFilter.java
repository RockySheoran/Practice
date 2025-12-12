package com.lifeflow.gateway.filter;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Slf4j
@Component
public class JwtAuthenticationFilter extends AbstractGatewayFilterFactory<JwtAuthenticationFilter.Config> {

    @Value("${jwt.secret:your-super-secret-jwt-key-change-in-production}")
    private String jwtSecret;

    public JwtAuthenticationFilter() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {
        return ((exchange, chain) -> {
            try {
                // Skip public endpoints
                String path = exchange.getRequest().getURI().getPath();
                if (isPublicEndpoint(path)) {
                    return chain.filter(exchange);
                }

                // Get authorization header
                String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
                
                if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                    throw new RuntimeException("Missing or invalid authorization header");
                }

                // Extract token
                String token = authHeader.substring(7);

                // Validate JWT
                validateToken(token);

                log.debug("JWT validation successful for path: {}", path);
                
                return chain.filter(exchange);

            } catch (Exception e) {
                log.error("JWT validation failed: {}", e.getMessage());
                exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                return exchange.getResponse().setComplete();
            }
        });
    }

    private void validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(Keys.hmacShaKeyFor(jwtSecret.getBytes()))
                    .build()
                    .parseClaimsJws(token);
        } catch (Exception e) {
            throw new RuntimeException("Invalid JWT token: " + e.getMessage());
        }
    }

    private boolean isPublicEndpoint(String path) {
        return path.startsWith("/api/v1/auth/login") ||
               path.startsWith("/api/v1/auth/register") ||
               path.startsWith("/actuator/health") ||
               path.startsWith("/swagger") ||
               path.startsWith("/api-docs");
    }

    public static class Config {
    }
}
