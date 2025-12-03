# Spring Boot Layered Architecture

## What is Layered Architecture?

Layered Architecture is a software design pattern that organizes code into horizontal layers, where each layer has specific responsibilities and communicates only with adjacent layers.

## Spring Boot Layers

### 1. Presentation Layer (Controller Layer)
**Purpose**: Handles HTTP requests and responses
**Responsibilities**:
- Receive user requests
- Validate input data
- Call business logic
- Return responses

```java
@RestController
@RequestMapping("/api/users")
@Validated
public class UserController {
    
    private final UserService userService;
    private final UserMapper userMapper;
    
    public UserController(UserService userService, UserMapper userMapper) {
        this.userService = userService;
        this.userMapper = userMapper;
    }
    
    @GetMapping
    public ResponseEntity<List<UserResponseDto>> getAllUsers() {
        List<User> users = userService.findAll();
        List<UserResponseDto> userDtos = userMapper.toResponseDtoList(users);
        return ResponseEntity.ok(userDtos);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<UserResponseDto> getUserById(@PathVariable @Min(1) Long id) {
        User user = userService.findById(id);
        UserResponseDto userDto = userMapper.toResponseDto(user);
        return ResponseEntity.ok(userDto);
    }
    
    @PostMapping
    public ResponseEntity<UserResponseDto> createUser(@Valid @RequestBody UserCreateDto createDto) {
        User user = userMapper.toEntity(createDto);
        User savedUser = userService.save(user);
        UserResponseDto responseDto = userMapper.toResponseDto(savedUser);
        
        URI location = ServletUriComponentsBuilder
                .fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(savedUser.getId())
                .toUri();
                
        return ResponseEntity.created(location).body(responseDto);
    }
}
```

### 2. Business/Service Layer
**Purpose**: Contains business logic and rules
**Responsibilities**:
- Implement business rules
- Coordinate between different services
- Handle transactions
- Validate business constraints

```java
public interface UserService {
    List<User> findAll();
    User findById(Long id);
    User save(User user);
    User update(Long id, User user);
    void deleteById(Long id);
    List<User> findByDepartment(String department);
    boolean existsByEmail(String email);
}

@Service
@Transactional
public class UserServiceImpl implements UserService {
    
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final AuditService auditService;
    
    public UserServiceImpl(UserRepository userRepository, 
                          EmailService emailService,
                          AuditService auditService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
        this.auditService = auditService;
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<User> findAll() {
        return userRepository.findAll();
    }
    
    @Override
    @Transactional(readOnly = true)
    public User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
    }
    
    @Override
    public User save(User user) {
        // Business validation
        validateUser(user);
        
        // Check business rules
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new DuplicateEmailException("Email already exists: " + user.getEmail());
        }
        
        // Save user
        User savedUser = userRepository.save(user);
        
        // Business logic - send welcome email
        emailService.sendWelcomeEmail(savedUser.getEmail(), savedUser.getName());
        
        // Audit logging
        auditService.logUserCreation(savedUser.getId(), savedUser.getName());
        
        return savedUser;
    }
    
    @Override
    public User update(Long id, User user) {
        User existingUser = findById(id);
        
        // Business validation
        validateUser(user);
        
        // Check if email is being changed and if it's already taken
        if (!existingUser.getEmail().equals(user.getEmail()) && 
            userRepository.existsByEmail(user.getEmail())) {
            throw new DuplicateEmailException("Email already exists: " + user.getEmail());
        }
        
        // Update fields
        existingUser.setName(user.getName());
        existingUser.setEmail(user.getEmail());
        existingUser.setAge(user.getAge());
        existingUser.setDepartment(user.getDepartment());
        
        User updatedUser = userRepository.save(existingUser);
        
        // Audit logging
        auditService.logUserUpdate(updatedUser.getId(), updatedUser.getName());
        
        return updatedUser;
    }
    
    @Override
    public void deleteById(Long id) {
        User user = findById(id);
        
        // Business rule - check if user can be deleted
        if (user.hasActiveOrders()) {
            throw new UserDeletionException("Cannot delete user with active orders");
        }
        
        userRepository.deleteById(id);
        
        // Audit logging
        auditService.logUserDeletion(id, user.getName());
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<User> findByDepartment(String department) {
        return userRepository.findByDepartment(department);
    }
    
    @Override
    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }
    
    private void validateUser(User user) {
        if (user.getAge() != null && user.getAge() < 18) {
            throw new InvalidUserException("User must be at least 18 years old");
        }
        
        if (user.getName() != null && user.getName().trim().isEmpty()) {
            throw new InvalidUserException("User name cannot be empty");
        }
    }
}
```

