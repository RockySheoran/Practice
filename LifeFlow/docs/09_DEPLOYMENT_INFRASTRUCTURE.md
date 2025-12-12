# Deployment & Infrastructure Architecture for LifeFlow

## 1. Deployment Environments

### Development (Local Machine)
```
Components:
├─ Docker Compose: All services in containers
├─ PostgreSQL: Single instance (shared databases)
├─ RabbitMQ: Single instance
├─ Redis: Single instance
├─ Keycloak: Authentication server
├─ Mailhog: Email testing
└─ Portainer: Docker GUI (optional)

Specifications:
├─ CPU: 4 cores
├─ RAM: 8GB
├─ Storage: 50GB
├─ Network: localhost only

Startup time: ~5 minutes
Used for: Development, testing, integration
```

### Staging (Pre-Production)
```
Environment: AWS / Google Cloud

Components:
├─ EKS Cluster (3 nodes, 2 CPU, 4GB each)
├─ RDS PostgreSQL (db.t3.medium, 20GB)
├─ ElastiCache Redis (cache.t3.micro)
├─ RabbitMQ: Managed service or self-hosted
├─ ELB (Elastic Load Balancer)
├─ CloudWatch for monitoring
├─ S3 for backups
└─ NAT Gateway for outbound internet

Auto-Scaling:
├─ Min replicas: 2
├─ Max replicas: 5
├─ Scale up trigger: CPU > 70% or memory > 80%
├─ Scale down trigger: CPU < 30% (after 5 minutes)

Specifications:
├─ Region: Same as production (for testing)
├─ Data: 20% of production (PII masked)
├─ Availability: Single zone (cost optimization)

Used for: Performance testing, load testing, UAT
```

### Production (Live)
```
Environment: AWS / Google Cloud with HA

Components:
├─ EKS Cluster Multi-AZ (9 nodes across 3 AZs, 4 CPU, 8GB each)
├─ RDS PostgreSQL Multi-AZ (db.r5.large, 500GB, automated backups)
├─ ElastiCache Redis (cache.r5.large, cluster mode enabled)
├─ Managed RabbitMQ or Apache Kafka
├─ Application Load Balancer (ALB) with WAF
├─ CloudFront CDN for static assets
├─ CloudWatch + Datadog for monitoring
├─ S3 for backups and disaster recovery
├─ Route53 for DNS
└─ Secrets Manager for credentials

Auto-Scaling:
├─ Min replicas: 3 (per service)
├─ Max replicas: 20 (per service)
├─ Scale up trigger: CPU > 70% or request queue > 100
├─ Scale down trigger: CPU < 40% (after 10 minutes)

Specifications:
├─ Regions: Primary + Failover region
├─ Availability Zones: 3 per region
├─ Data redundancy: RPO = 5 minutes, RTO = 15 minutes
├─ Backup: Daily incremental, monthly full
└─ DR site: Ready for failover within 15 minutes

Used for: Production traffic, 99.99% SLA
```

---

## 2. Kubernetes Architecture

### Cluster Setup

```
EKS Cluster (Production):

┌─────────────────────────────────────────────────┐
│         AWS Availability Zone A                  │
│  ┌────────────────────────────────────────────┐ │
│  │ EC2 Node 1 (t3.xlarge)                     │ │
│  │ ├─ Donor Service (Replica 1)               │ │
│  │ ├─ Request Service (Replica 1)             │ │
│  │ ├─ Notification Service (Replica 1)        │ │
│  │ └─ Prometheus Agent                        │ │
│  └────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────┐ │
│  │ EC2 Node 2 (t3.xlarge)                     │ │
│  │ ├─ Donor Service (Replica 2)               │ │
│  │ ├─ Inventory Service (Replica 1)           │ │
│  │ ├─ Analytics Service (Replica 1)           │ │
│  │ └─ Prometheus Agent                        │ │
│  └────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────┐ │
│  │ EC2 Node 3 (t3.xlarge)                     │ │
│  │ ├─ Request Service (Replica 2)             │ │
│  │ ├─ Geolocation Service (Replica 1)         │ │
│  │ ├─ Camp Service (Replica 1)                │ │
│  │ └─ Prometheus Agent                        │ │
│  └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘

Repeat for AZ B and AZ C (total 9 nodes)

Services per node:
├─ Resource limit: CPU 4, Memory 8GB
├─ Allocatable: ~70% (reserved for system)
├─ Usable: ~2.8 CPU, 5.6GB per node
└─ Total cluster: 25.2 CPU, 50.4GB available
```

