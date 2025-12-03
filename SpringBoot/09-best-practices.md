# Spring Boot Best Practices

## Project Structure

### Recommended Package Structure

```
com.example.myapp/
├── MyAppApplication.java          # Main application class
├── config/                        # Configuration classes
│   ├── DatabaseConfig.java
│   ├── SecurityConfig.java
│   └── WebConfig.java
├── controller/                    # REST controllers
│   ├── UserController.java
│   └── ProductController.java
├── service/                       # Business logic
│   ├── UserService.java
│   ├── UserServiceImpl.java
│   └── ProductService.java
├── repository/                    # Data access layer
│   ├── UserRepository.java
│   └── ProductRepository.java
├── model/                         # Entity classes
│   ├── User.java
│   └── Product.java
├── dto/                          # Data Transfer Objects
│   ├── UserDto.java
│   └── ProductDto.java
├── exception/                    # Custom exceptions
│   ├── UserNotFoundException.java
│   └── GlobalExceptionHandler.java
└── util/                         # Utility classes
    ├── DateUtil.java
    └── ValidationUtil.java
```

## Configuration Best Practices

### Use @ConfigurationProperties

**Good Practice:**
```java
@ConfigurationProperties(prefix = "app.database")
@Component
public class DatabaseProperties {
    private String url;
    private String username;
    private String password;
    private int maxConnections = 10;
    private Duration connectionTimeout = Duration.ofSeconds(30);
    
    // Getters and setters with validation
    @NotBlank
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
    
    @Min(1)
    @Max(100)
    public int getMaxConnections() { return maxConnections; }
    public void setMaxConnections(int maxConnections) { this.maxConnections = maxConnections; }
}
```

**Avoid:**
```java
// Don't scatter @Value annotations everywhere
@Service
public class DatabaseService {
    @Value("${app.database.url}")
    private String url;
    
    @Value("${app.database.username}")
    private String username;
    
    @Value("${app.database.password}")
    private String password;
}
```

### Environment-Specific Configuration

```yaml
# application.yml (common configuration)
app:
  name: My Application
  version: 1.0.0

spring:
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false

---
# application-dev.yml
spring:
  config:
    activate:
      on-profile: dev
  datasource:
    url: jdbc:h2:mem:devdb
    username: sa
    password: 
  jpa:
    show-sql: true
    hibernate:
      ddl-auto: create-drop

logging:
  level:
    com.example: DEBUG

---
# application-prod.yml
spring:
  config:
    activate:
      on-profile: prod
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}

logging:
  level:
    root: WARN
    com.example: INFO
```

## Dependency Injection Best Practices

### Constructor Injection (Recommended)

**Good Practice:**
```java
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    // Constructor injection - recommended
    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }
    
    // Business methods
}
```

**Avoid Field Injection:**
```java
@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository; // Avoid field injection
    
    @Autowired
    private EmailService emailService; // Hard to test, creates tight coupling
}
```

### Use @RequiredArgsConstructor (Lombok)

```java
@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    // Lombok generates constructor automatically
}
```

## Error Handling Best Practices

### Global Exception Handler

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    
    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFound(UserNotFoundException ex) {
        logger.warn("User not found: {}", ex.getMessage());
        
        ErrorResponse error = ErrorResponse.builder()
                .code("USER_NOT_FOUND")
                .message(ex.getMessage())
                .timestamp(LocalDateTime.now())
                .build();
                
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ValidationErrorResponse> handleValidation(
            MethodArgumentNotValidException ex) {
        
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error -> 
            errors.put(error.getField(), error.getDefaultMessage())
        );
        
        ValidationErrorResponse response = ValidationErrorResponse.builder()
                .code("VALIDATION_FAILED")
                .message("Validation failed")
                .errors(errors)
                .timestamp(LocalDateTime.now())
                .build();
                
        return ResponseEntity.badRequest().body(response);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneral(Exception ex) {
        logger.error("Unexpected error occurred", ex);
        
        ErrorResponse error = ErrorResponse.builder()
                .code("INTERNAL_ERROR")
                .message("An unexpected error occurred")
                .timestamp(LocalDateTime.now())
                .build();
                
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}
```

### Custom Exception Classes

```java
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(String message) {
        super(message);
    }
    
    public UserNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }
    
    public static UserNotFoundException forId(Long id) {
        return new UserNotFoundException("User not found with id: " + id);
    }
    
    public static UserNotFoundException forEmail(String email) {
        return new UserNotFoundException("User not found with email: " + email);
    }
}
```

## Data Transfer Objects (DTOs)

### Use DTOs for API Boundaries

```java
// Request DTO
public class CreateUserRequest {
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    private String name;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;
    
    @Min(value = 18, message = "Age must be at least 18")
    private Integer age;
    
    // Getters and setters
}