### 3. Data Access Layer (Repository Layer)
**Purpose**: Handles data persistence and retrieval
**Responsibilities**:
- Database operations (CRUD)
- Query execution
- Data mapping
- Transaction management at data level

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // Derived query methods
    Optional<User> findByEmail(String email);
    List<User> findByDepartment(String department);
    List<User> findByAgeGreaterThan(Integer age);
    List<User> findByNameContainingIgnoreCase(String name);
    boolean existsByEmail(String email);
    
    // Custom queries
    @Query("SELECT u FROM User u WHERE u.createdAt BETWEEN :startDate AND :endDate")
    List<User> findUsersCreatedBetween(@Param("startDate") LocalDateTime startDate, 
                                      @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT u FROM User u LEFT JOIN FETCH u.orders WHERE u.id = :id")
    Optional<User> findByIdWithOrders(@Param("id") Long id);
    
    // Native query
    @Query(value = "SELECT * FROM users WHERE email LIKE %:domain%", nativeQuery = true)
    List<User> findUsersByEmailDomain(@Param("domain") String domain);
    
    // Modifying queries
    @Modifying
    @Query("UPDATE User u SET u.lastLoginAt = :loginTime WHERE u.id = :id")
    int updateLastLoginTime(@Param("id") Long id, @Param("loginTime") LocalDateTime loginTime);
    
    // Pagination and sorting
    Page<User> findByDepartment(String department, Pageable pageable);
    
    // Projections
    @Query("SELECT new com.example.dto.UserSummaryDto(u.id, u.name, u.email) FROM User u")
    List<UserSummaryDto> findUserSummaries();
}

// Custom Repository Implementation
@Repository
public class UserRepositoryCustomImpl implements UserRepositoryCustom {
    
    @PersistenceContext
    private EntityManager entityManager;
    
    @Override
    public List<User> findUsersWithComplexCriteria(UserSearchCriteria criteria) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<User> query = cb.createQuery(User.class);
        Root<User> user = query.from(User.class);
        
        List<Predicate> predicates = new ArrayList<>();
        
        if (criteria.getName() != null) {
            predicates.add(cb.like(cb.lower(user.get("name")), 
                                 "%" + criteria.getName().toLowerCase() + "%"));
        }
        
        if (criteria.getMinAge() != null) {
            predicates.add(cb.greaterThanOrEqualTo(user.get("age"), criteria.getMinAge()));
        }
        
        if (criteria.getMaxAge() != null) {
            predicates.add(cb.lessThanOrEqualTo(user.get("age"), criteria.getMaxAge()));
        }
        
        if (criteria.getDepartment() != null) {
            predicates.add(cb.equal(user.get("department"), criteria.getDepartment()));
        }
        
        query.where(predicates.toArray(new Predicate[0]));
        
        return entityManager.createQuery(query).getResultList();
    }
}
```

### 4. Domain/Model Layer
**Purpose**: Represents business entities and domain logic
**Responsibilities**:
- Define business entities
- Encapsulate business rules
- Maintain data integrity

```java
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_department", columnList = "department")
})
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String name;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(nullable = false)
    private Integer age;
    
    @Column(length = 50)
    private String department;
    
    @Column(name = "is_active")
    private Boolean active = true;
    
    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;
    
    // Relationships
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Order> orders = new ArrayList<>();
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manager_id")
    private User manager;
    
    @OneToMany(mappedBy = "manager", fetch = FetchType.LAZY)
    private List<User> subordinates = new ArrayList<>();
    
    // Constructors
    public User() {}
    
    public User(String name, String email, Integer age) {
        this.name = name;
        this.email = email;
        this.age = age;
    }
    
    // Business methods (Domain logic)
    public void activate() {
        this.active = true;
    }
    
    public void deactivate() {
        if (hasActiveOrders()) {
            throw new IllegalStateException("Cannot deactivate user with active orders");
        }
        this.active = false;
    }
    
    public boolean hasActiveOrders() {
        return orders.stream().anyMatch(Order::isActive);
    }
    
    public void updateLastLogin() {
        this.lastLoginAt = LocalDateTime.now();
    }
    
    public boolean isManager() {
        return !subordinates.isEmpty();
    }
    
    public void assignManager(User manager) {
        if (manager.equals(this)) {
            throw new IllegalArgumentException("User cannot be their own manager");
        }
        this.manager = manager;
    }
    
    public int getTotalOrderValue() {
        return orders.stream()
                .filter(Order::isActive)
                .mapToInt(Order::getValue)
                .sum();
    }
    
    // Validation methods
    public void validateForCreation() {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Name is required");
        }
        if (email == null || !isValidEmail(email)) {
            throw new IllegalArgumentException("Valid email is required");
        }
        if (age == null || age < 18) {
            throw new IllegalArgumentException("Age must be at least 18");
        }
    }
    
    private boolean isValidEmail(String email) {
        return email.contains("@") && email.contains(".");
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
    
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    
    public List<Order> getOrders() { return orders; }
    public void setOrders(List<Order> orders) { this.orders = orders; }
    
    public User getManager() { return manager; }
    public void setManager(User manager) { this.manager = manager; }
    
    public List<User> getSubordinates() { return subordinates; }
    public void setSubordinates(List<User> subordinates) { this.subordinates = subordinates; }
    
    // equals and hashCode
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return Objects.equals(id, user.id);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
    
    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", age=" + age +
                ", department='" + department + '\'' +
                ", active=" + active +
                '}';
    }
}
```

## Data Transfer Objects (DTOs)

### Request DTOs

```java
// Create User DTO
public class UserCreateDto {
    
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Please provide a valid email")
    private String email;
    