### Pod Deployment Strategy

```
Deployment YAML Example:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: donor-service
  labels:
    app: donor-service
    version: v1
spec:
  replicas: 3  # Always 3 minimum in production
  selector:
    matchLabels:
      app: donor-service
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # One extra pod during update
      maxUnavailable: 0  # Always keep minimum running
  template:
    metadata:
      labels:
        app: donor-service
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8090"
    spec:
      affinity:
        # Spread pods across multiple nodes
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - donor-service
              topologyKey: kubernetes.io/hostname
      
      containers:
      - name: donor-service
        image: docker.io/lifeflow/donor-service:1.2.3
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8002
          name: http
        - containerPort: 8090
          name: metrics
        
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: donor-db-url
        - name: RABBITMQ_URL
          valueFrom:
            secretKeyRef:
              name: rabbitmq-secrets
              key: url
        
        resources:
          requests:
            cpu: "500m"      # Request 0.5 CPU
            memory: "512Mi"  # Request 512MB RAM
          limits:
            cpu: "1000m"     # Max 1 CPU
            memory: "1024Mi" # Max 1GB RAM
        
        livenessProbe:
          httpGet:
            path: /health
            port: 8002
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
        
        readinessProbe:
          httpGet:
            path: /ready
            port: 8002
          initialDelaySeconds: 20
          periodSeconds: 5
        
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 15"]  # Grace period before termination
```

---

## 3. Database Architecture

### PostgreSQL Setup (Multi-AZ)

```
Primary (us-east-1a):
├─ Instance: db.r5.large
├─ Storage: 500GB GP3
├─ Connections: 100
├─ Backups: Daily automated + continuous replication
└─ Multi-AZ: Synchronous replica in us-east-1b

Standby Replica (us-east-1b):
├─ Automatic failover: < 1 minute
├─ Read-Only: Can be used for read queries
└─ WAL streaming: Synchronous

Cross-Region Replica (us-west-1):
├─ Asynchronous replication (for DR)
├─ RPO: 5-10 minutes
└─ Failover: Manual (takes 15 minutes)

Backups:
├─ Automated: Every 6 hours, 30-day retention
├─ Manual: Before major deployments
├─ Location: S3 cross-region for DR
├─ Restore time: 10 minutes for any point-in-time
```

### Database Per Service

