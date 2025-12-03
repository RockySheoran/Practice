# Spring Boot Advanced Topics

## Actuator - Production Monitoring

### What is Actuator?
Spring Boot Actuator provides production-ready features like monitoring, metrics, and health checks.

### Dependencies

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

### Configuration

```properties
# Enable all actuator endpoints
management.endpoints.web.exposure.include=*

# Enable specific endpoints
management.endpoints.web.exposure.include=health,info,metrics

# Customize endpoint paths
management.endpoints.web.base-path=/actuator
management.endpoint.health.show-details=always

# Security for actuator endpoints
management.endpoints.web.exposure.exclude=shutdown
```

### Built-in Endpoints

```java
// Health endpoint - /actuator/health
// Info endpoint - /actuator/info
// Metrics endpoint - /actuator/metrics
// Environment endpoint - /actuator/env
// Beans endpoint - /actuator/beans
```

### Custom Health Indicator

```java
@Component
public class DatabaseHealthIndicator implements HealthIndicator {
    
    @Autowired
    private DataSource dataSource;
    
    @Override
    public Health health() {
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(1)) {
                return Health.up()
                        .withDetail("database", "Available")
                        .withDetail("validationQuery", "SELECT 1")
                        .build();
            }
        } catch (Exception e) {
            return Health.down()
                    .withDetail("database", "Unavailable")
                    .withException(e)
                    .build();
        }
        
        return Health.down()
                .withDetail("database", "Connection validation failed")
                .build();
    }
}
```

### Custom Metrics

```java
@Service
public class UserService {
    
    private final MeterRegistry meterRegistry;
    private final Counter userCreationCounter;
    private final Timer userProcessingTimer;
    
    public UserService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.userCreationCounter = Counter.builder("users.created")
                .description("Number of users created")
                .register(meterRegistry);
        this.userProcessingTimer = Timer.builder("users.processing.time")
                .description("User processing time")
                .register(meterRegistry);
    }
    
    public User createUser(User user) {
        return userProcessingTimer.recordCallable(() -> {
            User savedUser = userRepository.save(user);
            userCreationCounter.increment();
            
            // Custom gauge
            Gauge.builder("users.active.count")
                    .description("Number of active users")
                    .register(meterRegistry, this, UserService::getActiveUserCount);
            
            return savedUser;
        });
    }
    
    private double getActiveUserCount() {
        return userRepository.countByActiveTrue();
    }
}
```

## Caching

### Dependencies

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>

<!-- Redis Cache -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

### Enable Caching

```java
@SpringBootApplication
@EnableCaching
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

### Cache Configuration

```java
@Configuration
@EnableCaching
public class CacheConfig {
    
    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager cacheManager = new CaffeineCacheManager("users", "posts");
        cacheManager.setCaffeine(Caffeine.newBuilder()
                .initialCapacity(100)
                .maximumSize(500)
                .expireAfterAccess(10, TimeUnit.MINUTES)
                .recordStats());
        return cacheManager;
    }
    
    // Redis Cache Manager
    @Bean
    public CacheManager redisCacheManager(RedisConnectionFactory connectionFactory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofMinutes(10))
                .serializeKeysWith(RedisSerializationContext.SerializationPair
                        .fromSerializer(new StringRedisSerializer()))
                .serializeValuesWith(RedisSerializationContext.SerializationPair
                        .fromSerializer(new GenericJackson2JsonRedisSerializer()));
        
        return RedisCacheManager.builder(connectionFactory)
                .cacheDefaults(config)
                .build();
    }
}
```

### Cache Annotations

#### @Cacheable
**Purpose**: Caches method results
**What it does**: Stores method return value in cache

```java
@Service
public class UserService {
    
    @Cacheable(value = "users", key = "#id")
    public User findById(Long id) {
        System.out.println("Fetching user from database: " + id);
        return userRepository.findById(id).orElse(null);
    }
    
    @Cacheable(value = "users", key = "#email")
    public User findByEmail(String email) {
        return userRepository.findByEmail(email).orElse(null);
    }
    
    // Conditional caching
    @Cacheable(value = "users", condition = "#age > 18")
    public List<User> findUsersByAge(int age) {
        return userRepository.findByAge(age);
    }
}
```

#### @CacheEvict
**Purpose**: Removes entries from cache
**What it does**: Clears cache when data is modified

```java
@Service
public class UserService {
    
    @CacheEvict(value = "users", key = "#user.id")
    public User updateUser(User user) {
        return userRepository.save(user);
    }
    
    @CacheEvict(value = "users", key = "#id")
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
    
    // Clear all cache entries
    @CacheEvict(value = "users", allEntries = true)
    public void clearAllUsers() {
        // Clear all user cache
    }
}
```

#### @CachePut
**Purpose**: Always executes method and updates cache
**What it does**: Updates cache with new value

```java
@Service
public class UserService {
    
    @CachePut(value = "users", key = "#user.id")
    public User saveUser(User user) {
        return userRepository.save(user);
    }
}
```

#### @Caching
**Purpose**: Groups multiple cache operations
**What it does**: Combines multiple cache annotations

```java
@Service
public class UserService {
    