    @NotNull(message = "Age is required")
    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 100, message = "Age must be less than 100")
    private Integer age;
    
    @Size(max = 50, message = "Department name cannot exceed 50 characters")
    private String department;
    
    // Constructors
    public UserCreateDto() {}
    
    public UserCreateDto(String name, String email, Integer age, String department) {
        this.name = name;
        this.email = email;
        this.age = age;
        this.department = department;
    }
    
    // Getters and Setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
}

// Update User DTO
public class UserUpdateDto {
    
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Please provide a valid email")
    private String email;
    
    @NotNull(message = "Age is required")
    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 100, message = "Age must be less than 100")
    private Integer age;
    
    @Size(max = 50, message = "Department name cannot exceed 50 characters")
    private String department;
    
    // Getters and Setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
}
```

### Response DTOs

```java
// User Response DTO
public class UserResponseDto {
    
    private Long id;
    private String name;
    private String email;
    private Integer age;
    private String department;
    private Boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime lastLoginAt;
    private String managerName;
    private int totalOrders;
    
    // Constructors
    public UserResponseDto() {}
    
    public UserResponseDto(Long id, String name, String email, Integer age, 
                          String department, Boolean active, LocalDateTime createdAt) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.age = age;
        this.department = department;
        this.active = active;
        this.createdAt = createdAt;
    }
    
    // Static factory method
    public static UserResponseDto from(User user) {
        UserResponseDto dto = new UserResponseDto();
        dto.setId(user.getId());
        dto.setName(user.getName());
        dto.setEmail(user.getEmail());
        dto.setAge(user.getAge());
        dto.setDepartment(user.getDepartment());
        dto.setActive(user.getActive());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setLastLoginAt(user.getLastLoginAt());
        dto.setManagerName(user.getManager() != null ? user.getManager().getName() : null);
        dto.setTotalOrders(user.getOrders().size());
        return dto;
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
    
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }
    
    public String getManagerName() { return managerName; }
    public void setManagerName(String managerName) { this.managerName = managerName; }
    
    public int getTotalOrders() { return totalOrders; }
    public void setTotalOrders(int totalOrders) { this.totalOrders = totalOrders; }
}

// Summary DTO for lists
public class UserSummaryDto {
    
    private Long id;
    private String name;
    private String email;
    private String department;
    
    public UserSummaryDto(Long id, String name, String email, String department) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.department = department;
    }
    
    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
}
```

## Mapping Between Layers

### Using MapStruct

```java
@Mapper(componentModel = "spring")
public interface UserMapper {
    
    // Entity to Response DTO
    UserResponseDto toResponseDto(User user);
    
    // Entity list to Response DTO list
    List<UserResponseDto> toResponseDtoList(List<User> users);
    
