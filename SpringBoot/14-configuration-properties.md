# Spring Boot Configuration and Properties

## Configuration Sources

Spring Boot loads configuration from multiple sources in the following order (higher priority overrides lower):

1. **Command line arguments**
2. **JNDI attributes**
3. **Java System properties**
4. **OS environment variables**
5. **Profile-specific properties outside jar**
6. **Profile-specific properties inside jar**
7. **Application properties outside jar**
8. **Application properties inside jar**
9. **@PropertySource annotations**
10. **Default properties**

## Application Properties

### application.properties

```properties
# Server Configuration
server.port=8080
server.servlet.context-path=/api
server.servlet.session.timeout=30m

# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/mydb
spring.datasource.username=root
spring.datasource.password=password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect

# Logging Configuration
logging.level.com.example=DEBUG
logging.level.org.springframework.web=INFO
logging.file.name=app.log
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n

# Custom Application Properties
app.name=My Application
app.version=1.0.0
app.description=This is my Spring Boot application
app.admin.email=admin@example.com
app.features.email-notifications=true
app.features.sms-notifications=false
```

### application.yml (YAML Format)

```yaml
# Server Configuration
server:
  port: 8080
  servlet:
    context-path: /api
    session:
      timeout: 30m

# Database Configuration
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    username: root
    password: password
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        format_sql: true
    database-platform: org.hibernate.dialect.MySQL8Dialect

# Logging Configuration
logging:
  level:
    com.example: DEBUG
    org.springframework.web: INFO
  file:
    name: app.log
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"

# Custom Application Properties
app:
  name: My Application
  version: 1.0.0
  description: This is my Spring Boot application
  admin:
    email: admin@example.com
  features:
    email-notifications: true
    sms-notifications: false
```

## @Value Annotation

**Purpose**: Injects property values into fields or parameters
**What it does**: Reads values from configuration sources

### Basic Usage

```java
@Service
public class EmailService {
    
    @Value("${app.admin.email}")
    private String adminEmail;
    
    @Value("${app.name}")
    private String applicationName;
    
    @Value("${server.port}")
    private int serverPort;
    
    @Value("${app.features.email-notifications}")
    private boolean emailNotificationsEnabled;
    
    public void sendAdminNotification(String message) {
        if (emailNotificationsEnabled) {
            System.out.println("Sending email to: " + adminEmail);
            System.out.println("From application: " + applicationName);
            System.out.println("Message: " + message);
        }
    }
}
```

### Default Values

```java
@Service
public class ConfigurationService {
    
    // Default value if property not found
    @Value("${app.timeout:5000}")
    private int timeout;
    
    // Default value for string
    @Value("${app.environment:development}")
    private String environment;
    
    // Default value for boolean
    @Value("${app.debug:false}")
    private boolean debugMode;
    
    // Default value for list (comma-separated)
    @Value("${app.allowed-origins:http://localhost:3000,http://localhost:4200}")
    private List<String> allowedOrigins;
    
    public void printConfiguration() {
        System.out.println("Timeout: " + timeout);
        System.out.println("Environment: " + environment);
        System.out.println("Debug Mode: " + debugMode);
        System.out.println("Allowed Origins: " + allowedOrigins);
    }
}
```

### SpEL (Spring Expression Language)

```java
@Service
public class AdvancedConfigurationService {
    
    // Mathematical expressions
    @Value("#{${app.max-connections:10} * 2}")
    private int maxPoolSize;
    
    // Conditional expressions
    @Value("#{${app.debug:false} ? 'DEBUG' : 'INFO'}")
    private String logLevel;
    
    // System properties
    @Value("#{systemProperties['user.home']}")
    private String userHome;
    
    // Environment variables
    @Value("#{systemEnvironment['PATH']}")
    private String systemPath;
    
    // Random values
    @Value("#{T(java.util.UUID).randomUUID().toString()}")
    private String instanceId;
    
    // Method calls
    @Value("#{T(java.time.LocalDateTime).now()}")
    private LocalDateTime startupTime;
}
```

## @ConfigurationProperties

**Purpose**: Binds properties to Java objects with type safety
**What it does**: Maps property prefixes to object fields with validation

### Basic Configuration Properties

