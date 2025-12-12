# LifeFlow API Gateway

## Overview

The API Gateway serves as the single entry point for all client requests to the LifeFlow system. It handles:
- Request routing to appropriate microservices
- Authentication and authorization
- Rate limiting and throttling
- Request/response transformation
- CORS handling
- Logging and monitoring
- Circuit breaker pattern implementation

## Technology Stack

- **Framework**: Spring Cloud Gateway (Reactive)
- **Authentication**: Spring Security + JWT
- **Resilience**: Spring Cloud Circuit Breaker (Resilience4j)
- **Rate Limiting**: Spring Cloud Gateway with custom rate limiter

## Architecture

```
Client (Mobile/Web/Admin)
        ↓
   HTTPS/TLS 1.3
        ↓
   ┌─────────────────┐
   │  API Gateway    │
   ├─────────────────┤
   │ • Auth Filter   │
   │ • Rate Limit    │
   │ • Routing       │
   │ • Logging       │
   └─────────┬───────┘
             │
    ┌────────┼────────┬──────────┐
    ↓        ↓        ↓          ↓
 Service1  Service2 Service3   Service4
```

## Route Configuration

```yaml
spring:
  cloud:
    gateway:
      routes:
        # Identity & Authentication
        - id: identity-service
          uri: http://identity-service:8001
          predicates:
            - Path=/api/v1/auth/**
          filters:
            - StripPrefix=2
            - RequestRateLimiter=10,1

        # Donor Service
        - id: donor-service
          uri: http://donor-service:8002
          predicates:
            - Path=/api/v1/donors/**
          filters:
            - StripPrefix=2
            - name: RequestRateLimiter
              args:
                redis-rate-limiter:
                  replenishRate: 100
                  burstCapacity: 200

        # ... additional routes for other services

      # Global CORS
      globalcors:
        corsConfigurations:
          '[/**]':
            allowedOrigins: "*"
            allowedMethods:
              - GET
              - POST
              - PUT
              - DELETE
              - OPTIONS
            allowedHeaders: "*"
            maxAge: 86400
```

## Key Features

### 1. Authentication Filter
```java
@Component
public class JwtAuthenticationFilter extends AbstractGatewayFilterFactory<Config> {
    // Validates JWT tokens from Authorization header
    // Extracts user claims and adds to request headers
    // Rejects invalid/expired tokens
}
```

### 2. Rate Limiting
- Per-user: 1,000 requests/hour
- Per-IP: 10,000 requests/hour
- Per-endpoint: Configurable based on endpoint sensitivity
- Uses Redis for distributed rate limiting

### 3. Circuit Breaker
```java
@CircuitBreaker(name = "inventory-service", fallbackMethod = "inventoryFallback")
public Mono<ServerResponse> getInventory() {
    // Forward request to inventory service
    // If service down, trigger fallback
}

public Mono<ServerResponse> inventoryFallback(Exception e) {
    // Return cached data or error response
}
```

### 4. Request/Response Transformation
```java
@Component
public class RequestTransformer implements GatewayFilter {
    // Add correlation IDs
    // Mask sensitive data in responses
    // Transform response format if needed
}
```

## Monitoring

### Metrics Exposed
```
# Request metrics
gateway_requests_total{service="donor-service"}
gateway_requests_duration_seconds{service="donor-service"}
gateway_requests_errors_total{service="donor-service"}

# Rate limiting metrics
ratelimiter_permits_consumed_total
ratelimiter_permits_denied_total

# Circuit breaker metrics
resilience4j_circuitbreaker_state{name="donor-service"}
resilience4j_circuitbreaker_calls_total{name="donor-service"}
```

## Running

```bash
# Development
mvn spring-boot:run

# Docker
docker build -t lifeflow/api-gateway:latest .
docker run -p 8000:8000 \
  -e SPRING_PROFILES_ACTIVE=dev \
  lifeflow/api-gateway:latest

# Docker Compose
docker-compose up api-gateway
```

## Configuration

Key properties in `application.yml`:
```yaml
server:
  port: 8000

spring:
  cloud:
    gateway:
      # ... route configuration
      default-filters:
        - TokenRelay

management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus
```

## Testing

```bash
# Test gateway health
curl http://localhost:8000/health

# Test authentication
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Test rate limiting (should fail after 10 requests)
for i in {1..15}; do
  curl http://localhost:8000/api/v1/donors/me
done
```

## Troubleshooting

**Service not reachable**:
- Check service is running: `docker ps`
- Verify network: `docker network inspect lifeflow_network`
- Check route configuration matches service name

**Authentication failing**:
- Verify JWT secret matches across services
- Check token expiration
- Ensure Authorization header format: `Bearer <token>`

**Rate limiting issues**:
- Verify Redis is running
- Check rate limit configuration
- Monitor Redis memory usage

