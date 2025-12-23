# LifeFlow - Comprehensive API Specifications

## API Design Principles

### RESTful Design
- Resource-based URLs with clear hierarchies
- HTTP methods for operations (GET, POST, PUT, PATCH, DELETE)
- Stateless communication with JWT tokens
- Consistent response formats across all services
- HATEOAS (Hypermedia as the Engine of Application State) support

### API Versioning
- URL path versioning: `/api/v1/`, `/api/v2/`
- Backward compatibility maintained for at least 2 major versions
- Deprecation notices with 6-month advance warning
- Version-specific documentation and SDKs

### Standard Response Format
```json
{
  "success": true,
  "data": {},
  "message": "Operation completed successfully",
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req_123456789",
  "version": "v1",
  "links": {
    "self": "/api/v1/resource/123",
    "related": "/api/v1/resource/123/related"
  }
}
```

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data provided",
    "details": [
      {
        "field": "bloodType",
        "message": "Blood type is required and must be one of: A_POSITIVE, A_NEGATIVE, B_POSITIVE, B_NEGATIVE, AB_POSITIVE, AB_NEGATIVE, O_POSITIVE, O_NEGATIVE",
        "rejectedValue": "AB+"
      }
    ],
    "documentation": "https://docs.lifeflow.com/errors/validation-error"
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req_123456789",
  "path": "/api/v1/donors/register"
}
```

### HTTP Status Codes

#### Success Codes
- `200 OK` - Successful GET, PUT, PATCH requests
- `201 Created` - Successful POST requests with resource creation
- `202 Accepted` - Request accepted for asynchronous processing
- `204 No Content` - Successful DELETE requests or updates with no response body

#### Client Error Codes
- `400 Bad Request` - Invalid request syntax or data
- `401 Unauthorized` - Authentication required or invalid credentials
- `403 Forbidden` - Insufficient permissions for the requested operation
- `404 Not Found` - Requested resource does not exist
- `405 Method Not Allowed` - HTTP method not supported for this endpoint
- `409 Conflict` - Resource conflict (e.g., duplicate email)
- `422 Unprocessable Entity` - Valid syntax but semantic validation errors
- `429 Too Many Requests` - Rate limit exceeded

#### Server Error Codes
- `500 Internal Server Error` - Unexpected server error
- `502 Bad Gateway` - Upstream service unavailable
- `503 Service Unavailable` - Service temporarily unavailable
- `504 Gateway Timeout` - Upstream service timeout

## API Gateway Endpoints

**Base URL**: `https://api.lifeflow.com/api/v1`

### Authentication & Authorization

#### Authentication Endpoints
```http
POST   /auth/register                    # User registration
POST   /auth/login                       # User login
POST   /auth/refresh                     # Refresh access token
POST   /auth/logout                      # User logout
POST   /auth/forgot-password             # Request password reset
POST   /auth/reset-password              # Reset password with token
POST   /auth/verify-email                # Verify email address
POST   /auth/resend-verification         # Resend verification email
POST   /auth/change-password             # Change password (authenticated)
POST   /auth/enable-2fa                  # Enable two-factor authentication
POST   /auth/disable-2fa                 # Disable two-factor authentication
POST   /auth/verify-2fa                  # Verify 2FA token
```

#### Example: User Registration
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+91-9876543210",
  "password": "SecurePassword123!",
  "dateOfBirth": "1990-05-15",
  "gender": "MALE",
  "role": "DONOR",
  "acceptTerms": true,
  "acceptPrivacyPolicy": true
}
```

```json
{
  "success": true,
  "data": {
    "userId": "usr_123456789",
    "email": "john.doe@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "DONOR",
    "isVerified": false,
    "verificationEmailSent": true
  },
  "message": "Registration successful. Please check your email for verification.",
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req_reg_123456"
}
```

#### Example: User Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "password": "SecurePassword123!",
  "rememberMe": true,
  "deviceInfo": {
    "deviceType": "WEB",
    "browser": "Chrome",
    "os": "Windows 10"
  }
}
```

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "rt_abcdef123456...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": "usr_123456789",
      "email": "john.doe@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "roles": ["DONOR"],
      "permissions": ["donor:read", "donor:update", "request:read"],
      "lastLoginAt": "2024-01-15T10:30:00Z"
    }
  },
  "message": "Login successful",
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req_login_123456"
}
```

## Service-Specific API Endpoints

### 1. Identity Service API

**Base Path**: `/identity`

#### User Management
```
GET    /users/profile              # Get current user profile
PUT    /users/profile              # Update user profile
GET    /users/{userId}             # Get user by ID (admin only)
DELETE /users/{userId}             # Delete user (admin only)
```

#### Role Management
```
GET    /roles                      # List all roles
POST   /roles                      # Create new role (admin only)
PUT    /roles/{roleId}             # Update role (admin only)
DELETE /roles/{roleId}             # Delete role (admin only)
```

#### Example Request/Response:
```json
// GET /identity/users/profile
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "john.doe",
    "email": "john@example.com",
    "phoneNumber": "+1234567890",
    "roles": ["DONOR"],
    "isActive": true,
    "isVerified": true,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

