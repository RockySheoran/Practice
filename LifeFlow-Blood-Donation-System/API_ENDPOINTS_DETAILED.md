# LifeFlow - Detailed API Endpoints

## 1. Identity Service API

**Base Path**: `/identity`

### User Management
```http
GET    /users/profile                    # Get current user profile
PUT    /users/profile                    # Update user profile
PATCH  /users/profile/avatar             # Update profile picture
GET    /users/{userId}                   # Get user by ID (admin only)
PUT    /users/{userId}                   # Update user by ID (admin only)
DELETE /users/{userId}                   # Delete user (admin only)
GET    /users                            # List users with pagination (admin only)
POST   /users/{userId}/activate          # Activate user account
POST   /users/{userId}/deactivate        # Deactivate user account
GET    /users/{userId}/sessions          # Get user active sessions
DELETE /users/{userId}/sessions/{sessionId} # Terminate specific session
```

#### Example: Get User Profile
```http
GET /api/v1/identity/users/profile
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

```json
{
  "success": true,
  "data": {
    "id": "usr_123456789",
    "username": "john.doe",
    "email": "john.doe@example.com",
    "phoneNumber": "+91-9876543210",
    "firstName": "John",
    "lastName": "Doe",
    "dateOfBirth": "1990-05-15",
    "gender": "MALE",
    "profileImageUrl": "https://cdn.lifeflow.com/avatars/usr_123456789.jpg",
    "roles": ["DONOR"],
    "permissions": ["donor:read", "donor:update", "request:read"],
    "isActive": true,
    "isVerified": true,
    "emailVerifiedAt": "2024-01-10T08:30:00Z",
    "phoneVerifiedAt": "2024-01-10T08:35:00Z",
    "lastLoginAt": "2024-01-15T10:30:00Z",
    "twoFactorEnabled": false,
    "createdAt": "2024-01-10T08:00:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  },
  "message": "Profile retrieved successfully",
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req_profile_123456"
}
```

### Role Management
```http
GET    /roles                            # List all roles
POST   /roles                            # Create new role (admin only)
GET    /roles/{roleId}                   # Get role details
PUT    /roles/{roleId}                   # Update role (admin only)
DELETE /roles/{roleId}                   # Delete role (admin only)
GET    /roles/{roleId}/permissions       # Get role permissions
POST   /roles/{roleId}/permissions       # Add permissions to role
DELETE /roles/{roleId}/permissions/{permissionId} # Remove permission from role
```

---

## 2. Donor Service API

**Base Path**: `/donors`

### Donor Registration & Profile Management
```http
POST   /register                         # Register new donor
GET    /profile                          # Get donor profile
PUT    /profile                          # Update donor profile
PATCH  /profile/medical                  # Update medical information
PATCH  /profile/preferences              # Update notification preferences
GET    /profile/eligibility              # Check donation eligibility
POST   /profile/health-screening         # Submit health screening
GET    /profile/statistics               # Get donor statistics
```

#### Example: Donor Registration
```http
POST /api/v1/donors/register
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "bloodType": "A_POSITIVE",
  "weight": 70.5,
  "height": 175.0,
  "medicalConditions": ["HYPERTENSION"],
  "currentMedications": ["Lisinopril 10mg"],
  "allergies": ["PENICILLIN"],
  "emergencyContact": {
    "name": "Jane Doe",
    "phoneNumber": "+91-9876543211",
    "relationship": "SPOUSE"
  },
  "address": {
    "streetAddress": "123 Main Street",
    "apartmentUnit": "Apt 4B",
    "city": "Mumbai",
    "state": "Maharashtra",
    "postalCode": "400001",
    "country": "India",
    "addressType": "HOME"
  },
  "preferences": {
    "preferredDonationTime": "MORNING",
    "notificationMethods": ["EMAIL", "SMS"],
    "emergencyAvailable": true,
    "preferredLanguage": "en"
  }
}
```

```json
{
  "success": true,
  "data": {
    "donorId": "DN001234",
    "userId": "usr_123456789",
    "bloodType": "A_POSITIVE",
    "eligibilityStatus": "PENDING",
    "nextEligibleDate": null,
    "totalDonations": 0,
    "totalPoints": 0,
    "registrationDate": "2024-01-15T10:30:00Z",
    "healthScreeningRequired": true,
    "nextSteps": [
      "Complete health screening questionnaire",
      "Schedule first donation appointment",
      "Verify emergency contact information"
    ]
  },
  "message": "Donor registration successful. Health screening required before first donation.",
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req_donor_reg_123456"
}
```

### Donation History & Management
```http
GET    /donations                        # Get donation history (paginated)
GET    /donations/{donationId}           # Get specific donation details
POST   /donations/schedule               # Schedule new donation
PUT    /donations/{donationId}/reschedule # Reschedule donation
DELETE /donations/{donationId}/cancel    # Cancel scheduled donation
GET    /donations/upcoming               # Get upcoming donations
GET    /donations/statistics             # Get donation statistics
POST   /donations/{donationId}/feedback  # Submit donation feedback
```

#### Example: Get Donation History
```http
GET /api/v1/donors/donations?page=1&size=10&sort=donationDate,desc&status=COMPLETED
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

