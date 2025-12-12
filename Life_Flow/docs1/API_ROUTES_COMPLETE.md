# API ROUTES COMPLETE

---

## 1. AUTHENTICATION ENDPOINTS

### Port: 3000 | Gateway Route: `/api/v1/auth/**`

#### User Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "yourpassword"
}

Response: 200 OK
{
  "accessToken": "your_access_token",
  "refreshToken": "your_refresh_token",
  "expiresIn": 3600
}
```

#### User Logout
```http
POST /api/v1/auth/logout
Authorization: Bearer {access_token}

Response: 204 No Content
```

#### Refresh Token
```http
POST /api/v1/auth/refresh
Authorization: Bearer {refresh_token}

Response: 200 OK
{
  "accessToken": "new_access_token",
  "expiresIn": 3600
}
```

---

## 2. USER MANAGEMENT ENDPOINTS

### Port: 3001 | Gateway Route: `/api/v1/users/**`

#### Register User
```http
POST /api/v1/users/register
Content-Type: application/json

{
  "username": "newuser",
  "email": "newuser@example.com",
  "password": "yourpassword",
  "role": "DONOR"
}

Response: 201 Created
{
  "userId": "user-001",
  "username": "newuser",
  "email": "newuser@example.com",
  "role": "DONOR",
  "status": "ACTIVE"
}
```

#### Get User Profile
```http
GET /api/v1/users/profile
Authorization: Bearer {access_token}

Response: 200 OK
{
  "userId": "user-001",
  "username": "newuser",
  "email": "newuser@example.com",
  "role": "DONOR",
  "status": "ACTIVE",
  "donorProfile": {
    "bloodType": "O_POSITIVE",
    "lastDonationDate": "2024-01-10",
    "totalDonations": 5
  }
}
```

#### Update User Profile
```http
PUT /api/v1/users/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "username": "updateduser",
  "email": "updateduser@example.com",
  "password": "newpassword"
}

Response: 200 OK
{
  "userId": "user-001",
  "username": "updateduser",
  "email": "updateduser@example.com",
  "role": "DONOR",
  "status": "ACTIVE"
}
```

#### Get All Users (Admin)
```http
GET /api/v1/users
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "content": [
    {
      "userId": "user-001",
      "username": "newuser",
      "email": "newuser@example.com",
      "role": "DONOR",
      "status": "ACTIVE"
    }
  ],
  "totalElements": 100
}
```

---

## 3. INVENTORY ENDPOINTS (Blood Bank Management)

### Port: 3003 | Gateway Route: `/api/v1/inventory/**`

#### Add Blood Bag
```http
POST /api/v1/inventory/bags
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "bloodType": "O_POSITIVE",
  "volume": 350,
  "donorId": "donor-001",
  "collectionDate": "2024-01-15",
  "expiryDate": "2024-07-15",
  "status": "AVAILABLE"
}

Response: 201 Created
{
  "bagId": "bag-001",
  "status": "AVAILABLE",
  "expiryDate": "2024-07-15"
}
```

#### Get Blood Bag Details
```http
GET /api/v1/inventory/bags/{bagId}
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "bagId": "bag-001",
  "bloodType": "O_POSITIVE",
  "volume": 350,
  "donorId": "donor-001",
  "collectionDate": "2024-01-15",
  "expiryDate": "2024-07-15",
  "status": "AVAILABLE",
  "temperatureLogs": [
    {
      "timestamp": "2024-01-15T14:00:00Z",
      "temperature": 4.5
    }
  ]
}
```

#### Update Blood Bag Details
```http
PUT /api/v1/inventory/bags/{bagId}
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "status": "UNAVAILABLE",
  "reason": "Bag damaged"
}

Response: 200 OK
{
  "bagId": "bag-001",
  "status": "UNAVAILABLE"
}
```

#### Search Blood Bags
```http
GET /api/v1/inventory/bags/search?bloodType=O_POSITIVE&status=AVAILABLE
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "content": [
    {
      "bagId": "bag-001",
      "bloodType": "O_POSITIVE",
      "volume": 350,
      "status": "AVAILABLE"
    }
  ],
  "totalElements": 10
}
```

#### Release Reserved Blood Bag
```http
PUT /api/v1/inventory/bags/{bagId}/release
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "bagId": "bag-001",
  "status": "AVAILABLE"
}
```

#### Get Expiry Alerts
```http
GET /api/v1/inventory/expiry-alerts?alert_level=WARNING
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "content": [
    {
      "expiryAlertId": "exp-001",
      "bagId": "bag-001",
      "daysUntilExpiry": 3,
      "alertLevel": "WARNING",
      "bloodType": "AB_NEGATIVE"
    }
  ]
}
```

#### Check Stock Availability (Internal)
```http
GET /api/v1/inventory/check-stock?bloodType=O_POSITIVE&units=4
Authorization: Bearer {internal_service_token}

Response: 200 OK
{
  "available": true,
  "availableUnits": 8,
  "requiredUnits": 4
}
```

#### Get Temperature Monitoring Data
```http
GET /api/v1/inventory/temperature/monitoring?bagId={bagId}&hours=24
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "bagId": "bag-001",
  "readings": [
    {
      "temperature": 4.5,
      "humidity": 45,
      "readingTime": "2024-01-15T14:00:00Z",
      "alertTriggered": false
    }
  ],
  "avgTemperature": 4.3,
  "minTemperature": 4.0,
  "maxTemperature": 5.2
}
```

---

## 4. EMERGENCY REQUEST ENDPOINTS (Request Service)

### Port: 3004 | Gateway Route: `/api/v1/requests/**`

#### Create Emergency Blood Request (CRITICAL - Hospital)
```http
POST /api/v1/requests/create
Authorization: Bearer {hospital_token}
Content-Type: application/json

{
  "hospitalId": "hosp-001",
  "bloodType": "O_POSITIVE",
  "unitsRequired": 4,
  "urgencyLevel": "CRITICAL",
  "patientAge": 45,
  "patientGender": "M",
  "patientCondition": "Multiple trauma, ICU admission",
  "procedureType": "Emergency Surgery",
  "deadlineMinutes": 30
}

Response: 201 Created
{
  "statusCode": 201,
  "message": "Emergency request created and donor search initiated",
  "data": {
    "requestId": "req-001",
    "status": "PENDING",
    "createdAt": "2024-01-15T14:23:45Z",
    "deadlineTimestamp": "2024-01-15T14:53:45Z",
    "matchedDonorsCount": 8
  }
}
```

#### Get Request Details
```http
GET /api/v1/requests/{requestId}
Authorization: Bearer {access_token}

Response: 200 OK
{
  "requestId": "req-001",
  "hospitalId": "hosp-001",
  "bloodType": "O_POSITIVE",
  "unitsRequired": 4,
  "urgencyLevel": "CRITICAL",
  "patientCondition": "Multiple trauma, ICU admission",
  "status": "MATCHED",
  "deadlineTimestamp": "2024-01-15T14:53:45Z",
  "remainingMinutes": 18,
  "createdAt": "2024-01-15T14:23:45Z"
}
```

#### Get All Active Requests for Hospital
```http
GET /api/v1/requests/hospital/{hospitalId}/active
Authorization: Bearer {hospital_token}

Response: 200 OK
{
  "content": [
    {
      "requestId": "req-001",
      "bloodType": "O_POSITIVE",
      "unitsRequired": 4,
      "urgencyLevel": "CRITICAL",
      "status": "MATCHED",
      "remainingMinutes": 18
    }
  ],
  "totalElements": 3
}
```

#### Get Active Global Requests
```http
GET /api/v1/requests/active
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "content": [
    {
      "requestId": "req-001",
      "hospitalId": "hosp-001",
      "bloodType": "O_POSITIVE",
      "urgencyLevel": "CRITICAL",
      "status": "MATCHED",
      "matchedDonorsCount": 8
    }
  ],
  "totalElements": 12
}
```

#### Accept Response (Donor Accepts Emergency)
```http
POST /api/v1/requests/{requestId}/accept-response/{responseId}
Authorization: Bearer {donor_token}
Content-Type: application/json

{
  "donorId": "donor-99",
  "arrivalMinutes": 25,
  "currentLatitude": 28.5355,
  "currentLongitude": 77.3910
}

Response: 200 OK
{
  "statusCode": 200,
  "message": "Response accepted. Please proceed to collection center",
  "data": {
    "responseId": "resp-001",
    "scheduledPickupTime": "2024-01-15T14:45:00Z",
    "confirmationCode": "ABC123",
    "pointsEarned": 100
  }
}
```

#### Reject Response (Donor Rejects)
```http
POST /api/v1/requests/{requestId}/reject-response/{responseId}
Authorization: Bearer {donor_token}
Content-Type: application/json

{
  "donorId": "donor-99",
  "rejectionReason": "Unable to reach center on time"
}

Response: 200 OK
{
  "statusCode": 200,
  "message": "Response rejected"
}
```

#### Get Matched Donors for Request
```http
GET /api/v1/requests/{requestId}/matched-donors
Authorization: Bearer {hospital_token}

Response: 200 OK
{
  "content": [
    {
      "donorId": "donor-001",
      "bloodType": "O_POSITIVE",
      "distanceKm": 2.5,
      "matchScore": 95,
      "estimatedArrivalMinutes": 15,
      "isOnline": true,
      "totalDonations": 8,
      "badgeLevel": "SILVER"
    },
    {
      "donorId": "donor-002",
      "bloodType": "O_NEGATIVE",
      "distanceKm": 3.2,
      "matchScore": 88,
      "estimatedArrivalMinutes": 20,
      "isOnline": false,
      "totalDonations": 5,
      "badgeLevel": "BRONZE"
    }
  ],
  "totalElements": 8
}
```

#### Cancel Request
```http
DELETE /api/v1/requests/{requestId}
Authorization: Bearer {hospital_token}
Content-Type: application/json

{
  "reason": "Patient condition improved, emergency averted"
}

Response: 200 OK
{
  "requestId": "req-001",
  "status": "CANCELLED",
  "cancelledAt": "2024-01-15T14:40:00Z"
}
```

#### Get Request Responses
```http
GET /api/v1/requests/{requestId}/responses?status=ACCEPTED
Authorization: Bearer {hospital_token}

Response: 200 OK
{
  "content": [
    {
      "responseId": "resp-001",
      "donorId": "donor-001",
      "responseStatus": "ACCEPTED",
      "scheduledPickupTime": "2024-01-15T14:45:00Z",
      "pointsEarned": 100
    }
  ]
}
```

---

## 5. HOSPITAL ENDPOINTS (Donor Service Extension)

### Port: 3002 | Gateway Route: `/api/v1/hospitals/**`

#### Register Hospital
```http
POST /api/v1/hospitals/register
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "userId": "user-hospital-001",
  "hospitalName": "Apollo Hospital Delhi",
  "address": "Sarita Vihar, Delhi 110076",
  "city": "Delhi",
  "state": "Delhi",
  "pincode": "110076",
  "contactPhone": "+91-11-4262-5050",
  "emergencyContact": "+91-11-4262-5000",
  "bloodBankCapacity": 500,
  "operatingHoursStart": "00:00",
  "operatingHoursEnd": "23:59",
  "latitude": 28.5355,
  "longitude": 77.3910
}

Response: 201 Created
{
  "hospitalId": "hosp-001",
  "hospitalName": "Apollo Hospital Delhi",
  "address": "Sarita Vihar, Delhi 110076",
  "status": "ACTIVE",
  "bloodBankCapacity": 500
}
```

#### Get Hospital Profile
```http
GET /api/v1/hospitals/{hospitalId}
Authorization: Bearer {access_token}

Response: 200 OK
{
  "hospitalId": "hosp-001",
  "userId": "user-hospital-001",
  "hospitalName": "Apollo Hospital Delhi",
  "address": "Sarita Vihar, Delhi 110076",
  "contactPhone": "+91-11-4262-5050",
  "bloodBankCapacity": 500,
  "currentBloodInventory": {
    "O_POSITIVE": 8,
    "O_NEGATIVE": 2,
    "A_POSITIVE": 5,
    "A_NEGATIVE": 1
  },
  "totalRequestsToday": 5,
  "fulfilledToday": 4
}
```

#### Get Hospital Dashboard
```http
GET /api/v1/hospitals/{hospitalId}/dashboard
Authorization: Bearer {hospital_token}

Response: 200 OK
{
  "hospitalId": "hosp-001",
  "hospitalName": "Apollo Hospital Delhi",
  "todayStats": {
    "totalRequests": 5,
    "fulfilledRequests": 4,
    "pendingRequests": 1,
    "averageResponseTime": 18,
    "lifeSaved": 12
  },
  "bloodInventory": {
    "O_POSITIVE": 8,
    "O_NEGATIVE": 2,
    "A_POSITIVE": 5,
    "AB_NEGATIVE": 0
  },
  "activeRequests": [
    {
      "requestId": "req-001",
      "bloodType": "O_POSITIVE",
      "unitsRequired": 4,
      "urgencyLevel": "CRITICAL",
      "remainingMinutes": 18
    }
  ]
}
```

#### Update Hospital Profile
```http
PUT /api/v1/hospitals/{hospitalId}/profile
Authorization: Bearer {hospital_token}
Content-Type: application/json

{
  "bloodBankCapacity": 600,
  "operatingHoursStart": "06:00",
  "operatingHoursEnd": "22:00"
}

Response: 200 OK
```

#### Get Hospital Performance Report
```http
GET /api/v1/hospitals/{hospitalId}/performance?days=30
Authorization: Bearer {hospital_token}

Response: 200 OK
{
  "hospitalId": "hosp-001",
  "period": "Last 30 days",
  "totalRequests": 145,
  "fulfilledRequests": 138,
  "partiallyFulfilled": 5,
  "failedRequests": 2,
  "averageResponseTime": 22,
  "averageFulfillmentTime": 28,
  "operationalEfficiencyScore": 92,
  "donorSatisfactionScore": 88
}
```

#### List All Hospitals (Admin)
```http
GET /api/v1/hospitals?page=0&size=20
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "content": [
    {
      "hospitalId": "hosp-001",
      "hospitalName": "Apollo Hospital Delhi",
      "city": "Delhi",
      "bloodBankCapacity": 500,
      "status": "ACTIVE"
    }
  ],
  "totalElements": 45
}
```

---

## 6. GEOLOCATION ENDPOINTS (Geolocation Service)

### Port: 3005 | Gateway Route: `/api/v1/geo/**`

#### Find Nearby Donors
```http
GET /api/v1/geo/nearby-donors?hospitalId=hosp-001&radius=5
Authorization: Bearer {hospital_token}

Response: 200 OK
{
  "nearbyDonors": [
    {
      "donorId": "donor-001",
      "donorName": "John Doe",
      "bloodType": "O_POSITIVE",
      "distanceKm": 2.5,
      "estimatedTimeMinutes": 8,
      "isOnline": true,
      "totalDonations": 8
    },
    {
      "donorId": "donor-002",
      "donorName": "Jane Smith",
      "bloodType": "O_NEGATIVE",
      "distanceKm": 3.2,
      "estimatedTimeMinutes": 12,
      "isOnline": false,
      "totalDonations": 5
    }
  ],
  "totalFound": 8,
  "searchRadius": 5
}
```

#### Update Donor Location
```http
POST /api/v1/geo/location/update
Authorization: Bearer {donor_token}
Content-Type: application/json

{
  "donorId": "donor-001",
  "latitude": 28.5355,
  "longitude": 77.3910,
  "accuracy": 15
}

Response: 200 OK
{
  "locationId": "loc-001",
  "lastUpdate": "2024-01-15T14:25:00Z"
}
```

#### Get Live Delivery Tracking
```http
GET /api/v1/geo/tracking/{fulfillmentId}
Authorization: Bearer {hospital_token}

Response: 200 OK
{
  "fulfillmentId": "fulfillment-001",
  "rideId": "ride-001",
  "status": "IN_TRANSIT",
  "pickupLocation": {
    "latitude": 28.5355,
    "longitude": 77.3910,
    "name": "Collection Center"
  },
  "deliveryLocation": {
    "latitude": 28.5610,
    "longitude": 77.2105,
    "name": "Apollo Hospital"
  },
  "currentLocation": {
    "latitude": 28.5450,
    "longitude": 77.3300
  },
  "distanceRemaining": 8.5,
  "etaMinutes": 12,
  "temperature": 4.5,
  "speed": 35
}
```

#### Get Distance Between Two Locations
```http
GET /api/v1/geo/distance?origin=donor-001&destination=hosp-001
Authorization: Bearer {internal_token}

Response: 200 OK
{
  "originDonorId": "donor-001",
  "destinationHospitalId": "hosp-001",
  "distanceKm": 2.5,
  "durationMinutes": 8,
  "routeSummary": "Via Ring Road"
}
```

#### Start Ride Tracking
```http
POST /api/v1/geo/tracking/{fulfillmentId}/start
Authorization: Bearer {rider_token}
Content-Type: application/json

{
  "riderId": "rider-001",
  "vehicleType": "Motorcycle"
}

Response: 200 OK
{
  "rideId": "ride-001",
  "status": "STARTED"
}
```

#### Log Tracking Point
```http
POST /api/v1/geo/tracking/{rideId}/points
Authorization: Bearer {rider_token}
Content-Type: application/json

{
  "latitude": 28.5450,
  "longitude": 77.3300,
  "speed": 35,
  "accuracy": 10
}

Response: 201 Created
{
  "trackingId": "track-001",
  "timestamp": "2024-01-15T14:28:35Z"
}
```

---

## 7. NOTIFICATION ENDPOINTS (Notification Service)

### Port: 3006 | Gateway Route: `/api/v1/notifications/**`

#### Get User Notifications
```http
GET /api/v1/notifications?read_status=false&page=0&size=10
Authorization: Bearer {access_token}

Response: 200 OK
{
  "content": [
    {
      "notificationId": "notif-001",
      "title": "Emergency Blood Needed",
      "content": "O+ blood needed at Apollo Hospital. Can you donate?",
      "notificationType": "PUSH",
      "priority": "CRITICAL",
      "sentAt": "2024-01-15T14:23:45Z",
      "readAt": null,
      "readStatus": false
    }
  ],
  "totalUnread": 5
}
```

#### Mark Notification as Read
```http
PUT /api/v1/notifications/{notificationId}/read
Authorization: Bearer {access_token}

Response: 200 OK
{
  "notificationId": "notif-001",
  "readAt": "2024-01-15T14:25:00Z"
}
```

#### Get Notification Preferences
```http
GET /api/v1/notifications/preferences
Authorization: Bearer {access_token}

Response: 200 OK
{
  "preferenceId": "pref-001",
  "smsEnabled": true,
  "emailEnabled": true,
  "pushEnabled": true,
  "emergencyAlertsSound": true,
  "quietHoursEnabled": false
}
```

#### Update Notification Preferences
```http
PUT /api/v1/notifications/preferences
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "smsEnabled": true,
  "emailEnabled": true,
  "pushEnabled": true,
  "emergencyAlertsSound": true,
  "quietHoursEnabled": true,
  "quietHoursStart": "22:00",
  "quietHoursEnd": "08:00"
}

Response: 200 OK
```

#### Get Notification History
```http
GET /api/v1/notifications/history?page=0&size=20
Authorization: Bearer {access_token}

Response: 200 OK
{
  "content": [
    {
      "notificationId": "notif-001",
      "title": "Emergency Blood Needed",
      "sentAt": "2024-01-15T14:23:45Z",
      "deliveryStatus": "DELIVERED",
      "readStatus": true,
      "readAt": "2024-01-15T14:25:00Z"
    }
  ],
  "totalElements": 156
}
```

---

## 8. ANALYTICS ENDPOINTS (Analytics Service)

### Port: 3007 | Gateway Route: `/api/v1/analytics/**`

#### Get System Dashboard
```http
GET /api/v1/analytics/dashboard
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "totalActiveRequests": 12,
  "totalDonorsOnline": 245,
  "criticalRequestsPending": 3,
  "averageResponseTime": 18,
  "successfulFulfillmentToday": 18,
  "totalUnitsDistributedToday": 54,
  "systemUptime": 99.85,
  "bloodShortageAlerts": 2,
  "apiErrorRate": 0.02
}
```

#### Get Donor Statistics
```http
GET /api/v1/analytics/donors/stats
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "totalDonors": 5420,
  "activeDonors": 3240,
  "newDonorsThisMonth": 145,
  "totalDonationsAllTime": 18540,
  "averageDonationsPerDonor": 3.4,
  "donorRetentionRate": 78.5
}
```

#### Get Blood Demand Forecast
```http
GET /api/v1/analytics/forecast/demand?days=30
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "forecast": [
    {
      "bloodType": "O_POSITIVE",
      "predictedDemand": 125,
      "confidencePercent": 92,
      "trend": "UP",
      "recommendation": "Increase collection drives"
    },
    {
      "bloodType": "AB_NEGATIVE",
      "predictedDemand": 8,
      "confidencePercent": 85,
      "trend": "DOWN",
      "recommendation": "Monitor closely"
    }
  ]
}
```

#### Get Stock Prediction
```http
GET /api/v1/analytics/forecast/stock
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "predictions": [
    {
      "bloodType": "O_POSITIVE",
      "currentStock": 45,
      "predicted_24h": 32,
      "predicted_7d": 8,
      "shortageProb": 15,
      "daysUntilCritical": 6
    }
  ]
}
```

#### Get Critical Incidents Report
```http
GET /api/v1/analytics/incidents?severity=CRITICAL&page=0&size=10
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "content": [
    {
      "incidentId": "inc-001",
      "incidentType": "STOCK_CRITICAL",
      "severity": "CRITICAL",
      "bloodType": "AB_NEGATIVE",
      "reportedAt": "2024-01-15T12:30:00Z",
      "resolvedAt": "2024-01-15T13:15:00Z",
      "resolution": "Emergency collection drive initiated"
    }
  ],
  "totalElements": 8
}
```

#### Get Hospital Performance Report
```http
GET /api/v1/analytics/hospitals/{hospitalId}/performance?days=30
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "hospitalId": "hosp-001",
  "period": "Last 30 days",
  "totalRequests": 145,
  "fulfilledRequests": 138,
  "operationalEfficiencyScore": 92,
  "donorSatisfactionScore": 88
}
```

#### Get Global Performance Analytics
```http
GET /api/v1/analytics/global/performance?days=30
Authorization: Bearer {admin_token}

Response: 200 OK
{
  "period": "Last 30 days",
  "totalRequests": 4530,
  "fulfilledRequests": 4298,
  "partiallyFulfilled": 185,
  "failedRequests": 47,
  "averageResponseTime": 22,
  "estimatedLivesSaved": 12894,
  "systemUptime": 99.85
}
```

#### Export Analytics Report
```http
GET /api/v1/analytics/reports/export?type=PDF&days=30
Authorization: Bearer {admin_token}

Response: 200 OK (Binary PDF)
```

---

## Error Response Format

All endpoints return consistent error responses:

```json
{
  "statusCode": 400,
  "message": "Invalid request parameters",
  "errors": [
    {
      "field": "bloodType",
      "message": "Blood type is required"
    }
  ],
  "timestamp": "2024-01-15T14:35:00Z"
}
```

## HTTP Status Codes

- `200 OK` - Successful GET/PUT request
- `201 Created` - Successful POST request
- `204 No Content` - Successful DELETE request
- `400 Bad Request` - Invalid parameters
- `401 Unauthorized` - Missing/invalid JWT token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Business logic conflict
- `500 Internal Server Error` - Server error