### 2. Donor Service API

**Base Path**: `/donors`

#### Donor Management
```
POST   /register                   # Register new donor
GET    /profile                    # Get donor profile
PUT    /profile                    # Update donor profile
GET    /eligibility                # Check donation eligibility
POST   /health-screening           # Submit health screening
```

#### Donation History
```
GET    /donations                  # Get donation history (paginated)
GET    /donations/{donationId}     # Get specific donation details
POST   /donations                  # Record new donation
```

#### Example Request/Response:
```json
// POST /donors/register
{
  "bloodType": "A_POSITIVE",
  "dateOfBirth": "1990-01-01",
  "gender": "MALE",
  "weight": 70.5,
  "height": 175.0,
  "address": {
    "street": "123 Main St",
    "city": "New York",
    "state": "NY",
    "postalCode": "10001",
    "country": "USA"
  },
  "emergencyContact": {
    "name": "Jane Doe",
    "phone": "+1234567890",
    "relationship": "Spouse"
  }
}

// Response
{
  "success": true,
  "data": {
    "id": "donor-uuid",
    "bloodType": "A_POSITIVE",
    "eligibilityStatus": "ELIGIBLE",
    "nextEligibleDate": null,
    "totalDonations": 0
  },
  "message": "Donor registered successfully"
}
```

### 3. Hospital Service API

**Base Path**: `/hospitals`

#### Hospital Management
```
POST   /register                   # Register new hospital
GET    /profile                    # Get hospital profile
PUT    /profile                    # Update hospital profile
GET    /staff                      # List hospital staff
POST   /staff                      # Add staff member
PUT    /staff/{staffId}            # Update staff member
DELETE /staff/{staffId}            # Remove staff member
```

#### Inventory Management
```
GET    /inventory                  # Get current blood inventory
PUT    /inventory                  # Update inventory levels
GET    /inventory/alerts           # Get low stock alerts
```

### 4. Request Service API

**Base Path**: `/requests`

#### Blood Request Management
```
POST   /                          # Create new blood request
GET    /                          # List blood requests (paginated)
GET    /{requestId}               # Get specific request details
PUT    /{requestId}               # Update request
DELETE /{requestId}               # Cancel request
```

#### Emergency Requests
```
POST   /emergency                 # Create emergency request
GET    /emergency                 # List emergency requests
PUT    /emergency/{requestId}/escalate # Escalate request priority
```

#### Example Request/Response:
```json
// POST /requests/emergency
{
  "patientId": "anonymous-patient-123",
  "bloodType": "O_NEGATIVE",
  "quantityNeeded": 2,
  "urgencyLevel": "CRITICAL",
  "medicalCondition": "Trauma - Motor Vehicle Accident",
  "surgeryDate": "2024-01-15T14:00:00Z",
  "notes": "Patient requires immediate transfusion"
}

// Response
{
  "success": true,
  "data": {
    "id": "request-uuid",
    "status": "PENDING",
    "estimatedFulfillmentTime": "2024-01-15T12:30:00Z",
    "nearbyDonorsNotified": 15,
    "availableInventory": 0
  },
  "message": "Emergency request created and donors notified"
}
```

### 5. Inventory Service API

**Base Path**: `/inventory`

#### Blood Bag Management
```
POST   /blood-bags                # Register new blood bag
GET    /blood-bags                # List blood bags (paginated)
GET    /blood-bags/{bagId}        # Get blood bag details
PUT    /blood-bags/{bagId}        # Update blood bag status
DELETE /blood-bags/{bagId}        # Mark blood bag as discarded
```

#### Stock Management
```
GET    /stock                     # Get current stock levels
GET    /stock/alerts              # Get expiry and low stock alerts
POST   /stock/reserve             # Reserve blood for request
POST   /stock/release             # Release reserved blood
```

#### Example Request/Response:
```json
// GET /inventory/stock
{
  "success": true,
  "data": {
    "stockLevels": [
      {
        "bloodType": "A_POSITIVE",
        "currentStock": 25,
        "reservedStock": 5,
        "availableStock": 20,
        "minimumThreshold": 10,
        "status": "ADEQUATE"
      },
      {
        "bloodType": "O_NEGATIVE",
        "currentStock": 3,
        "reservedStock": 2,
        "availableStock": 1,
        "minimumThreshold": 15,
        "status": "CRITICAL"
      }
    ],
    "totalUnits": 156,
    "expiringIn7Days": 8
  }
}
```