```
Service 1: Identity & Auth Service
└─ Database: lifeflow_auth_prod
   ├─ Tables: users, roles, sessions, oauth_clients, audit_logs
   ├─ Size: ~50GB
   ├─ Queries/sec: ~1000
   └─ Primary keys: SERIAL (id), UUIDs (user_id)

Service 2: Donor Service
└─ Database: lifeflow_donors_prod
   ├─ Tables: donors, medical_history, donations, preferences, etc.
   ├─ Size: ~200GB (due to large donor base)
   ├─ Queries/sec: ~2000
   └─ Indexes: (donor_id, created_at), (blood_type, status)

Service 3: Inventory & Blood Bank
└─ Database: lifeflow_inventory_prod
   ├─ Tables: blood_banks, inventory, bags, batches, locations
   ├─ Size: ~100GB
   ├─ Queries/sec: ~3000 (high during emergencies)
   └─ Indexes: (blood_type), (expiry_date), (status)

Service 4: Request & Emergency
└─ Database: lifeflow_requests_prod
   ├─ Tables: requests, alternatives, matching, fulfillment
   ├─ Size: ~150GB
   ├─ Queries/sec: ~2500 (varies with emergencies)
   └─ Indexes: (status), (urgency_level), (created_at)

Service 5: Geolocation & Logistics
└─ Database: lifeflow_geolocation_prod
   ├─ Tables: locations, tracking, routes, geofences
   ├─ Size: ~80GB
   ├─ Queries/sec: ~1500
   ├─ Spatial indexes: PostGIS indexes on coordinates
   └─ Redis caching: Live locations cached for 1 minute

Service 6: Notification Service
└─ Database: lifeflow_notifications_prod
   ├─ Tables: notifications, logs, templates, preferences
   ├─ Size: ~300GB (high volume of logs)
   ├─ Queries/sec: ~5000 (notification delivery spikes)
   └─ Indexes: (recipient_id), (created_at), (status)

Service 7: Camp & Event Service
└─ Database: lifeflow_camps_prod
   ├─ Tables: camps, registrations, volunteers, schedules
   ├─ Size: ~50GB
   ├─ Queries/sec: ~500
   └─ Indexes: (camp_id), (donor_id), (status)

Service 8: Analytics & Gamification
└─ Database: lifeflow_analytics_prod
   ├─ Tables: rewards, badges, leaderboards, donations_impact
   ├─ Size: ~250GB
   ├─ Queries/sec: ~1000
   ├─ Indexes: (donor_id), (leaderboard_type)
   └─ Materialized views: Pre-calculated leaderboards
```

---

## 4. Monitoring & Observability

### Prometheus Metrics Collection

```
Metrics Collected:

Application Metrics:
├─ Request count (per endpoint, method, status)
├─ Request duration (p50, p95, p99, p99.9)
├─ Error rate (5xx errors, 4xx errors)
├─ Active connections per service
├─ Database connection pool usage
├─ Cache hit rate (Redis)
└─ Message broker queue depth

Infrastructure Metrics:
├─ CPU usage per node
├─ Memory usage per node
├─ Disk I/O operations
├─ Network throughput
├─ Pod restart count
└─ Node health status

Database Metrics:
├─ Query execution time (slow query log)
├─ Connection count
├─ Transaction count
├─ Index hit ratio
├─ Replication lag
└─ Backup status

Custom Business Metrics:
├─ Blood requests per minute
├─ Fulfillment time average
├─ Donors online (active sessions)
├─ Blood wastage rate
├─ Lives saved estimate
└─ Emergency response time
```

### Alerting Rules

```
Critical Alerts (Page on-call immediately):
├─ Service down: No responses for 2 minutes
├─ Error rate > 5%: For 5 consecutive minutes
├─ Request latency p99 > 10 seconds: For 5 minutes
├─ Database connection pool exhausted
├─ Pod crash loop (> 3 restarts in 10 minutes)
├─ Disk usage > 90%
├─ Message broker queue backup > 10,000 messages
└─ Blood shortage incident detected

High Priority Alerts:
├─ Error rate > 1%: For 10 minutes
├─ Request latency p99 > 5 seconds: For 10 minutes
├─ Pod pending: For > 5 minutes
├─ Replication lag > 30 seconds
├─ Cache hit rate < 50%
└─ Emergency request fulfillment > 20 minutes

Medium Priority Alerts:
├─ Deployment failure
├─ Certificate expiry in 30 days
├─ Backup job failed
├─ Disk usage > 80%
└─ Memory usage > 85%

Notification Channels:
├─ Critical: SMS + Slack + PagerDuty
├─ High: Slack + Email
├─ Medium: Email + Dashboard
└─ Info: Dashboard only
```

### Logging Architecture