```java
@ConfigurationProperties(prefix = "app")
@Component
public class ApplicationProperties {
    
    private String name;
    private String version;
    private String description;
    private Admin admin = new Admin();
    private Features features = new Features();
    private List<String> supportedLanguages = new ArrayList<>();
    private Map<String, String> metadata = new HashMap<>();
    
    // Nested class for admin properties
    public static class Admin {
        private String email;
        private String name;
        private List<String> roles = new ArrayList<>();
        
        // Getters and setters
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public List<String> getRoles() { return roles; }
        public void setRoles(List<String> roles) { this.roles = roles; }
    }
    
    // Nested class for features
    public static class Features {
        private boolean emailNotifications;
        private boolean smsNotifications;
        private boolean pushNotifications;
        
        // Getters and setters
        public boolean isEmailNotifications() { return emailNotifications; }
        public void setEmailNotifications(boolean emailNotifications) { 
            this.emailNotifications = emailNotifications; 
        }
        
        public boolean isSmsNotifications() { return smsNotifications; }
        public void setSmsNotifications(boolean smsNotifications) { 
            this.smsNotifications = smsNotifications; 
        }
        
        public boolean isPushNotifications() { return pushNotifications; }
        public void setPushNotifications(boolean pushNotifications) { 
            this.pushNotifications = pushNotifications; 
        }
    }
    
    // Main class getters and setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getVersion() { return version; }
    public void setVersion(String version) { this.version = version; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public Admin getAdmin() { return admin; }
    public void setAdmin(Admin admin) { this.admin = admin; }
    
    public Features getFeatures() { return features; }
    public void setFeatures(Features features) { this.features = features; }
    
    public List<String> getSupportedLanguages() { return supportedLanguages; }
    public void setSupportedLanguages(List<String> supportedLanguages) { 
        this.supportedLanguages = supportedLanguages; 
    }
    
    public Map<String, String> getMetadata() { return metadata; }
    public void setMetadata(Map<String, String> metadata) { this.metadata = metadata; }
}
```

### Corresponding Properties File

```yaml
app:
  name: My Spring Boot Application
  version: 2.1.0
  description: A comprehensive Spring Boot application
  admin:
    email: admin@example.com
    name: System Administrator
    roles:
      - ADMIN
      - SUPER_USER
  features:
    email-notifications: true
    sms-notifications: false
    push-notifications: true
  supported-languages:
    - en
    - es
    - fr
  metadata:
    author: John Doe
    company: Example Corp
    license: MIT
```

### Using Configuration Properties

```java
@Service
public class NotificationService {
    
    private final ApplicationProperties applicationProperties;
    
    public NotificationService(ApplicationProperties applicationProperties) {
        this.applicationProperties = applicationProperties;
    }
    
    public void sendNotification(String message, String type) {
        ApplicationProperties.Features features = applicationProperties.getFeatures();
        
        switch (type.toLowerCase()) {
            case "email":
                if (features.isEmailNotifications()) {
                    sendEmail(message);
                }
                break;
            case "sms":
                if (features.isSmsNotifications()) {
                    sendSms(message);
                }
                break;
            case "push":
                if (features.isPushNotifications()) {
                    sendPushNotification(message);
                }
                break;
        }
    }
    
    private void sendEmail(String message) {
        String adminEmail = applicationProperties.getAdmin().getEmail();
        System.out.println("Sending email to: " + adminEmail + " - " + message);
    }
    
    private void sendSms(String message) {
        System.out.println("Sending SMS: " + message);
    }
    
    private void sendPushNotification(String message) {
        System.out.println("Sending push notification: " + message);
    }
}
```

## Validation in Configuration Properties

### Adding Validation Dependencies

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

### Validated Configuration Properties

