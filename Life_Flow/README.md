# LifeFlow: Blood Donation Management System (Java/Spring Boot Edition)

**A mission-critical, high-availability platform connecting hospitals with blood donors in emergencies.**

## 🚀 Quick Start

### Prerequisites
- Java 17+
- Maven 3.8+
- Docker & Docker Compose
- PostgreSQL 14+
- Redis
- RabbitMQ

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/RockySheoran/Practice.git
   cd Practice
   ```

2. **Setup environment variables**
   ```bash
   cp .env.example .env
   ```

3. **Initialize databases**
   ```bash
   bash scripts/setup-databases.sh
   ```

4. **Build all services**
   ```bash
   mvn clean install -DskipTests
   ```

5. **Start all services using Docker Compose**
   ```bash
   docker-compose up -d
   ```

6. **Verify services are running**
   ```bash
   curl http://localhost:8080/actuator/health
   ```

## 📋 System Overview

LifeFlow solves the critical challenge of blood availability in emergencies using **Java/Spring Boot microservices** architecture.

**The Problem:**
- Patient needs emergency blood transfusion
- Hospital blood bank is low/out of stock
- Need to find eligible donors within minutes
- Manual process is slow and error-prone

**The Solution:**
- Automated donor matching algorithm (Spring Data JPA with custom queries)
- Real-time emergency notifications (Spring Integration with RabbitMQ)
- Live tracking from donation to usage (Spring WebSocket)
- Gamification to encourage repeat donations

## 🏗️ Architecture (Java Stack)

```
┌─────────────────────────────────────────┐
│      API Gateway (Spring Cloud Gateway) │
│              (8080)                     │
└─────────────────────┬───────────────────┘
                      │
    ┌─────────────────┼─────────────────┐
    │                 │                 │
┌───▼────────────┐ ┌─▼────────────┐ ┌─▼────────────┐
│REQUEST SERVICE │ │DONOR SERVICE │ │INVENTORY SVC │
│(Spring Boot)   │ │(Spring Boot) │ │(Spring Boot) │
│ Port: 3004     │ │ Port: 3002   │ │ Port: 3003   │
└───┬────────────┘ └──┬──────────┘ └──┬────────────┘
    │                 │                 │
    └─────────────────┼─────────────────┘
                      │
         ┌────────────▼─────────────┐
         │  RabbitMQ Event Bus      │
         │  (Spring AMQP)           │
         └────────────┬─────────────┘
                      │
    ┌─────────────────┼─────────────────┐
    │                 │                 │
┌───▼────────┐  ┌─────▼──────┐  ┌──────▼─────┐
│GEOLOCATION │  │NOTIFICATION│  │ ANALYTICS  │
│SERVICE     │  │ SERVICE    │  │ SERVICE    │
│Port: 3005  │  │ Port: 3006 │  │ Port: 3007 │
└────────────┘  └────────────┘  └────────────┘
```

## 🛠️ Technology Stack

**Backend:**
- Java 17 LTS
- Spring Boot 3.x
- Spring Cloud (Eureka, Config Server)
- Spring Data JPA (Hibernate)
- Spring AMQP (RabbitMQ)
- Spring WebSocket (Real-time tracking)
- Spring Security + JWT
- PostgreSQL 14+
- Redis (Caching)
- Maven (Build)

**Database:**
- PostgreSQL (Primary data store)
- Redis (Geolocation cache)
- MongoDB (Optional: Notification logs)

**Infrastructure:**
- Docker & Docker Compose
- Kubernetes (Production)
- Nginx (Load Balancer)
- ELK Stack (Logging)
- Prometheus + Grafana (Monitoring)

## 📊 Core Entities

### 1. **Blood Request** (Emergency)
```java
@Entity
public class BloodRequest {
    @Id private String requestId;
    private String bloodType;
    private Integer unitsRequired;
    @Enumerated(EnumType.STRING)
    private UrgencyLevel urgencyLevel;
    private LocalDateTime deadline;
    @Enumerated(EnumType.STRING)
    private RequestStatus status;
}
```

### 2. **Donor Response**
```java
@Entity
public class RequestResponse {
    @Id private String responseId;
    @ManyToOne private BloodRequest request;
    @ManyToOne private DonorProfile donor;
    @Enumerated(EnumType.STRING)
    private ResponseStatus responseStatus;
    private LocalDateTime scheduledPickupTime;
    private Integer pointsEarned;
}
```

## 📡 API Endpoints

### Create Emergency Request
```http
POST /api/v1/requests/create
Content-Type: application/json
Authorization: Bearer {jwt_token}

{
  "hospitalId": "hosp-001",
  "bloodType": "O_POSITIVE",
  "unitsRequired": 4,
  "urgencyLevel": "CRITICAL",
  "patientCondition": "Multiple trauma",
  "deadlineMinutes": 30
}
```

### Donor Accepts Request
```http
POST /api/v1/responses/{requestId}/accept
Content-Type: application/json
Authorization: Bearer {jwt_token}

{
  "donorId": "donor-99",
  "canArriveInMinutes": 25
}
```

## 🔐 Security

- JWT-based authentication
- OAuth2 integration
- Role-based access control (RBAC)
- HIPAA compliance
- AES-256 encryption for sensitive data
- TLS 1.3 for all communications

## 🧪 Testing

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=RequestServiceTest

# Run with coverage
mvn test jacoco:report

# Integration tests
mvn verify
```

## 📚 Documentation

- **[LIFEFLOW_ARCHITECTURE.md](docs/LIFEFLOW_ARCHITECTURE.md)** - System design
- **[EMERGENCY_WORKFLOW_SEQUENCE.md](docs/EMERGENCY_WORKFLOW_SEQUENCE.md)** - Detailed workflows
- **[DATABASE_SCHEMAS.md](database/SCHEMAS.md)** - ER diagrams & SQL
- **[API_REFERENCE.md](docs/API_REFERENCE.md)** - REST endpoints (to be created)
- **[DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md)** - K8s setup (to be created)

## 🚀 Deployment

### Local Development
```bash
docker-compose -f docker-compose.yml up -d
```

### Build Docker Images
```bash
mvn clean package -DskipTests
docker-compose build
```

### Production (Kubernetes)
```bash
kubectl apply -f infrastructure/kubernetes/
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📞 Support

- Email: support@lifeflow.local
- Slack: #lifeflow-dev
- Issues: GitHub Issues

## 📄 License

MIT License - see [LICENSE](LICENSE)

---

**Built with ☕ Java Spring Boot for critical life-saving blood donations**