```
Log Collection:

Filebeat (Log Shipper):
├─ Runs on every node
├─ Collects logs from /var/log/containers/
├─ Parses JSON logs from applications
└─ Ships to Elasticsearch

Elasticsearch:
├─ Cluster: 3 nodes for redundancy
├─ Shards: 5 per index (parallelism)
├─ Retention: 30 days hot, 90 days archive
├─ Indices: Daily rollover (one per day)
└─ Backup: Snapshots to S3

Kibana (Visualization):
├─ Log search and analysis
├─ Pre-built dashboards per service
├─ Alert configuration
└─ Performance analytics

Log Format (JSON):
{
  "timestamp": "2024-01-15T10:30:00.123Z",
  "level": "INFO",
  "logger": "DonorService",
  "service": "donor-service",
  "pod": "donor-service-abc123",
  "host": "node-2",
  "correlation_id": "uuid-12345",
  "user_id": "donor_123",
  "message": "Donation recorded successfully",
  "donation_id": "D-001",
  "duration_ms": 45,
  "tags": ["donation", "success"],
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736"
}
```

---

## 5. Disaster Recovery

### Backup Strategy

```
Daily Backups:
├─ Time: 02:00 UTC (off-peak)
├─ Duration: ~30 minutes
├─ Type: Automated PostgreSQL backups
├─ Location: AWS S3 us-east-1 (primary), us-west-1 (secondary)
├─ Retention: 30 days
└─ Verification: Weekly restore test in staging

Monthly Backups:
├─ Full database dump
├─ Archives to Glacier (cheaper long-term storage)
├─ Retention: 7 years (compliance)

Pre-Deployment Backup:
├─ Triggered before major deployments
├─ Full database snapshot
├─ Kept for 30 days (immediate rollback)
└─ Labeled with deployment version
```

### Failover Procedure

```
Scenario: Primary region (us-east-1) goes down

Automatic Failover (RTO: 1 minute):
├─ Health check fails for primary region
├─ Route53 health check triggers
├─ Traffic automatically routed to secondary region (us-west-1)
├─ Users experience brief latency increase (geo-switch)
└─ Database reads fail over to read-replica in secondary region

Database Failover:
├─ Primary (us-east-1a) is down
├─ RDS multi-AZ: Promotes us-east-1b to primary (< 1 minute)
├─ Cross-region replica (us-west-1): User-initiated promotion (5 minutes)
├─ Data loss: < 5 minutes (RPO)

Manual Failover Steps:
1. Declare disaster (P1 severity)
2. Promote us-west-1 read replica to primary
3. Update Route53 DNS to point to us-west-1
4. Redirect traffic via CDN to us-west-1
5. Monitor metrics for stability
6. Once stable, handle writes to new primary
7. RTO: 15 minutes, RPO: 5 minutes

Post-Incident:
├─ Investigate root cause
├─ Update runbooks
├─ Post-mortem meeting
├─ Practice failover monthly
└─ Update infrastructure documentation
```

---

## 6. CI/CD Pipeline

### Deployment Workflow

```
Developer commits code to GitHub:
  ↓
GitHub Webhook → Jenkins/GitLab CI triggers
  ↓
Build Stage:
  ├─ Clone repository
  ├─ Build Java artifact (Maven)
  ├─ Run unit tests
  ├─ Run integration tests
  └─ Build Docker image
  ↓
Push Docker Image:
  ├─ Tag: latest + git commit hash
  ├─ Push to ECR (AWS Elastic Container Registry)
  └─ Trigger downstream pipelines
  ↓
Deploy to Staging:
  ├─ Kubernetes deployment: Staging cluster
  ├─ Rolling update: 1 pod at a time
  ├─ Run smoke tests
  ├─ Run load tests
  └─ Notify team (Slack)
  ↓
Manual Approval:
  ├─ Team lead approves deployment to production
  ├─ Merge request review (2 approvals minimum)
  └─ Ready for production release
  ↓
Deploy to Production:
  ├─ Kubernetes deployment: Production cluster
  ├─ Canary deployment: 10% traffic to new version
  ├─ Monitor metrics for 5 minutes
  ├─ If OK: Proceed to 50% traffic
  ├─ Monitor for 5 minutes
  ├─ If OK: Roll out to 100%
  ├─ If issues: Auto-rollback to previous version
  └─ Deployment complete

Total time: ~15 minutes (from commit to production)
```

