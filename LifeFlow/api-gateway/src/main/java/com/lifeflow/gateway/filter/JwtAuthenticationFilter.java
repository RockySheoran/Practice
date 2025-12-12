package com.lifeflow.gateway.filter;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import javax.crypto.SecretKey;
import java.util.Base64;

/**
 * JWT Authentication Filter for API Gateway
 * Validates JWT tokens from Authorization header
 * Extracts user info and adds to request headers for downstream services
 */
@Component
public class JwtAuthenticationFilter extends AbstractGatewayFilterFactory<JwtAuthenticationFilter.Config> {

    public static class Config {
        public String tokenSecret;
    }

    private final JwtUtil jwtUtil;

    public JwtAuthenticationFilter(JwtUtil jwtUtil) {
        super(Config.class);
        this.jwtUtil = jwtUtil;
    }

    @Override
    public GatewayFilter apply(Config config) {
        return ((exchange, chain) -> {
            String token = null;
            String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);

            // Extract token from "Bearer <token>"
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                token = authHeader.substring(7);
            }

            if (token == null || token.isEmpty()) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing Authorization token");
            }

            try {
                // Validate token
                Claims claims = jwtUtil.validateToken(token);
                
                // Extract user information
                String userId = claims.getSubject();
                String role = claims.get("role", String.class);
                String username = claims.get("username", String.class);
                String userType = claims.get("userType", String.class); // donor, hospital, admin
                
                // Add user info to request headers for downstream services
                exchange.getRequest().mutate()
                    .header("X-User-Id", userId)
                    .header("X-User-Name", username)
                    .header("X-User-Role", role)
                    .header("X-User-Type", userType)
                    .header("X-Forwarded-Token", token)
                    .header("X-Forwarded-For", exchange.getRequest().getRemoteAddress().getAddress().getHostAddress())
                    .build();

                return chain.filter(exchange);

            } catch (Exception e) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid or expired token: " + e.getMessage());
            }
        });
    }
}
