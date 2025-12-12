# Compliance, Security & Privacy for LifeFlow

## 1. Regulatory Compliance

### HIPAA (Health Insurance Portability & Accountability Act)
**Applicable In**: USA

**Requirements**:
- Patient health information must be encrypted
- Access logs must be maintained
- Data breach notification within 60 days
- Minimum 6-year data retention

**LifeFlow Implementation**:
```
✓ PII Encryption: AES-256 for patient records
✓ Access Logs: All database access logged
✓ Audit Trail: 7-year retention for health data
✓ Data Deletion: 90-day grace period before permanent deletion
✓ Breach Notification: Automated alerts to compliance team
```

### GDPR (General Data Protection Regulation)
**Applicable In**: EU, India (similar regulations)

**Key Requirements**:
- Right to access personal data
- Right to be forgotten (data deletion)
- Data portability
- Privacy by design
- Consent for data processing

**LifeFlow Implementation**:
```
✓ Data Portability: Export donor data as JSON/CSV
✓ Right to Erasure: Self-service account deletion with 30-day grace period
✓ Consent Management: Explicit opt-in for data processing
✓ DPA (Data Processing Agreement): Signed with all vendors
✓ Privacy Policy: Clear, accessible, updated quarterly
✓ Consent Records: Audit trail of all user consents
```

### India's Digital Personal Data Protection (DPDP) Act
**Similar to GDPR but tailored for India**