```json
{
  "success": true,
  "data": {
    "donations": [
      {
        "id": "don_123456789",
        "donationId": "DON001234",
        "donationDate": "2024-01-10",
        "donationTime": "10:30:00",
        "locationType": "HOSPITAL",
        "locationName": "City General Hospital",
        "volumeCollected": 450,
        "bloodBagId": "BB001234567",
        "status": "COMPLETED",
        "preVitals": {
          "hemoglobin": 13.5,
          "bloodPressure": "120/80",
          "pulse": 72,
          "temperature": 98.6,
          "weight": 70.5
        },
        "postVitals": {
          "bloodPressure": "118/78",
          "pulse": 70
        },
        "pointsEarned": 100,
        "nextEligibleDate": "2024-04-10",
        "staffNotes": "Smooth donation process, no complications",
        "donorFeedback": "Great experience, staff was very professional"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 3,
      "totalElements": 25,
      "size": 10,
      "hasNext": true,
      "hasPrevious": false
    },
    "summary": {
      "totalDonations": 25,
      "totalVolumeContributed": 11250,
      "totalPointsEarned": 2750,
      "averageDonationInterval": 95,
      "lastDonationDate": "2024-01-10"
    }
  },
  "message": "Donation history retrieved successfully",
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req_donations_123456"
}
```

### Health Screening & Eligibility
```http
POST   /health-screening                 # Submit health screening
GET    /health-screening/latest          # Get latest screening results
GET    /health-screening/history         # Get screening history
GET    /eligibility/check                # Check current eligibility
GET    /eligibility/requirements         # Get eligibility requirements
POST   /eligibility/appeal               # Appeal eligibility decision
```

---

## 3. Hospital Service API

**Base Path**: `/hospitals`

### Hospital Registration & Management
```http
POST   /register                         # Register new hospital
GET    /profile                          # Get hospital profile
PUT    /profile                          # Update hospital profile
GET    /profile/verification-status      # Get verification status
POST   /profile/submit-verification      # Submit verification documents
GET    /certifications                   # Get hospital certifications
POST   /certifications                   # Add new certification
PUT    /certifications/{certId}          # Update certification
DELETE /certifications/{certId}          # Remove certification
```

#### Example: Hospital Registration
```http
POST /api/v1/hospitals/register
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "name": "City General Hospital",
  "hospitalType": "PUBLIC",
  "specialization": ["CARDIOLOGY", "ONCOLOGY", "EMERGENCY"],
  "licenseNumber": "HSP-MH-2024-001234",
  "registrationNumber": "REG-MH-001234",
  "accreditationLevel": "NABH",
  "bedCapacity": 500,
  "icuBeds": 50,
  "emergencyBeds": 25,
  "operationTheaters": 12,
  "emergencyServices": true,
  "traumaCenterLevel": "LEVEL_1",
  "bloodBankLicense": "BB-MH-001234",
  "bloodBankCapacity": 1000,
  "hasComponentSeparation": true,
  "hasApheresisFacility": true,
  "address": {
    "streetAddress": "456 Hospital Road",
    "landmark": "Near Central Railway Station",
    "city": "Mumbai",
    "district": "Mumbai City",
    "state": "Maharashtra",
    "postalCode": "400001",
    "country": "India"
  },
  "contacts": [
    {
      "contactType": "MAIN",
      "phoneNumber": "+91-22-12345678",
      "email": "info@citygeneralhospital.com",
      "contactPerson": "Dr. Rajesh Kumar",
      "designation": "Medical Superintendent",
      "available24x7": true
    },
    {
      "contactType": "BLOOD_BANK",
      "phoneNumber": "+91-22-12345679",
      "email": "bloodbank@citygeneralhospital.com",
      "contactPerson": "Dr. Priya Sharma",
      "designation": "Blood Bank Officer",
      "available24x7": true
    }
  ],
  "operatingHours": {
    "monday": {"open": "00:00", "close": "23:59"},
    "tuesday": {"open": "00:00", "close": "23:59"},
    "wednesday": {"open": "00:00", "close": "23:59"},
    "thursday": {"open": "00:00", "close": "23:59"},
    "friday": {"open": "00:00", "close": "23:59"},
    "saturday": {"open": "00:00", "close": "23:59"},
    "sunday": {"open": "00:00", "close": "23:59"}
  },
  "websiteUrl": "https://www.citygeneralhospital.com",
  "establishedYear": 1985
}
```