    // Create DTO to Entity
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "active", constant = "true")
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "lastLoginAt", ignore = true)
    @Mapping(target = "orders", ignore = true)
    @Mapping(target = "manager", ignore = true)
    @Mapping(target = "subordinates", ignore = true)
    User toEntity(UserCreateDto createDto);
    
    // Update DTO to Entity
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "active", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "lastLoginAt", ignore = true)
    @Mapping(target = "orders", ignore = true)
    @Mapping(target = "manager", ignore = true)
    @Mapping(target = "subordinates", ignore = true)
    User toEntity(UserUpdateDto updateDto);
    
    // Custom mapping method
    @Mapping(target = "managerName", source = "manager.name")
    @Mapping(target = "totalOrders", expression = "java(user.getOrders().size())")
    UserResponseDto toDetailedResponseDto(User user);
}
```

## Cross-Cutting Concerns

### 1. Logging Service

```java
@Service
public class AuditService {
    
    private static final Logger logger = LoggerFactory.getLogger(AuditService.class);
    
    public void logUserCreation(Long userId, String userName) {
        logger.info("User created - ID: {}, Name: {}", userId, userName);
        // Save to audit table if needed
    }
    
    public void logUserUpdate(Long userId, String userName) {
        logger.info("User updated - ID: {}, Name: {}", userId, userName);
    }
    
    public void logUserDeletion(Long userId, String userName) {
        logger.info("User deleted - ID: {}, Name: {}", userId, userName);
    }
}
```

### 2. Email Service

```java
public interface EmailService {
    void sendWelcomeEmail(String email, String name);
    void sendPasswordResetEmail(String email, String resetToken);
}

@Service
public class EmailServiceImpl implements EmailService {
    
    private static final Logger logger = LoggerFactory.getLogger(EmailServiceImpl.class);
    
    @Override
    public void sendWelcomeEmail(String email, String name) {
        logger.info("Sending welcome email to: {}", email);
        // Email sending logic
        // Could use JavaMailSender, external email service, etc.
    }
    
    @Override
    public void sendPasswordResetEmail(String email, String resetToken) {
        logger.info("Sending password reset email to: {}", email);
        // Password reset email logic
    }
}
```

## Layer Communication Rules

### 1. Dependency Direction
```
Controller → Service → Repository → Database
     ↓         ↓          ↓
   DTOs    Business    Entities
           Logic
```

### 2. What Each Layer Can Access

**Controller Layer:**
- Can call Service layer
- Can use DTOs
- Cannot directly call Repository layer
- Cannot access Entities directly

**Service Layer:**
- Can call Repository layer
- Can call other Services
- Can use Entities
- Cannot access DTOs (should use Entities)

**Repository Layer:**
- Can access Database
- Can use Entities
- Cannot call Service layer
- Cannot access DTOs

### 3. Data Flow Example

```java
// 1. Controller receives DTO
@PostMapping
public ResponseEntity<UserResponseDto> createUser(@Valid @RequestBody UserCreateDto createDto) {
    
    // 2. Convert DTO to Entity
    User user = userMapper.toEntity(createDto);
    
    // 3. Call Service with Entity
    User savedUser = userService.save(user);
    
    // 4. Convert Entity back to DTO
    UserResponseDto responseDto = userMapper.toResponseDto(savedUser);
    
    // 5. Return DTO in Response
    return ResponseEntity.created(location).body(responseDto);
}

// Service works with Entities
@Service
public class UserServiceImpl implements UserService {
    
    @Override
    public User save(User user) {
        // Business logic with Entity
        validateUser(user);
        
        // Call Repository with Entity
        User savedUser = userRepository.save(user);
        
        // Return Entity
        return savedUser;
    }
}

// Repository works with Entities
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Methods work with Entity types
    Optional<User> findByEmail(String email);
}
```

## Benefits of Layered Architecture

1. **Separation of Concerns** - Each layer has specific responsibility
2. **Maintainability** - Easy to modify one layer without affecting others
3. **Testability** - Each layer can be tested independently
4. **Reusability** - Services can be reused by different controllers
5. **Scalability** - Layers can be scaled independently
6. **Security** - Clear boundaries for applying security measures
7. **Team Development** - Different teams can work on different layers
8. **Technology Independence** - Can change implementation of one layer

## Best Practices

1. **Keep Controllers Thin** - Move business logic to service layer
2. **Use DTOs** - Don't expose entities in API layer
3. **Single Responsibility** - Each layer should have one reason to change
4. **Dependency Injection** - Use constructor injection
5. **Transaction Management** - Handle transactions at service layer
6. **Error Handling** - Implement proper exception handling at each layer
7. **Validation** - Validate at appropriate layers (DTO validation, business validation)
8. **Logging** - Add appropriate logging at each layer
9. **Testing** - Write unit tests for each layer
10. **Documentation** - Document interfaces and business rules