    @Caching(evict = {
        @CacheEvict(value = "users", key = "#user.id"),
        @CacheEvict(value = "users", key = "#user.email")
    })
    public User updateUser(User user) {
        return userRepository.save(user);
    }
}
```

## Async Processing

### Enable Async

```java
@SpringBootApplication
@EnableAsync
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

### Async Configuration

```java
@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {
    
    @Override
    @Bean(name = "taskExecutor")
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(500);
        executor.setThreadNamePrefix("Async-");
        executor.initialize();
        return executor;
    }
    
    @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
        return new SimpleAsyncUncaughtExceptionHandler();
    }
}
```

### @Async Annotation
**Purpose**: Executes method asynchronously
**What it does**: Runs method in separate thread

```java
@Service
public class EmailService {
    
    @Async
    public CompletableFuture<String> sendEmail(String to, String subject, String body) {
        try {
            // Simulate email sending
            Thread.sleep(2000);
            System.out.println("Email sent to: " + to);
            return CompletableFuture.completedFuture("Email sent successfully");
        } catch (InterruptedException e) {
            return CompletableFuture.failedFuture(e);
        }
    }
    
    @Async("taskExecutor")
    public void processUserRegistration(User user) {
        // Long running process
        System.out.println("Processing user registration: " + user.getName());
        // Send welcome email, setup user profile, etc.
    }
}

// Usage
@RestController
public class UserController {
    
    @Autowired
    private EmailService emailService;
    
    @PostMapping("/users")
    public ResponseEntity<String> createUser(@RequestBody User user) {
        // Save user synchronously
        User savedUser = userService.save(user);
        
        // Send email asynchronously
        emailService.sendEmail(user.getEmail(), "Welcome", "Welcome to our platform!");
        
        return ResponseEntity.ok("User created successfully");
    }
}
```

## Scheduling

### Enable Scheduling

```java
@SpringBootApplication
@EnableScheduling
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

### @Scheduled Annotation
**Purpose**: Executes method on schedule
**What it does**: Runs method at specified intervals

```java
@Component
public class ScheduledTasks {
    
    private static final Logger logger = LoggerFactory.getLogger(ScheduledTasks.class);
    
    // Fixed rate - every 5 seconds
    @Scheduled(fixedRate = 5000)
    public void reportCurrentTime() {
        logger.info("Current time: {}", LocalDateTime.now());
    }
    
    // Fixed delay - 5 seconds after previous execution completes
    @Scheduled(fixedDelay = 5000)
    public void processData() {
        logger.info("Processing data...");
        // Simulate processing time
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
    
    // Cron expression - every day at 2 AM
    @Scheduled(cron = "0 0 2 * * ?")
    public void performDailyCleanup() {
        logger.info("Performing daily cleanup...");
        // Cleanup logic
    }
    
    // Cron with timezone
    @Scheduled(cron = "0 0 12 * * ?", zone = "America/New_York")
    public void noonReport() {
        logger.info("Noon report in New York timezone");
    }
    
    // Initial delay
    @Scheduled(fixedRate = 10000, initialDelay = 5000)
    public void startAfterDelay() {
        logger.info("Started after initial delay");
    }
}
```

## Events and Listeners

### Application Events

```java
// Custom Event
public class UserRegisteredEvent extends ApplicationEvent {
    private final User user;
    
    public UserRegisteredEvent(Object source, User user) {
        super(source);
        this.user = user;
    }
    
    public User getUser() {
        return user;
    }
}

// Event Publisher
@Service
public class UserService {
    
    @Autowired
    private ApplicationEventPublisher eventPublisher;
    
    public User registerUser(User user) {
        User savedUser = userRepository.save(user);
        
        // Publish event
        eventPublisher.publishEvent(new UserRegisteredEvent(this, savedUser));
        
        return savedUser;
    }
}

// Event Listener
@Component
public class UserEventListener {
    
    @EventListener
    public void handleUserRegistered(UserRegisteredEvent event) {
        User user = event.getUser();
        System.out.println("User registered: " + user.getName());
        
        // Send welcome email, create user profile, etc.
    }
    
    @EventListener
    @Async
    public void handleUserRegisteredAsync(UserRegisteredEvent event) {
        // Handle event asynchronously
        User user = event.getUser();
        // Long running operations
    }
    
    // Conditional event handling
    @EventListener(condition = "#event.user.age >= 18")
    public void handleAdultUserRegistered(UserRegisteredEvent event) {
        // Handle only adult users
    }
}
```

## Profiles

### Profile Configuration

```properties
# application.properties
spring.profiles.active=dev

# application-dev.properties
server.port=8080
spring.datasource.url=jdbc:h2:mem:devdb
logging.level.root=DEBUG

# application-prod.properties
server.port=80
spring.datasource.url=jdbc:mysql://prod-server:3306/proddb
logging.level.root=WARN
```

### Profile-specific Beans

```java
@Configuration
public class DatabaseConfig {
    