### Staff Management
```http
GET    /staff                            # List hospital staff
POST   /staff                            # Add staff member
GET    /staff/{staffId}                  # Get staff details
PUT    /staff/{staffId}                  # Update staff member
DELETE /staff/{staffId}                  # Remove staff member
POST   /staff/{staffId}/activate         # Activate staff member
POST   /staff/{staffId}/deactivate       # Deactivate staff member
GET    /staff/departments                # Get staff by department
```

### Department Management
```http
GET    /departments                      # List departments
POST   /departments                      # Create new department
GET    /departments/{deptId}             # Get department details
PUT    /departments/{deptId}             # Update department
DELETE /departments/{deptId}             # Delete department
GET    /departments/{deptId}/staff       # Get department staff
```

### Inventory Thresholds
```http
GET    /inventory/thresholds             # Get inventory thresholds
PUT    /inventory/thresholds             # Update inventory thresholds
GET    /inventory/thresholds/{bloodType} # Get specific blood type threshold
PUT    /inventory/thresholds/{bloodType} # Update specific threshold
```

---

## 4. Request Service API

**Base Path**: `/requests`

### Blood Request Management
```http
POST   /                                 # Create new blood request
GET    /                                 # List blood requests (paginated)
GET    /{requestId}                      # Get specific request details
PUT    /{requestId}                      # Update request
PATCH  /{requestId}/priority             # Update request priority
DELETE /{requestId}                      # Cancel request
GET    /{requestId}/status               # Get request status
GET    /{requestId}/timeline             # Get request timeline
```

#### Example: Create Blood Request
```http
POST /api/v1/requests
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "patientId": "PAT-2024-001234",
  "bloodType": "O_NEGATIVE",
  "componentType": "PACKED_RBC",
  "quantityNeeded": 3,
  "urgencyLevel": "URGENT",
  "medicalCondition": "Acute Blood Loss - Post Surgical",
  "surgeryDate": "2024-01-16T14:00:00Z",
  "requiredBy": "2024-01-16T12:00:00Z",
  "specialRequirements": [
    "CMV_NEGATIVE",
    "IRRADIATED"
  ],
  "patientDetails": {
    "age": 45,
    "gender": "MALE",
    "weight": 75.0,
    "diagnosis": "Gastrointestinal bleeding",
    "currentHemoglobin": 6.5,
    "bloodPressure": "90/60",
    "isPregnant": false
  },
  "requestingPhysician": {
    "name": "Dr. Amit Patel",
    "licenseNumber": "MH-12345",
    "department": "SURGERY",
    "contactNumber": "+91-9876543210"
  },
  "notes": "Patient requires immediate transfusion due to ongoing bleeding. Cross-match compatibility essential."
}
```

```json
{
  "success": true,
  "data": {
    "requestId": "REQ-2024-001234",
    "id": "req_123456789",
    "status": "PENDING",
    "priority": "URGENT",
    "estimatedFulfillmentTime": "2024-01-16T10:30:00Z",
    "matchingResults": {
      "inventoryMatches": 1,
      "nearbyDonorsNotified": 25,
      "compatibleDonorsInRadius": 45
    },
    "timeline": [
      {
        "timestamp": "2024-01-15T10:30:00Z",
        "event": "REQUEST_CREATED",
        "description": "Blood request created and submitted for processing"
      },
      {
        "timestamp": "2024-01-15T10:31:00Z",
        "event": "INVENTORY_CHECKED",
        "description": "Inventory checked - 1 compatible unit found"
      },
      {
        "timestamp": "2024-01-15T10:32:00Z",
        "event": "DONORS_NOTIFIED",
        "description": "25 compatible donors notified within 10km radius"
      }
    ],
    "nextSteps": [
      "Awaiting donor responses",
      "Preparing available inventory unit",
      "Cross-match testing scheduled"
    ]
  },
  "message": "Blood request created successfully. Donors have been notified.",
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req_create_123456"
}
```

