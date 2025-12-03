# Spring Boot Interview Questions

## Beginner Level Questions (1-2 Years Experience)

### 1. What is Spring Boot and why is it used?

**Answer:**
Spring Boot is a framework that makes it easy to create stand-alone, production-grade Spring-based applications with minimal configuration.

**Key Benefits:**
- **Auto Configuration** - Automatically configures application based on dependencies
- **Embedded Servers** - No need to deploy WAR files
- **Starter Dependencies** - Pre-configured dependency sets
- **Production Ready** - Built-in monitoring and health checks
- **Convention over Configuration** - Reduces boilerplate code

**Example:**
```java
@SpringBootApplication
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}
```

### 2. What is @SpringBootApplication annotation?

**Answer:**
@SpringBootApplication is a convenience annotation that combines three annotations:

```java
@SpringBootApplication
// Equivalent to:
@Configuration      // Marks class as configuration source
@EnableAutoConfiguration  // Enables auto-configuration
@ComponentScan     // Enables component scanning
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

### 3. What are Spring Boot Starters?

**Answer:**
Starters are pre-configured dependency descriptors that include all necessary dependencies for a particular functionality.

**Common Starters:**
```xml
<!-- Web applications -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- Data JPA -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

### 4. How do you create a REST API in Spring Boot?

**Answer:**
```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping
    public List<User> getAllUsers() {
        return userService.findAll();
    }
    
    @GetMapping("/{id}")
    public User getUserById(@PathVariable Long id) {
        return userService.findById(id);
    }
    
    @PostMapping
    public User createUser(@RequestBody User user) {
        return userService.save(user);
    }
    
    @PutMapping("/{id}")
    public User updateUser(@PathVariable Long id, @RequestBody User user) {
        return userService.update(id, user);
    }
    
    @DeleteMapping("/{id}")
    public void deleteUser(@PathVariable Long id) {
        userService.delete(id);
    }
}
```

### 5. What is the difference between @Controller and @RestController?

**Answer:**

| @Controller | @RestController |
|-------------|-----------------|
| Returns view names | Returns data directly |
| Used for web pages | Used for REST APIs |
| Needs @ResponseBody for JSON | @ResponseBody included |

```java
@Controller
public class WebController {
    @RequestMapping("/home")
    public String home() {
        return "index"; // Returns view name
    }
    
    @RequestMapping("/api/data")
    @ResponseBody // Needed for JSON response
    public User getData() {
        return new User();
    }
}

@RestController // Combines @Controller + @ResponseBody
public class ApiController {
    @GetMapping("/users")
    public List<User> getUsers() {
        return users; // Automatically converted to JSON
    }
}
```

### 6. How do you handle exceptions in Spring Boot?

**Answer:**
```java
// Custom Exception
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(String message) {
        super(message);
    }
}

// Global Exception Handler
@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFound(UserNotFoundException e) {
        ErrorResponse error = new ErrorResponse("USER_NOT_FOUND", e.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneral(Exception e) {
        ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Something went wrong");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}
```

### 7. What is Spring Boot Actuator?

**Answer:**
Actuator provides production-ready features like monitoring, metrics, and health checks.

**Configuration:**
```properties
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=always
```

**Built-in Endpoints:**
- `/actuator/health` - Application health
- `/actuator/info` - Application information
- `/actuator/metrics` - Application metrics
- `/actuator/env` - Environment properties

### 8. How do you configure a database in Spring Boot?

**Answer:**
```properties
# application.properties
spring.datasource.url=jdbc:mysql://localhost:3306/mydb
spring.datasource.username=root
spring.datasource.password=password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

```java
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    // Getters and setters
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    List<User> findByName(String name);
}
```

## Intermediate Level Questions (2-4 Years Experience)

### 9. What is Auto Configuration in Spring Boot?

**Answer:**
Auto Configuration automatically configures Spring application based on the dependencies present in the classpath.

**How it works:**
1. Spring Boot scans classpath for dependencies
2. Applies conditional configuration based on what's found
3. Creates beans automatically if not already defined

**Example:**
```java
@Configuration
@ConditionalOnClass(DataSource.class)
@ConditionalOnMissingBean(DataSource.class)
public class DataSourceAutoConfiguration {
    