**Key Points**:
- Lawful basis for data processing
- Purpose limitation (use data only for stated purpose)
- Data minimization (collect only what's needed)
- Storage limitation

**LifeFlow Implementation**:
```
✓ Lawful Basis: Blood donation is public health benefit
✓ Purpose Limitation: Data used only for blood donation matching
✓ Minimal Data: Only essential fields collected
✓ Consent: Explicit consent before data collection
✓ Anonymization: Patient data anonymized in vein-to-vein tracking
```

---

## 2. Data Security

### Encryption Strategy

**Data at Rest** (Stored in databases):
```sql
-- All sensitive fields encrypted with master key
CREATE TABLE DONORS (
  donor_id UUID PRIMARY KEY,
  phone_number TEXT ENCRYPTED,  -- AES-256
  email TEXT ENCRYPTED,          -- AES-256
  blood_type TEXT,               -- Not sensitive, not encrypted
  medical_history JSON ENCRYPTED, -- AES-256
  last_encrypted TIMESTAMP
);

Encryption Key Management:
├─ Master key: HSM (Hardware Security Module)
├─ Key rotation: Every 90 days
├─ Access: Only encryption service can access keys
└─ Backup: Encrypted key backup in separate location
```

**Data in Transit** (Network communication):
```
All APIs: HTTPS/TLS 1.3 minimum
├─ Certificate: Signed by trusted CA
├─ HSTS: HTTP Strict Transport Security enabled
├─ Perfect Forward Secrecy: Enabled
├─ Cipher suites: TLS_AES_256_GCM_SHA384 preferred

Service-to-service: mTLS (Mutual TLS)
├─ Service certificates: Issued by internal CA
├─ Rotation: Every 180 days
├─ Verification: CN and SANs checked
```

**Data in Transit - PII Masking**:
```
Request to hospital with donor details:
├─ Donor phone: +91-9876543210
│  Sent as: +91-98*****210 (masked)
├─ Donor email: rahul@example.com
│  Sent as: r****@example.com (masked)
├─ Donor name: Rahul Sharma
│  Sent as: R.S. (initials only)

Only after donor accepts request:
└─ Full details revealed to hospital
```

### Authentication & Authorization

**Multi-Factor Authentication (MFA)**:
```
Factor 1: Something you know (password)
├─ Minimum 12 characters
├─ Special characters + numbers required
├─ Bcrypt hashing with salt
└─ Breach detection (if password in breach database)

Factor 2: Something you have
├─ Option 1: OTP via SMS (Twilio)
├─ Option 2: OTP via Email
├─ Option 3: Authenticator app (Google Authenticator, Microsoft Authenticator)
├─ Option 4: Hardware token (FIDO2)
└─ Backup codes: 10 one-time use codes

Factor 3 (Optional): Something you are (Biometric)
├─ Fingerprint scan
├─ Face recognition
├─ Supported on: iOS & Android
└─ Biometric data: Stored locally on device, never sent to server
```

**Session Management**:
```
JWT Token (Access Token):
├─ Validity: 15 minutes
├─ Algorithm: HS256
├─ Contains: user_id, roles, permissions, iat, exp
└─ Revocation: Token blacklist on logout

Refresh Token:
├─ Validity: 7 days
├─ Stored: Secure HTTP-only cookie
├─ Rotation: New refresh token issued on use
└─ Device tracking: IP address, user agent validated

Session Invalidation:
├─ On logout: All tokens invalidated
├─ On password change: All sessions invalidated
├─ On security incident: All sessions forcefully invalidated
└─ Inactivity: Auto-logout after 30 minutes
```

### OAuth2 Implementation

```
For Third-Party Integrations:

Flow: Authorization Code Grant (most secure)
1. User clicks "Login with LifeFlow" on partner site
2. Redirected to LifeFlow login page
3. User logs in (with MFA if enabled)
4. User sees consent screen: "App X wants access to:"
   ├─ Your blood type
   ├─ Your donation history (anonymized)
   └─ Your contact information
5. User grants permission
6. Redirected back to partner with authorization code
7. Partner exchanges code for access token (server-to-server)
8. Partner uses access token to call LifeFlow APIs
9. Access token: 1-hour validity, revocable anytime

Scope Limitations:
├─ blood_type:read
├─ donation_history:read
├─ profile:read
└─ No write permissions to sensitive data
```

---

## 3. Privacy Architecture

### Anonymization & De-identification

**Vein-to-Vein Tracking - Anonymization**:
```
Donor receives:
┌──────────────────────────────────┐
│ Your blood saved a life! 🎉      │
│                                  │
│ Patient: 34-year-old             │ ← Age only
│ Gender: Female                    │ ← Gender only
│ Procedure: Emergency transfusion  │ ← Procedure type
│ Status: Discharged, recovering   │ ← Outcome
│ Hospital: Central Medical Center  │ ← Hospital name OK
│ Date: 2024-01-15                 │ ← Date OK
└──────────────────────────────────┘

NOT sent to donor:
├─ Patient name
├─ Patient address
├─ Patient ID/insurance number
├─ Specific diagnosis
├─ Hospital ward/room
└─ Any identifying information
```

**Pseudonymization for Analytics**:
```
Raw data:
├─ Donor: Rahul Sharma, +91-98765-43210, rahul@example.com

Pseudonymized (for analytics):
├─ Donor: DONOR_P7K2Q9
├─ Age: 28
├─ Blood type: O+
├─ Donation count: 4
└─ City: Delhi

Mapping table (encrypted, access restricted):
├─ DONOR_P7K2Q9 ↔ actual donor info
├─ Encrypted with separate master key
├─ Only GDPR request handler can decrypt
└─ No analytics team member can see original data
```

### Audit & Compliance Logging

```
All Audit Events Logged:

Authentication Events:
├─ LOGIN_SUCCESS: user_id, timestamp, ip_address, device
├─ LOGIN_FAILURE: email, timestamp, ip_address, reason
├─ PASSWORD_CHANGE: user_id, timestamp, actor
└─ 2FA_ENABLED/DISABLED: user_id, timestamp, actor

Data Access Events:
├─ DONOR_DATA_ACCESSED: actor_id, donor_id, timestamp, reason
├─ BLOOD_BAG_VIEWED: actor_id, bag_id, timestamp
├─ PATIENT_DATA_ACCESSED: actor_id, patient_id, timestamp, reason
└─ REPORT_GENERATED: actor_id, report_type, timestamp

Data Modification Events:
├─ PROFILE_UPDATED: user_id, fields_changed, timestamp
├─ RECORD_DELETED: actor_id, record_type, timestamp, reason
└─ DONATION_RECORDED: actor_id, donor_id, timestamp

Admin Actions:
├─ USER_SUSPENDED: actor_id, user_id, reason, timestamp
├─ DATA_EXPORT: actor_id, user_id, format, timestamp
└─ SETTINGS_CHANGED: actor_id, setting_name, old_value, new_value

Storage:
├─ Immutable audit logs (append-only, cannot delete)
├─ Retention: 7 years for health data
├─ Indexed by: user_id, action_type, timestamp
├─ Searchable: Via audit dashboard
└─ Alerts: On suspicious patterns (e.g., 10 logins in 1 minute)
```

---

## 4. Network Security

### API Security

```
Rate Limiting:
├─ Per-user rate limit: 1000 requests/hour
├─ Per-IP rate limit: 10,000 requests/hour
├─ Per-endpoint: Emergency endpoints unlimited
├─ Burst protection: Max 100 requests/minute

Request Validation:
├─ Content-Type validation (must be application/json)
├─ Payload size limit: 10MB
├─ Field validation: Type, length, format
├─ SQL injection prevention: Parameterized queries
├─ XSS prevention: Input sanitization

CORS Policy:
├─ Allowed origins: Configured whitelist only
├─ Allowed methods: GET, POST, PUT, DELETE
├─ Allowed headers: Authorization, Content-Type, X-Correlation-ID
├─ Credentials: Allowed (for auth cookies)
├─ Max age: 86400 seconds (24 hours)
```

### DDoS Protection

```
Layer 1 - Web Application Firewall (WAF):
├─ Cloudflare / AWS WAF
├─ Rate limiting: 1000 requests/second per IP
├─ Geo-blocking: Block requests from suspicious countries
├─ Signature detection: Known attack patterns blocked
└─ Behavioral analysis: Unusual patterns flagged

Layer 2 - API Gateway:
├─ Request rate limiting per user
├─ Circuit breaker: Stop accepting requests if overloaded
├─ Queue management: Fair queuing, no starvation
└─ Graceful degradation: Drop non-critical requests

Layer 3 - Infrastructure:
├─ Auto-scaling: Handle traffic spikes
├─ Load balancing: Distribute across multiple servers
├─ CDN: Cache static content, reduce origin load
└─ DDoS detection: Automatic blocking of suspicious IPs
```

### Vulnerability Management

```
Regular Security Audits:
├─ Penetration testing: Quarterly
├─ Code review: Every pull request (2 reviewers)
├─ Dependency scanning: Daily (npm audit, Maven dependency-check)
├─ SAST (Static Application Security Testing): On every commit
└─ DAST (Dynamic Application Security Testing): Weekly

Vulnerability Reporting:
├─ Bug bounty program: Up to ₹1,00,000 per vulnerability
├─ Disclosure policy: 90-day responsible disclosure
├─ Notification: Affected users notified within 24 hours
└─ Fix priority: Critical (24 hours), High (1 week), Medium (2 weeks)

Patch Management:
├─ Security patches: Applied immediately (emergency deployment)
├─ Regular updates: Applied in monthly maintenance window
├─ Testing: Staging environment mirroring production
└─ Rollback plan: Keep previous version for quick rollback
```

---

## 5. Vendor & Third-Party Security

```
Third-Party Services Integration:

Twilio (SMS):
├─ Data: Only phone numbers and message content
├─ Encryption: TLS in transit
├─ Contract: DPA (Data Processing Agreement) signed
├─ Audit: SOC 2 Type II certified
└─ Incident protocol: Notification within 24 hours

SendGrid (Email):
├─ Data: Email addresses and message content
├─ Encryption: TLS in transit, AES at rest
├─ Contract: DPA signed
├─ Audit: SOC 2 Type II certified
└─ Incident protocol: Notification within 24 hours

Firebase (Push Notifications):
├─ Data: Device tokens, message content
├─ Encryption: TLS in transit
├─ Contract: Google DPA (via Google Cloud)
├─ Audit: ISO 27001 certified
└─ Incident protocol: Notification within 24 hours

Google Maps (Geolocation):
├─ Data: Coordinates, distances
├─ Encryption: TLS in transit
├─ Contract: Google Maps API terms
├─ No PII: Only location data, not tied to names
└─ Caching: Cache maps data locally to minimize API calls

Vendor Risk Management:
├─ Annual security questionnaire
├─ SOC 2 certification verification
├─ Incident history review
├─ Insurance coverage verification
└─ Business continuity plan review
```

---

## 6. Incident Response Plan

```
Incident Severity Levels:

CRITICAL (0-1 hour response):
├─ Data breach (PII exposed)
├─ System outage (>30 minutes)
├─ Ransomware attack
├─ DDoS preventing service access
└─ Unauthorized data access

HIGH (1-4 hours):
├─ Security vulnerability discovered
├─ Partial service degradation
├─ Unsuccessful attack attempt
└─ Configuration error exposing data

MEDIUM (1-2 days):
├─ Minor security issue
├─ Suspicious activity detected
├─ Non-critical service degradation
└─ Policy violation

Incident Response Workflow:

1. Detection:
   ├─ Automated alerts
   ├─ User reports
   ├─ Security team monitoring
   └─ Compliance team

2. Assessment (15 minutes):
   ├─ Severity determination
   ├─ Scope assessment
   ├─ Affected users count
   └─ Data exposure assessment

3. Containment (varies by severity):
   ├─ Isolate affected systems
   ├─ Revoke compromised credentials
   ├─ Block malicious IP addresses
   └─ Kill suspicious processes

4. Investigation (24-72 hours):
   ├─ Root cause analysis
   ├─ Forensic data collection
   ├─ Timeline reconstruction
   └─ Blame-free learning

5. Communication:
   ├─ User notification (if needed)
   ├─ Regulatory notification (if required)
   ├─ Press statement (if public)
   ├─ Internal team briefing
   └─ Stakeholder updates

6. Remediation (varies):
   ├─ Fix root cause
   ├─ Apply patches
   ├─ Update security controls
   └─ Verify fix

7. Post-Incident Review (1 week):
   ├─ Full incident report
   ├─ Preventive measures
   ├─ Training updates
   └─ Control improvements
```