### Emergency Requests
```http
POST   /emergency                        # Create emergency request
GET    /emergency                        # List emergency requests
PUT    /emergency/{requestId}/escalate   # Escalate request priority
POST   /emergency/{requestId}/broadcast  # Broadcast to wider donor network
GET    /emergency/statistics             # Get emergency response statistics
```

### Request Fulfillment
```http
GET    /{requestId}/fulfillments         # Get request fulfillments
POST   /{requestId}/fulfillments         # Add fulfillment record
PUT    /{requestId}/fulfillments/{fulfillmentId} # Update fulfillment
GET    /{requestId}/donors               # Get matched donors
POST   /{requestId}/donors/{donorId}/notify # Notify specific donor
```

### Donor Matching & Notifications
```http
GET    /{requestId}/matches              # Get donor matches
POST   /{requestId}/matches/refresh      # Refresh donor matching
GET    /{requestId}/notifications        # Get notification history
POST   /{requestId}/notifications/resend # Resend notifications
GET    /{requestId}/responses            # Get donor responses
```

---

## 5. Inventory Service API

**Base Path**: `/inventory`

### Blood Bag Management
```http
POST   /blood-bags                       # Register new blood bag
GET    /blood-bags                       # List blood bags (paginated)
GET    /blood-bags/{bagId}               # Get blood bag details
PUT    /blood-bags/{bagId}               # Update blood bag status
PATCH  /blood-bags/{bagId}/location      # Update blood bag location
DELETE /blood-bags/{bagId}               # Mark blood bag as discarded
GET    /blood-bags/{bagId}/history       # Get blood bag movement history
POST   /blood-bags/{bagId}/test          # Record quality test
GET    /blood-bags/expiring              # Get expiring blood bags
POST   /blood-bags/batch-update          # Batch update blood bags
```

#### Example: Register Blood Bag
```http
POST /api/v1/inventory/blood-bags
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "bagId": "BB-2024-001234567",
  "batchNumber": "BATCH-2024-001",
  "donorId": "DN001234",
  "donationId": "DON001234",
  "bloodType": "A_POSITIVE",
  "rhFactor": "POSITIVE",
  "collectionDate": "2024-01-15",
  "collectionTime": "10:30:00",
  "collectionLocationId": "HSP001",
  "collectionLocationName": "City General Hospital",
  "volumeMl": 450,
  "bagType": "WHOLE_BLOOD",
  "expiryDate": "2024-02-19",
  "currentLocationId": "LOC-BB-001",
  "storageTemperature": 4.0,
  "qualityTests": {
    "hiv": "PENDING",
    "hbv": "PENDING",
    "hcv": "PENDING",
    "syphilis": "PENDING",
    "aboGrouping": "CONFIRMED",
    "rhTyping": "CONFIRMED"
  },
  "processingNotes": "Standard collection procedure followed. No complications observed."
}
```

### Stock Management
```http
GET    /stock                            # Get current stock levels
GET    /stock/summary                    # Get stock summary by blood type
GET    /stock/alerts                     # Get stock alerts
POST   /stock/reserve                    # Reserve blood for request
POST   /stock/release                    # Release reserved blood
GET    /stock/movements                  # Get stock movements
GET    /stock/forecast                   # Get stock level forecast
POST   /stock/adjustment                 # Manual stock adjustment
```