    @Bean
    public DataSource dataSource() {
        return new HikariDataSource();
    }
}
```

**Conditional Annotations:**
- `@ConditionalOnClass` - If class is present
- `@ConditionalOnMissingBean` - If bean is not defined
- `@ConditionalOnProperty` - If property is set

### 10. How do you implement security in Spring Boot?

**Answer:**
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login")
                .defaultSuccessUrl("/dashboard")
            )
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login")
            );
        
        return http.build();
    }
}
```

### 11. What are Spring Profiles and how do you use them?

**Answer:**
Profiles allow you to segregate parts of your application configuration for different environments.

**Configuration:**
```properties
# application.properties
spring.profiles.active=dev

# application-dev.properties
server.port=8080
spring.datasource.url=jdbc:h2:mem:devdb

# application-prod.properties
server.port=80
spring.datasource.url=jdbc:mysql://prod-server:3306/proddb
```

**Profile-specific Beans:**
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
        return dataSource;
    }
}
```

### 12. How do you implement caching in Spring Boot?

**Answer:**
```java
@SpringBootApplication
@EnableCaching
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

@Service
public class UserService {
    
    @Cacheable(value = "users", key = "#id")
    public User findById(Long id) {
        // This will be cached
        return userRepository.findById(id).orElse(null);
    }
    
    @CacheEvict(value = "users", key = "#user.id")
    public User updateUser(User user) {
        return userRepository.save(user);
    }
    
    @CacheEvict(value = "users", allEntries = true)
    public void clearAllCache() {
        // Clear all cache entries
    }
}
```

### 13. What is @Transactional and how does it work?

**Answer:**
@Transactional manages database transactions automatically.

```java
@Service
@Transactional
public class UserService {
    
    @Transactional(readOnly = true)
    public List<User> findAll() {
        return userRepository.findAll();
    }
    
    @Transactional
    public User createUserWithProfile(User user, Profile profile) {
        User savedUser = userRepository.save(user);
        profile.setUser(savedUser);
        profileRepository.save(profile);
        
        // If any exception occurs, both operations will rollback
        return savedUser;
    }
    
    @Transactional(rollbackFor = Exception.class)
    public void processPayment(Payment payment) {
        // Rollback for any exception
    }
}
```

**Transaction Properties:**
- `readOnly` - Optimization for read operations
- `rollbackFor` - Specify exceptions that trigger rollback
- `propagation` - How transactions relate to each other
- `isolation` - Transaction isolation level

### 14. How do you test Spring Boot applications?

**Answer:**
```java
// Unit Test
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void shouldFindUserById() {
        // Given
        User user = new User("John", "john@email.com");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        
        // When
        User result = userService.findById(1L);
        
        // Then
        assertThat(result.getName()).isEqualTo("John");
    }
}

// Integration Test
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UserControllerIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void shouldCreateUser() {
        User user = new User("John", "john@email.com");
        
        ResponseEntity<User> response = restTemplate.postForEntity("/api/users", user, User.class);
        
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody().getName()).isEqualTo("John");
    }
}

// Web Layer Test
@WebMvcTest(UserController.class)
class UserControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void shouldGetUser() throws Exception {
        User user = new User("John", "john@email.com");
        when(userService.findById(1L)).thenReturn(user);
        
        mockMvc.perform(get("/api/users/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("John"));
    }
}
```

## Advanced Level Questions (4+ Years Experience)

### 15. How does Spring Boot Auto Configuration work internally?

**Answer:**
Auto Configuration uses several mechanisms:

1. **@EnableAutoConfiguration** triggers auto-configuration
2. **spring.factories** file lists auto-configuration classes
3. **Conditional annotations** determine when to apply configuration

**Process:**
```java
// 1. @EnableAutoConfiguration imports AutoConfigurationImportSelector
@EnableAutoConfiguration
public class Application { }

// 2. AutoConfigurationImportSelector reads spring.factories
// META-INF/spring.factories
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
com.example.MyAutoConfiguration

// 3. Conditional configuration
@Configuration
@ConditionalOnClass(DataSource.class)
@ConditionalOnMissingBean(DataSource.class)
public class DataSourceAutoConfiguration {
    