### 6. Geolocation Service API

**Base Path**: `/geolocation`

#### Location Management
```
POST   /locations                 # Register new location
GET    /locations/nearby          # Find nearby donors/hospitals
PUT    /locations/{locationId}    # Update location
GET    /distance                  # Calculate distance between points
```

#### Route Optimization
```
POST   /routes/optimize           # Optimize delivery route
GET    /routes/{routeId}          # Get route details
POST   /deliveries                # Start new delivery
PUT    /deliveries/{deliveryId}/track # Update delivery location
```

### 7. Notification Service API

**Base Path**: `/notifications`

#### Notification Management
```
POST   /send                      # Send notification
GET    /                          # List notifications (paginated)
GET    /{notificationId}          # Get notification details
PUT    /preferences               # Update notification preferences
```

#### Bulk Operations
```
POST   /bulk/send                 # Send bulk notifications
GET    /templates                 # List message templates
POST   /templates                 # Create message template
```

### 8. Camp Service API

**Base Path**: `/camps`

#### Camp Management
```
POST   /                          # Create new donation camp
GET    /                          # List camps (paginated)
GET    /{campId}                  # Get camp details
PUT    /{campId}                  # Update camp
DELETE /{campId}                  # Cancel camp
```

#### Registration Management
```
POST   /{campId}/register         # Register for camp
GET    /{campId}/registrations    # List camp registrations
PUT    /{campId}/registrations/{regId} # Update registration
DELETE /{campId}/registrations/{regId} # Cancel registration
```

### 9. Analytics Service API

**Base Path**: `/analytics`

#### Reports and Dashboards
```
GET    /dashboard                 # Get dashboard data
GET    /reports                   # List available reports
POST   /reports/generate          # Generate custom report
GET    /predictions               # Get demand predictions
```

#### Metrics
```
GET    /metrics/donations         # Donation metrics
GET    /metrics/requests          # Request fulfillment metrics
GET    /metrics/inventory         # Inventory turnover metrics
GET    /metrics/performance       # System performance metrics
```

### 10. Gamification Service API

**Base Path**: `/gamification`

#### Points and Badges
```
GET    /points                    # Get user points balance
GET    /badges                    # List earned badges
GET    /achievements              # List achievements
GET    /leaderboard               # Get leaderboard rankings
```

#### Rewards
```
GET    /rewards                   # List available rewards
POST   /rewards/{rewardId}/redeem # Redeem reward
GET    /redemptions               # List redemption history
```

## Common Query Parameters

### Pagination
```
?page=1&size=20&sort=createdAt,desc
```

### Filtering
```
?bloodType=A_POSITIVE&status=ACTIVE&city=NewYork
```

### Date Ranges
```
?startDate=2024-01-01&endDate=2024-01-31
```

## HTTP Status Codes

### Success Codes
- `200 OK` - Successful GET, PUT requests
- `201 Created` - Successful POST requests
- `204 No Content` - Successful DELETE requests

### Client Error Codes
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource conflict
- `422 Unprocessable Entity` - Validation errors

### Server Error Codes
- `500 Internal Server Error` - Server error
- `502 Bad Gateway` - Service unavailable
- `503 Service Unavailable` - Temporary unavailability

## Rate Limiting

### Standard Limits
- **Authenticated Users**: 1000 requests/hour
- **Emergency Endpoints**: 100 requests/minute
- **Bulk Operations**: 10 requests/minute
- **Anonymous Users**: 100 requests/hour

### Headers
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1642248000
```

## Security Headers

### Required Headers
```
Authorization: Bearer <jwt-token>
Content-Type: application/json
X-Request-ID: <uuid>
X-API-Version: v1
```

### Response Headers
```
X-Response-Time: 150ms
X-Service-Name: donor-service
X-Correlation-ID: <uuid>
```

## WebSocket APIs (Real-time Features)

### Emergency Notifications
```
ws://api.lifeflow.com/ws/emergency
```

### Delivery Tracking
```
ws://api.lifeflow.com/ws/tracking/{deliveryId}
```

### Live Dashboard Updates
```
ws://api.lifeflow.com/ws/dashboard
```

## API Testing

### Health Check Endpoints
```
GET /health                        # Overall system health
GET /{service}/health              # Service-specific health
GET /{service}/health/detailed     # Detailed health information
```

### Example Health Response
```json
{
  "status": "UP",
  "services": {
    "database": "UP",
    "kafka": "UP",
    "redis": "UP"
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0"
}
```