```java
@ConfigurationProperties(prefix = "app.database")
@Component
@Validated
public class DatabaseProperties {
    
    @NotBlank(message = "Database URL is required")
    private String url;
    
    @NotBlank(message = "Username is required")
    private String username;
    
    @NotBlank(message = "Password is required")
    private String password;
    
    @Min(value = 1, message = "Minimum connections must be at least 1")
    @Max(value = 100, message = "Maximum connections cannot exceed 100")
    private int minConnections = 5;
    
    @Min(value = 1, message = "Maximum connections must be at least 1")
    @Max(value = 200, message = "Maximum connections cannot exceed 200")
    private int maxConnections = 20;
    
    @Min(value = 1000, message = "Connection timeout must be at least 1000ms")
    private long connectionTimeout = 30000;
    
    @Valid
    private Pool pool = new Pool();
    
    public static class Pool {
        @Min(value = 1, message = "Initial size must be at least 1")
        private int initialSize = 5;
        
        @Min(value = 1, message = "Max active must be at least 1")
        private int maxActive = 20;
        
        @Min(value = 0, message = "Max idle cannot be negative")
        private int maxIdle = 10;
        
        // Getters and setters
        public int getInitialSize() { return initialSize; }
        public void setInitialSize(int initialSize) { this.initialSize = initialSize; }
        
        public int getMaxActive() { return maxActive; }
        public void setMaxActive(int maxActive) { this.maxActive = maxActive; }
        
        public int getMaxIdle() { return maxIdle; }
        public void setMaxIdle(int maxIdle) { this.maxIdle = maxIdle; }
    }
    
    // Getters and setters
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public int getMinConnections() { return minConnections; }
    public void setMinConnections(int minConnections) { this.minConnections = minConnections; }
    
    public int getMaxConnections() { return maxConnections; }
    public void setMaxConnections(int maxConnections) { this.maxConnections = maxConnections; }
    
    public long getConnectionTimeout() { return connectionTimeout; }
    public void setConnectionTimeout(long connectionTimeout) { this.connectionTimeout = connectionTimeout; }
    
    public Pool getPool() { return pool; }
    public void setPool(Pool pool) { this.pool = pool; }
}
```

## Profile-Specific Configuration

### Profile-Specific Properties Files

```
application.properties          # Common properties
application-dev.properties      # Development environment
application-test.properties     # Test environment
application-prod.properties     # Production environment
```

### application-dev.properties

```properties
# Development Configuration
server.port=8080
spring.datasource.url=jdbc:h2:mem:devdb
spring.datasource.username=sa
spring.datasource.password=

spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true

logging.level.com.example=DEBUG
logging.level.org.springframework.web=DEBUG

app.features.email-notifications=false
app.features.debug-mode=true
```

### application-prod.properties

```properties
# Production Configuration
server.port=80
spring.datasource.url=${DATABASE_URL}
spring.datasource.username=${DATABASE_USERNAME}
spring.datasource.password=${DATABASE_PASSWORD}

spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false

logging.level.com.example=INFO
logging.level.org.springframework.web=WARN

app.features.email-notifications=true
app.features.debug-mode=false
```

### Profile-Specific Configuration Classes

```java
@Configuration
@Profile("dev")
public class DevelopmentConfig {
    
    @Bean
    public DataSource dataSource() {
        return new EmbeddedDatabaseBuilder()
                .setType(EmbeddedDatabaseType.H2)
                .build();
    }
    
    @Bean
    public EmailService emailService() {
        return new MockEmailService(); // Mock for development
    }
}

@Configuration
@Profile("prod")
public class ProductionConfig {
    
    @Bean
    public DataSource dataSource(@Value("${spring.datasource.url}") String url,
                                @Value("${spring.datasource.username}") String username,
                                @Value("${spring.datasource.password}") String password) {
        HikariDataSource dataSource = new HikariDataSource();
        dataSource.setJdbcUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        return dataSource;
    }
    
    @Bean
    public EmailService emailService() {
        return new SmtpEmailService(); // Real email service
    }
}
```

## Environment Variables

### Using Environment Variables

```properties
# application.properties
spring.datasource.url=${DATABASE_URL:jdbc:h2:mem:testdb}
spring.datasource.username=${DATABASE_USERNAME:sa}
spring.datasource.password=${DATABASE_PASSWORD:}

app.jwt.secret=${JWT_SECRET:defaultsecret}
app.external.api.key=${EXTERNAL_API_KEY:}
```

### Environment Variable Naming

```bash
# Environment variables (uppercase with underscores)
export DATABASE_URL=jdbc:mysql://localhost:3306/proddb
export DATABASE_USERNAME=produser
export DATABASE_PASSWORD=prodpassword
export JWT_SECRET=mysecretkey
export EXTERNAL_API_KEY=abc123xyz

# Spring Boot automatically maps these to properties:
# DATABASE_URL -> database.url or database_url
# JWT_SECRET -> jwt.secret or jwt_secret
```

## Custom Configuration Classes

### Configuration with @Bean

