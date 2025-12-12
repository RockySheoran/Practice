# Donor Management Service

## Service Overview

The Donor Management Service is responsible for managing all donor-related operations in LifeFlow, including donor profiles, medical history, donation records, eligibility status, and reward management.

## Key Responsibilities

- **Donor Registration**: Create and manage donor profiles
- **Medical History**: Track donor health information (blood type, hemoglobin level, weight, etc.)
- **Donation Records**: Maintain history of all donations
- **Eligibility Management**: Determine donor eligibility for donation based on criteria
- **Reward System**: Manage donor points, badges, and reward preferences
- **Preference Management**: Store donor communication and donation preferences

## Technology Stack

- **Language**: Java 17
- **Framework**: Spring Boot 3.x
- **Database**: PostgreSQL
- **ORM**: JPA/Hibernate
- **Message Broker**: RabbitMQ (event publishing)
- **Caching**: Redis
- **API**: REST (OpenAPI 3.0)

## API Endpoints

### Donor Profile Management
```
GET  /api/v1/donors/me              Get my profile
PUT  /api/v1/donors/me              Update my profile
GET  /api/v1/donors/{id}            Get donor details
POST /api/v1/donors/{id}/avatar     Upload profile picture
GET  /api/v1/donors/search          Search donors (admin only)
```

### Eligibility
```
GET  /api/v1/donors/me/eligibility             Check my eligibility
GET  /api/v1/donors/{id}/eligibility-history   Get eligibility history
POST /api/v1/donors/{id}/eligibility/verify    Verify eligibility (doctor)
```

### Donations
```
GET  /api/v1/donors/me/donations               Get my donation history
POST /api/v1/donations                         Record new donation (blood bank)
GET  /api/v1/donations/{id}                    Get donation details
PUT  /api/v1/donations/{id}/status             Update donation status
```

### Rewards
```
GET  /api/v1/donors/me/rewards                 Get my rewards
GET  /api/v1/donors/me/points                  Get my points balance
GET  /api/v1/rewards/catalog                   Get reward catalog
POST /api/v1/rewards/{id}/redeem               Redeem reward
```

### Preferences
```
GET  /api/v1/donors/me/preferences             Get my preferences
PUT  /api/v1/donors/me/preferences             Update preferences
```

## Database Schema

Key tables:
- `donors`: Donor profiles
- `medical_history`: Health records
- `donation_records`: Donation history
- `donor_preferences`: Communication preferences
- `donor_contacts`: Emergency contacts

## Events Published

- `EVENT_DONOR_REGISTERED`: New donor registered
- `EVENT_DONOR_ELIGIBILITY_CHANGED`: Eligibility status changed
- `EVENT_DONATION_COMPLETED`: Donation recorded
- `EVENT_POINTS_EARNED`: Donor earned points
- `EVENT_BADGE_EARNED`: Donor earned badge

## Configuration

```properties
# application.properties

spring.datasource.url=jdbc:postgresql://localhost:5432/lifeflow_donors
spring.datasource.username=lifeflow
spring.datasource.password=password
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQL10Dialect

spring.rabbitmq.host=localhost
spring.rabbitmq.port=5672
spring.rabbitmq.username=guest
spring.rabbitmq.password=guest

spring.redis.host=localhost
spring.redis.port=6379

lifeflow.service.name=donor-service
lifeflow.service.port=8002
```

## Running Locally

```bash
# Using Maven
mvn spring-boot:run

# Using Docker
docker build -t lifeflow/donor-service:latest .
docker run -p 8002:8002 --network lifeflow_network lifeflow/donor-service:latest

# Using Docker Compose
docker-compose up donor-service
```

## Testing

```bash
# Run unit tests
mvn test

# Run integration tests
mvn verify

# Run with coverage
mvn clean test jacoco:report
```