    @Bean
    @ConditionalOnProperty(name = "spring.datasource.url")
    public DataSource dataSource() {
        return DataSourceBuilder.create().build();
    }
}
```

### 16. How do you create a custom Spring Boot Starter?

**Answer:**
```java
// 1. Auto Configuration Class
@Configuration
@ConditionalOnClass(MyService.class)
@EnableConfigurationProperties(MyServiceProperties.class)
public class MyServiceAutoConfiguration {
    
    @Bean
    @ConditionalOnMissingBean
    public MyService myService(MyServiceProperties properties) {
        return new MyService(properties);
    }
}

// 2. Properties Class
@ConfigurationProperties(prefix = "myservice")
public class MyServiceProperties {
    private boolean enabled = true;
    private String apiKey;
    private int timeout = 5000;
    
    // Getters and setters
}

// 3. Service Class
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

// 4. META-INF/spring.factories
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
com.example.MyServiceAutoConfiguration
```

### 17. How do you implement custom metrics in Spring Boot?

**Answer:**
```java
@Service
public class UserService {
    
    private final MeterRegistry meterRegistry;
    private final Counter userCreationCounter;
    private final Timer userProcessingTimer;
    private final Gauge activeUsersGauge;
    
    public UserService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        
        // Counter - monotonically increasing
        this.userCreationCounter = Counter.builder("users.created")
                .description("Number of users created")
                .tag("service", "user")
                .register(meterRegistry);
        
        // Timer - measures duration
        this.userProcessingTimer = Timer.builder("users.processing.time")
                .description("User processing time")
                .register(meterRegistry);
        
        // Gauge - current value
        this.activeUsersGauge = Gauge.builder("users.active")
                .description("Number of active users")
                .register(meterRegistry, this, UserService::getActiveUserCount);
    }
    
    public User createUser(User user) {
        return userProcessingTimer.recordCallable(() -> {
            User savedUser = userRepository.save(user);
            userCreationCounter.increment();
            return savedUser;
        });
    }
    
    private double getActiveUserCount() {
        return userRepository.countByActiveTrue();
    }
}
```

### 18. How do you implement async processing in Spring Boot?

**Answer:**
```java
@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {
    
    @Override
    @Bean(name = "taskExecutor")
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("Async-");
        executor.initialize();
        return executor;
    }
    
    @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
        return (ex, method, params) -> {
            System.err.println("Async method " + method.getName() + " threw exception: " + ex.getMessage());
        };
    }
}

@Service
public class EmailService {
    
    @Async
    public CompletableFuture<String> sendEmail(String to, String subject, String body) {
        try {
            // Simulate email sending
            Thread.sleep(2000);
            return CompletableFuture.completedFuture("Email sent to " + to);
        } catch (InterruptedException e) {
            return CompletableFuture.failedFuture(e);
        }
    }
    
    @Async("taskExecutor")
    public void processUserRegistration(User user) {
        // Long running process
        System.out.println("Processing user: " + user.getName());
    }
}
```

### 19. How do you implement event-driven architecture in Spring Boot?

**Answer:**
```java
// 1. Custom Event
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

// 2. Event Publisher
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

// 3. Event Listeners
@Component
public class UserEventListener {
    
    @EventListener
    public void handleUserRegistered(UserRegisteredEvent event) {
        User user = event.getUser();
        System.out.println("User registered: " + user.getName());
        // Send welcome email
    }
    
    @EventListener
    @Async
    public void handleUserRegisteredAsync(UserRegisteredEvent event) {
        // Handle asynchronously
        User user = event.getUser();
        // Long running operations
    }
    