// Response DTO
public class UserResponse {
    private Long id;
    private String name;
    private String email;
    private Integer age;
    private LocalDateTime createdAt;
    
    // Static factory method
    public static UserResponse from(User user) {
        UserResponse response = new UserResponse();
        response.setId(user.getId());
        response.setName(user.getName());
        response.setEmail(user.getEmail());
        response.setAge(user.getAge());
        response.setCreatedAt(user.getCreatedAt());
        return response;
    }
    
    // Getters and setters
}
```

### Use MapStruct for Mapping

```java
@Mapper(componentModel = "spring")
public interface UserMapper {
    
    UserResponse toResponse(User user);
    
    User toEntity(CreateUserRequest request);
    
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    User toEntity(UpdateUserRequest request);
    
    List<UserResponse> toResponseList(List<User> users);
}
```

## Service Layer Best Practices

### Interface Segregation

```java
// Good: Focused interfaces
public interface UserService {
    User findById(Long id);
    User save(User user);
    void deleteById(Long id);
    Page<User> findAll(Pageable pageable);
}

public interface UserSearchService {
    List<User> searchByName(String name);
    List<User> searchByEmail(String email);
    List<User> searchByAgeRange(Integer minAge, Integer maxAge);
}

// Implementation
@Service
@Transactional
public class UserServiceImpl implements UserService, UserSearchService {
    
    private final UserRepository userRepository;
    
    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    @Override
    @Transactional(readOnly = true)
    public User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> UserNotFoundException.forId(id));
    }
    
    @Override
    public User save(User user) {
        validateUser(user);
        return userRepository.save(user);
    }
    
    private void validateUser(User user) {
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new DuplicateEmailException("Email already exists: " + user.getEmail());
        }
    }
}
```

## Repository Best Practices

### Use Derived Query Methods

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // Derived query methods
    Optional<User> findByEmail(String email);
    List<User> findByAgeGreaterThan(Integer age);
    List<User> findByNameContainingIgnoreCase(String name);
    boolean existsByEmail(String email);
    
    // Custom queries for complex operations
    @Query("SELECT u FROM User u WHERE u.createdAt BETWEEN :startDate AND :endDate")
    List<User> findUsersCreatedBetween(@Param("startDate") LocalDateTime startDate, 
                                      @Param("endDate") LocalDateTime endDate);
    
    // Native query when needed
    @Query(value = "SELECT * FROM users WHERE email LIKE %:domain%", nativeQuery = true)
    List<User> findUsersByEmailDomain(@Param("domain") String domain);
    
    // Modifying queries
    @Modifying
    @Query("UPDATE User u SET u.lastLoginAt = :loginTime WHERE u.id = :id")
    int updateLastLoginTime(@Param("id") Long id, @Param("loginTime") LocalDateTime loginTime);
}
```

## Controller Best Practices

### RESTful API Design

```java
@RestController
@RequestMapping("/api/v1/users")
@Validated
public class UserController {
    
    private final UserService userService;
    private final UserMapper userMapper;
    
    public UserController(UserService userService, UserMapper userMapper) {
        this.userService = userService;
        this.userMapper = userMapper;
    }
    
    @GetMapping
    public ResponseEntity<Page<UserResponse>> getUsers(
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size,
            @RequestParam(defaultValue = "id") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir) {
        
        Sort sort = Sort.by(Sort.Direction.fromString(sortDir), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        
        Page<User> users = userService.findAll(pageable);
        Page<UserResponse> response = users.map(userMapper::toResponse);
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUser(@PathVariable @Min(1) Long id) {
        User user = userService.findById(id);
        UserResponse response = userMapper.toResponse(user);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
        User user = userMapper.toEntity(request);
        User savedUser = userService.save(user);
        UserResponse response = userMapper.toResponse(savedUser);
        
        URI location = ServletUriComponentsBuilder
                .fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(savedUser.getId())
                .toUri();
                
        return ResponseEntity.created(location).body(response);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable @Min(1) Long id,
            @Valid @RequestBody UpdateUserRequest request) {
        
        User user = userMapper.toEntity(request);
        user.setId(id);
        User updatedUser = userService.update(user);
        UserResponse response = userMapper.toResponse(updatedUser);
        
        return ResponseEntity.ok(response);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable @Min(1) Long id) {
        userService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
```

## Security Best Practices