```java
@Configuration
@EnableConfigurationProperties({DatabaseProperties.class, ApplicationProperties.class})
public class AppConfiguration {
    
    @Bean
    public DataSource dataSource(DatabaseProperties databaseProperties) {
        HikariDataSource dataSource = new HikariDataSource();
        dataSource.setJdbcUrl(databaseProperties.getUrl());
        dataSource.setUsername(databaseProperties.getUsername());
        dataSource.setPassword(databaseProperties.getPassword());
        dataSource.setMinimumIdle(databaseProperties.getMinConnections());
        dataSource.setMaximumPoolSize(databaseProperties.getMaxConnections());
        dataSource.setConnectionTimeout(databaseProperties.getConnectionTimeout());
        return dataSource;
    }
    
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
    
    @Bean
    @ConditionalOnProperty(name = "app.features.caching", havingValue = "true")
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager("users", "products");
    }
}
```

## Conditional Configuration

### @ConditionalOnProperty

```java
@Configuration
public class ConditionalConfiguration {
    
    @Bean
    @ConditionalOnProperty(name = "app.features.email-notifications", havingValue = "true")
    public EmailService emailService() {
        return new SmtpEmailService();
    }
    
    @Bean
    @ConditionalOnProperty(name = "app.features.email-notifications", havingValue = "false", matchIfMissing = true)
    public EmailService mockEmailService() {
        return new MockEmailService();
    }
    
    @Bean
    @ConditionalOnProperty(name = "app.cache.enabled", havingValue = "true")
    public CacheService cacheService() {
        return new RedisCacheService();
    }
}
```

### @ConditionalOnClass

```java
@Configuration
public class AutoConfiguration {
    
    @Bean
    @ConditionalOnClass(RedisTemplate.class)
    public RedisService redisService() {
        return new RedisService();
    }
    
    @Bean
    @ConditionalOnClass(name = "com.amazonaws.services.s3.AmazonS3")
    public S3Service s3Service() {
        return new S3Service();
    }
}
```

## Configuration Metadata

### META-INF/spring-configuration-metadata.json

```json
{
  "properties": [
    {
      "name": "app.name",
      "type": "java.lang.String",
      "description": "The name of the application",
      "defaultValue": "My App"
    },
    {
      "name": "app.admin.email",
      "type": "java.lang.String",
      "description": "Administrator email address"
    },
    {
      "name": "app.features.email-notifications",
      "type": "java.lang.Boolean",
      "description": "Enable or disable email notifications",
      "defaultValue": true
    }
  ]
}
```

## Testing Configuration

### Test Properties

```java
@SpringBootTest
@TestPropertySource(properties = {
    "app.name=Test Application",
    "app.features.email-notifications=false",
    "spring.datasource.url=jdbc:h2:mem:testdb"
})
class ConfigurationTest {
    
    @Autowired
    private ApplicationProperties applicationProperties;
    
    @Test
    void shouldLoadTestProperties() {
        assertThat(applicationProperties.getName()).isEqualTo("Test Application");
        assertThat(applicationProperties.getFeatures().isEmailNotifications()).isFalse();
    }
}
```

### Test Configuration Files

```properties
# application-test.properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.jpa.hibernate.ddl-auto=create-drop
app.features.email-notifications=false
logging.level.com.example=DEBUG
```

## Best Practices

1. **Use @ConfigurationProperties** - Type-safe configuration over @Value
2. **Validate Configuration** - Add validation annotations
3. **Use Profiles** - Separate configuration for different environments
4. **Environment Variables** - Use for sensitive data in production
5. **Default Values** - Provide sensible defaults
6. **Documentation** - Document configuration properties
7. **Immutable Configuration** - Make configuration objects immutable when possible
8. **Hierarchical Properties** - Use nested objects for related properties
9. **Property Naming** - Use kebab-case for property names
10. **Test Configuration** - Test different configuration scenarios

## Common Pitfalls

1. **Missing @EnableConfigurationProperties** - Configuration properties not loaded
2. **Wrong Property Names** - Typos in property names
3. **Type Mismatches** - Wrong data types in properties
4. **Missing Validation** - Invalid configuration not caught
5. **Hardcoded Values** - Not using configuration for environment-specific values
6. **Circular Dependencies** - Configuration beans depending on each other
7. **Profile Conflicts** - Conflicting properties in different profiles
8. **Security Issues** - Exposing sensitive data in configuration files