    @EventListener(condition = "#event.user.age >= 18")
    public void handleAdultUserRegistered(UserRegisteredEvent event) {
        // Handle only adult users
    }
}

// 4. Transaction Event Listeners
@Component
public class UserTransactionEventListener {
    
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleUserRegisteredAfterCommit(UserRegisteredEvent event) {
        // Execute only after transaction commits
    }
    
    @TransactionalEventListener(phase = TransactionPhase.AFTER_ROLLBACK)
    public void handleUserRegisteredAfterRollback(UserRegisteredEvent event) {
        // Execute only after transaction rollback
    }
}
```

### 20. How do you implement custom health indicators?

**Answer:**
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

@Component
public class ExternalServiceHealthIndicator implements HealthIndicator {
    
    @Autowired
    private RestTemplate restTemplate;
    
    @Override
    public Health health() {
        try {
            ResponseEntity<String> response = restTemplate.getForEntity(
                "https://api.external-service.com/health", String.class);
            
            if (response.getStatusCode().is2xxSuccessful()) {
                return Health.up()
                        .withDetail("external-service", "Available")
                        .withDetail("status", response.getStatusCode())
                        .build();
            } else {
                return Health.down()
                        .withDetail("external-service", "Unavailable")
                        .withDetail("status", response.getStatusCode())
                        .build();
            }
        } catch (Exception e) {
            return Health.down()
                    .withDetail("external-service", "Unavailable")
                    .withException(e)
                    .build();
        }
    }
}
```

## Scenario-Based Questions

### 21. How would you handle a situation where your Spring Boot application is running out of memory?

**Answer:**
1. **Analyze heap dump** using tools like Eclipse MAT
2. **Check for memory leaks** in custom code
3. **Optimize database queries** and use pagination
4. **Implement caching** strategically
5. **Tune JVM parameters**

```java
// Example: Implement pagination
@GetMapping("/users")
public Page<User> getUsers(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size) {
    
    Pageable pageable = PageRequest.of(page, size);
    return userService.findAll(pageable);
}

// Example: Use @Transactional(readOnly = true) for read operations
@Transactional(readOnly = true)
public List<User> findAllUsers() {
    return userRepository.findAll();
}
```

### 22. How would you implement rate limiting in Spring Boot?

**Answer:**
```java
@Component
public class RateLimitingFilter implements Filter {
    
    private final Map<String, List<Long>> requestCounts = new ConcurrentHashMap<>();
    private final int MAX_REQUESTS = 100;
    private final long TIME_WINDOW = 60000; // 1 minute
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, 
                        FilterChain chain) throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String clientIp = httpRequest.getRemoteAddr();
        
        if (isRateLimited(clientIp)) {
            HttpServletResponse httpResponse = (HttpServletResponse) response;
            httpResponse.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            httpResponse.getWriter().write("Rate limit exceeded");
            return;
        }
        
        chain.doFilter(request, response);
    }
    
    private boolean isRateLimited(String clientIp) {
        long currentTime = System.currentTimeMillis();
        requestCounts.putIfAbsent(clientIp, new ArrayList<>());
        
        List<Long> requests = requestCounts.get(clientIp);
        
        // Remove old requests outside time window
        requests.removeIf(time -> currentTime - time > TIME_WINDOW);
        
        if (requests.size() >= MAX_REQUESTS) {
            return true;
        }
        
        requests.add(currentTime);
        return false;
    }
}
```

## Tips for Interview Success

1. **Understand the fundamentals** - Know Spring Boot core concepts well
2. **Practice coding** - Be ready to write code during interviews
3. **Know the ecosystem** - Understand related technologies (Docker, Kubernetes, etc.)
4. **Real-world experience** - Be prepared to discuss projects you've worked on
5. **Stay updated** - Know the latest Spring Boot features and versions
6. **Problem-solving** - Focus on how you approach and solve problems
7. **Best practices** - Demonstrate knowledge of coding standards and patterns
8. **Testing** - Show understanding of different testing strategies
9. **Performance** - Know how to optimize Spring Boot applications
10. **Communication** - Explain concepts clearly and concisely