### Secure Configuration

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {
    
    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final JwtRequestFilter jwtRequestFilter;
    
    public SecurityConfig(JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint,
                         JwtRequestFilter jwtRequestFilter) {
        this.jwtAuthenticationEntryPoint = jwtAuthenticationEntryPoint;
        this.jwtRequestFilter = jwtRequestFilter;
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12); // Use strong cost factor
    }
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Only for APIs
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/v1/auth/**").permitAll()
                .requestMatchers("/api/v1/public/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/v1/users/**").hasAnyRole("USER", "ADMIN")
                .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .exceptionHandling(ex -> ex.authenticationEntryPoint(jwtAuthenticationEntryPoint))
            .addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter.class);
            
        return http.build();
    }
}
```

## Testing Best Practices

### Test Pyramid Structure

```java
// Unit Tests (70%)
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserServiceImpl userService;
    
    @Test
    void shouldFindUserById() {
        // Given
        User user = createTestUser();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        
        // When
        User result = userService.findById(1L);
        
        // Then
        assertThat(result).isEqualTo(user);
    }
    
    private User createTestUser() {
        return User.builder()
                .id(1L)
                .name("John Doe")
                .email("john@example.com")
                .age(25)
                .build();
    }
}

// Integration Tests (20%)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(locations = "classpath:application-test.properties")
class UserIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void shouldCreateAndRetrieveUser() {
        // Test full flow
    }
}

// End-to-End Tests (10%)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class UserE2ETest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:13")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");
    
    @Test
    void shouldHandleCompleteUserWorkflow() {
        // Test complete user journey
    }
}
```

## Performance Best Practices

### Database Optimization

```java
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_created_at", columnList = "created_at")
})
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    // Use appropriate fetch types
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Order> orders = new ArrayList<>();
    
    // Use @BatchSize for N+1 problem
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    @BatchSize(size = 10)
    private List<Address> addresses = new ArrayList<>();
}

// Repository with pagination
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    @Query("SELECT u FROM User u LEFT JOIN FETCH u.orders WHERE u.id = :id")
    Optional<User> findByIdWithOrders(@Param("id") Long id);
    
    // Use Slice for better performance when total count is not needed
    Slice<User> findByAgeGreaterThan(Integer age, Pageable pageable);
}
```

### Caching Strategy

```java
@Service
@CacheConfig(cacheNames = "users")
public class UserService {
    
    @Cacheable(key = "#id")
    public User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> UserNotFoundException.forId(id));
    }
    
    @CacheEvict(key = "#user.id")
    public User update(User user) {
        return userRepository.save(user);
    }
    
    @CacheEvict(allEntries = true)
    public void clearCache() {
        // Clear all user cache
    }
}
```

## Monitoring and Observability

### Actuator Configuration

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
  metrics:
    export:
      prometheus:
        enabled: true
```

### Custom Metrics

```java
@Service
public class UserService {
    
    private final Counter userCreationCounter;
    private final Timer userProcessingTimer;
    
    public UserService(MeterRegistry meterRegistry) {
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
            return savedUser;
        });
    }
}
```

## Documentation Best Practices

### OpenAPI Documentation

```java
@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "User Management", description = "APIs for managing users")
public class UserController {
    
    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID", description = "Retrieves a user by their unique identifier")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "User found"),
        @ApiResponse(responseCode = "404", description = "User not found"),
        @ApiResponse(responseCode = "400", description = "Invalid ID format")
    })
    public ResponseEntity<UserResponse> getUser(
            @Parameter(description = "User ID", example = "1")
            @PathVariable Long id) {
        // Implementation
    }
}
```

## Common Anti-Patterns to Avoid

### 1. God Classes
```java
// Avoid: Single class doing too much
@Service
public class UserService {
    // 50+ methods handling everything user-related
}

// Better: Split responsibilities
@Service
public class UserService { /* Core user operations */ }

@Service
public class UserSearchService { /* Search operations */ }

@Service
public class UserNotificationService { /* Notification operations */ }
```

### 2. Anemic Domain Model
```java
// Avoid: Entities with only getters/setters
public class User {
    private String email;
    // Only getters and setters
}

// Better: Rich domain model
public class User {
    private String email;
    
    public void changeEmail(String newEmail) {
        validateEmail(newEmail);
        this.email = newEmail;
    }
    
    private void validateEmail(String email) {
        // Validation logic
    }
}
```

### 3. Overuse of @Autowired
```java
// Avoid: Field injection everywhere
@Service
public class UserService {
    @Autowired private UserRepository userRepository;
    @Autowired private EmailService emailService;
    @Autowired private ValidationService validationService;
}

// Better: Constructor injection
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final ValidationService validationService;
}
```

## Summary

1. **Structure your project logically** with clear separation of concerns
2. **Use constructor injection** over field injection
3. **Implement proper error handling** with global exception handlers
4. **Use DTOs** for API boundaries to avoid exposing internal models
5. **Follow RESTful conventions** for API design
6. **Implement comprehensive testing** following the test pyramid
7. **Optimize database queries** and use appropriate caching
8. **Monitor your application** with metrics and health checks
9. **Document your APIs** with OpenAPI/Swagger
10. **Avoid common anti-patterns** that lead to maintainability issues