    @Bean
    @Profile("dev")
    public DataSource devDataSource() {
        return new EmbeddedDatabaseBuilder()
                .setType(EmbeddedDatabaseType.H2)
                .build();
    }
    
    @Bean
    @Profile("prod")
    public DataSource prodDataSource() {
        HikariDataSource dataSource = new HikariDataSource();
        dataSource.setJdbcUrl("jdbc:mysql://prod-server:3306/proddb");
        dataSource.setUsername("prod_user");
        dataSource.setPassword("prod_password");
        return dataSource;
    }
    
    @Bean
    @Profile("!prod") // Not production
    public DataSource testDataSource() {
        return new EmbeddedDatabaseBuilder()
                .setType(EmbeddedDatabaseType.H2)
                .build();
    }
}
```

## Custom Auto Configuration

### Auto Configuration Class

```java
@Configuration
@ConditionalOnClass(MyService.class)
@ConditionalOnProperty(name = "myservice.enabled", havingValue = "true", matchIfMissing = true)
@EnableConfigurationProperties(MyServiceProperties.class)
public class MyServiceAutoConfiguration {
    
    @Bean
    @ConditionalOnMissingBean
    public MyService myService(MyServiceProperties properties) {
        return new MyService(properties);
    }
}

// Properties class
@ConfigurationProperties(prefix = "myservice")
public class MyServiceProperties {
    private boolean enabled = true;
    private String apiKey;
    private int timeout = 5000;
    
    // Getters and setters
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    
    public String getApiKey() { return apiKey; }
    public void setApiKey(String apiKey) { this.apiKey = apiKey; }
    
    public int getTimeout() { return timeout; }
    public void setTimeout(int timeout) { this.timeout = timeout; }
}

// Service class
public class MyService {
    private final MyServiceProperties properties;
    
    public MyService(MyServiceProperties properties) {
        this.properties = properties;
    }
    
    public void doSomething() {
        if (properties.isEnabled()) {
            // Service logic
        }
    }
}
```

### Register Auto Configuration

```
# META-INF/spring.factories
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
com.example.autoconfigure.MyServiceAutoConfiguration
```

## Custom Starter

### Starter Structure

```
my-spring-boot-starter/
├── src/main/java/
│   └── com/example/starter/
│       ├── MyServiceAutoConfiguration.java
│       ├── MyServiceProperties.java
│       └── MyService.java
├── src/main/resources/
│   └── META-INF/
│       └── spring.factories
└── pom.xml
```

### Starter POM

```xml
<project>
    <groupId>com.example</groupId>
    <artifactId>my-spring-boot-starter</artifactId>
    <version>1.0.0</version>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-configuration-processor</artifactId>
            <optional>true</optional>
        </dependency>
    </dependencies>
</project>
```

## Externalized Configuration

### Configuration Sources (Priority Order)

1. Command line arguments
2. JNDI attributes
3. Java System properties
4. OS environment variables
5. Profile-specific properties
6. Application properties
7. @PropertySource annotations
8. Default properties

### Using @ConfigurationProperties

```java
@ConfigurationProperties(prefix = "app")
@Component
public class AppProperties {
    
    private String name;
    private String version;
    private Security security = new Security();
    private List<String> servers = new ArrayList<>();
    private Map<String, String> database = new HashMap<>();
    
    // Nested class
    public static class Security {
        private String username;
        private String password;
        private List<String> roles = new ArrayList<>();
        
        // Getters and setters
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
        
        public List<String> getRoles() { return roles; }
        public void setRoles(List<String> roles) { this.roles = roles; }
    }
    
    // Getters and setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getVersion() { return version; }
    public void setVersion(String version) { this.version = version; }
    
    public Security getSecurity() { return security; }
    public void setSecurity(Security security) { this.security = security; }
    
    public List<String> getServers() { return servers; }
    public void setServers(List<String> servers) { this.servers = servers; }
    
    public Map<String, String> getDatabase() { return database; }
    public void setDatabase(Map<String, String> database) { this.database = database; }
}
```

### Properties File

```yaml
# application.yml
app:
  name: My Application
  version: 1.0.0
  security:
    username: admin
    password: secret
    roles:
      - ADMIN
      - USER
  servers:
    - server1.example.com
    - server2.example.com
  database:
    url: jdbc:mysql://localhost:3306/mydb
    driver: com.mysql.cj.jdbc.Driver
```

## Best Practices

1. **Use appropriate annotations** - Choose the right annotation for the task
2. **Configure thread pools** - Customize async and scheduling thread pools
3. **Monitor performance** - Use Actuator metrics and custom metrics
4. **Handle exceptions** - Implement proper exception handling for async operations
5. **Use profiles wisely** - Separate configurations for different environments
6. **Cache strategically** - Cache expensive operations, not everything
7. **Event-driven architecture** - Use events for loose coupling
8. **External configuration** - Keep configuration outside the code
9. **Custom starters** - Create reusable components
10. **Production readiness** - Use Actuator for monitoring and health checks