#### Example: Get Stock Levels
```http
GET /api/v1/inventory/stock?location=HSP001&includeReserved=true
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

```json
{
  "success": true,
  "data": {
    "locationId": "HSP001",
    "locationName": "City General Hospital Blood Bank",
    "lastUpdated": "2024-01-15T10:30:00Z",
    "stockLevels": [
      {
        "bloodType": "A_POSITIVE",
        "componentType": "WHOLE_BLOOD",
        "totalStock": 25,
        "availableStock": 20,
        "reservedStock": 5,
        "minimumThreshold": 10,
        "criticalThreshold": 5,
        "status": "ADEQUATE",
        "daysOfSupply": 12,
        "expiringIn7Days": 2,
        "expiringIn3Days": 0
      },
      {
        "bloodType": "O_NEGATIVE",
        "componentType": "PACKED_RBC",
        "totalStock": 3,
        "availableStock": 1,
        "reservedStock": 2,
        "minimumThreshold": 15,
        "criticalThreshold": 5,
        "status": "CRITICAL",
        "daysOfSupply": 1,
        "expiringIn7Days": 1,
        "expiringIn3Days": 1
      }
    ],
    "summary": {
      "totalUnits": 156,
      "totalAvailable": 134,
      "totalReserved": 22,
      "criticalTypes": ["O_NEGATIVE", "AB_NEGATIVE"],
      "expiringIn7Days": 8,
      "expiringIn3Days": 3,
      "expiringToday": 0
    },
    "alerts": [
      {
        "type": "CRITICAL_STOCK",
        "bloodType": "O_NEGATIVE",
        "message": "O_NEGATIVE stock critically low - only 1 unit available",
        "severity": "HIGH",
        "recommendedAction": "Initiate emergency donor recruitment"
      }
    ]
  },
  "message": "Stock levels retrieved successfully",
  "timestamp": "2024-01-15T10:30:00Z",
  "requestId": "req_stock_123456"
}
```

### Quality Testing
```http
GET    /quality-tests                    # List quality tests
POST   /quality-tests                    # Record new test
GET    /quality-tests/{testId}           # Get test details
PUT    /quality-tests/{testId}           # Update test results
GET    /quality-tests/pending            # Get pending tests
GET    /quality-tests/failed             # Get failed tests
POST   /quality-tests/batch              # Batch test recording
```

### Storage Locations
```http
GET    /locations                        # List storage locations
POST   /locations                        # Create new location
GET    /locations/{locationId}           # Get location details
PUT    /locations/{locationId}           # Update location
DELETE /locations/{locationId}           # Delete location
GET    /locations/{locationId}/capacity  # Get location capacity
GET    /locations/{locationId}/temperature # Get temperature logs
```

### Alerts & Monitoring
```http
GET    /alerts                           # Get inventory alerts
POST   /alerts/{alertId}/acknowledge     # Acknowledge alert
POST   /alerts/{alertId}/resolve         # Resolve alert
GET    /alerts/statistics                # Get alert statistics
POST   /alerts/test                      # Test alert system
```

---

## Common Query Parameters

### Pagination
```
?page=1&size=20&sort=createdAt,desc
?page=2&size=50&sort=name,asc&sort=createdAt,desc
```

### Filtering
```
?bloodType=A_POSITIVE,O_NEGATIVE&status=ACTIVE&city=Mumbai
?startDate=2024-01-01&endDate=2024-01-31
?urgencyLevel=CRITICAL,URGENT
```

### Search
```
?search=john&searchFields=firstName,lastName,email
?q=blood+bank&searchType=fuzzy
```

### Field Selection
```
?fields=id,name,email,createdAt
?exclude=password,internalNotes
```

### Include Related Data
```
?include=address,preferences,donations
?expand=hospital,donor,bloodBag
```

## Rate Limiting

### Standard Limits
- **Authenticated Users**: 1000 requests/hour, 100 requests/minute
- **Emergency Endpoints**: 500 requests/hour, 50 requests/minute  
- **Bulk Operations**: 100 requests/hour, 10 requests/minute
- **Anonymous Users**: 100 requests/hour, 10 requests/minute
- **Search Endpoints**: 200 requests/hour, 20 requests/minute

### Rate Limit Headers
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1642248000
X-RateLimit-Retry-After: 3600
```

## Security & Authentication

### Required Headers
```http
Authorization: Bearer <jwt-access-token>
Content-Type: application/json
X-Request-ID: <unique-request-id>
X-API-Version: v1
X-Client-Version: 1.2.3
```

### Optional Headers
```http
X-Correlation-ID: <correlation-id>
X-User-Agent: LifeFlow-Mobile/1.2.3
X-Device-ID: <device-identifier>
Accept-Language: en-US,en;q=0.9
```

### Response Headers
```http
X-Response-Time: 150ms
X-Service-Name: donor-service
X-Correlation-ID: <correlation-id>
X-Request-ID: <request-id>
Cache-Control: no-cache, no-store, must-revalidate
```

This comprehensive API specification provides detailed endpoints for all major operations in the LifeFlow blood donation management system, with proper request/response examples, error handling, and security considerations.