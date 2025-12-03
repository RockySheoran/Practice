# Spring Boot Database & JPA

## What is JPA?

JPA (Java Persistence API) is a specification for managing relational data in Java applications. Spring Data JPA provides repository abstraction on top of JPA.

## Dependencies

```xml
<dependencies>
    <!-- Spring Data JPA -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    
    <!-- H2 Database (for development) -->
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>runtime</scope>
    </dependency>
    
    <!-- MySQL Driver -->
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <scope>runtime</scope>
    </dependency>
</dependencies>
```

## Database Configuration

### application.properties

```properties
# H2 Database (In-memory for development)
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=password
spring.h2.console.enabled=true

# MySQL Database
spring.datasource.url=jdbc:mysql://localhost:3306/mydb
spring.datasource.username=root
spring.datasource.password=password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
```

## Entity Classes

### @Entity Annotation
**Purpose**: Marks class as JPA entity
**What it does**: Maps class to database table

### Basic Entity

```java
@Entity
@Table(name = "users")
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "full_name", nullable = false, length = 100)
    private String name;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private Integer age;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    // Constructors
    public User() {}
    
    public User(String name, String email, Integer age) {
        this.name = name;
        this.email = email;
        this.age = age;
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
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
```

## JPA Annotations Explained

### @Id
**Purpose**: Marks field as primary key
**What it does**: Identifies the primary key of entity

### @GeneratedValue
**Purpose**: Specifies primary key generation strategy
**What it does**: Auto-generates primary key values

```java
@Id
@GeneratedValue(strategy = GenerationType.IDENTITY) // Auto-increment
private Long id;

@Id
@GeneratedValue(strategy = GenerationType.UUID)
private String id;
```

### @Column
**Purpose**: Maps field to database column
**What it does**: Customizes column properties

```java
@Column(name = "full_name", nullable = false, length = 100, unique = true)
private String name;
```

### @Table
**Purpose**: Specifies table details
**What it does**: Customizes table name and properties

```java
@Entity
@Table(name = "app_users", schema = "public")
public class User {
    // ...
}
```

### @Temporal
**Purpose**: Maps date/time fields
**What it does**: Specifies temporal type for date fields

```java
@Temporal(TemporalType.DATE)
private Date birthDate;

@Temporal(TemporalType.TIMESTAMP)
private Date createdAt;
```

### @Enumerated
**Purpose**: Maps enum fields
**What it does**: Specifies how enum should be persisted

```java
public enum Status {
    ACTIVE, INACTIVE, PENDING
}

@Enumerated(EnumType.STRING) // Stores as string
private Status status;

@Enumerated(EnumType.ORDINAL) // Stores as number
private Status status;
```

## Repository Layer

### @Repository Annotation
**Purpose**: Marks class as data access component
**What it does**: Enables exception translation and component scanning

### JpaRepository Interface

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // Custom query methods
    List<User> findByName(String name);
    List<User> findByEmail(String email);
    List<User> findByAgeGreaterThan(Integer age);
    List<User> findByNameContaining(String name);
    List<User> findByNameAndEmail(String name, String email);
    
    // Custom queries with @Query
    @Query("SELECT u FROM User u WHERE u.age BETWEEN :minAge AND :maxAge")
    List<User> findUsersByAgeRange(@Param("minAge") Integer minAge, @Param("maxAge") Integer maxAge);
    
    @Query(value = "SELECT * FROM users WHERE email LIKE %:domain%", nativeQuery = true)
    List<User> findUsersByEmailDomain(@Param("domain") String domain);
    
    // Modifying queries
    @Modifying
    @Query("UPDATE User u SET u.name = :name WHERE u.id = :id")
    int updateUserName(@Param("id") Long id, @Param("name") String name);
    
    @Modifying
    @Query("DELETE FROM User u WHERE u.age < :age")
    int deleteUsersByAge(@Param("age") Integer age);
}
```

## Service Layer with Repository

```java
@Service
@Transactional
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    public List<User> findAll() {
        return userRepository.findAll();
    }
    
    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }
    
    public User save(User user) {
        return userRepository.save(user);
    }
    
    public User update(Long id, User userDetails) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found"));
        
        user.setName(userDetails.getName());
        user.setEmail(userDetails.getEmail());
        user.setAge(userDetails.getAge());
        
        return userRepository.save(user);
    }
    
    public void deleteById(Long id) {
        userRepository.deleteById(id);
    }
    
    public List<User> findByName(String name) {
        return userRepository.findByName(name);
    }
    
    public List<User> findUsersByAgeRange(Integer minAge, Integer maxAge) {
        return userRepository.findUsersByAgeRange(minAge, maxAge);
    }
}
```

## Relationships

### One-to-Many Relationship

```java
// User Entity (One side)
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Post> posts = new ArrayList<>();
    
    // Constructors, getters, setters
}

// Post Entity (Many side)
@Entity
public class Post {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String title;
    private String content;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
    
    // Constructors, getters, setters
}
```

### Many-to-Many Relationship

```java
// User Entity
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @ManyToMany
    @JoinTable(
        name = "user_roles",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles = new HashSet<>();
    
    // Constructors, getters, setters
}

// Role Entity
@Entity
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @ManyToMany(mappedBy = "roles")
    private Set<User> users = new HashSet<>();
    
    // Constructors, getters, setters
}
```

## Transaction Management

### @Transactional Annotation
**Purpose**: Manages database transactions
**What it does**: Ensures data consistency and rollback on errors

```java
@Service
@Transactional
public class UserService {
    
    @Transactional(readOnly = true)
    public List<User> findAll() {
        return userRepository.findAll();
    }
    
    @Transactional
    public User createUserWithPosts(User user, List<Post> posts) {
        User savedUser = userRepository.save(user);
        
        for (Post post : posts) {
            post.setUser(savedUser);
            postRepository.save(post);
        }
        
        return savedUser;
    }
    
    @Transactional(rollbackFor = Exception.class)
    public void transferData() {
        // If any exception occurs, transaction will rollback
        userRepository.save(user1);
        userRepository.save(user2);
    }
}
```

## Pagination and Sorting

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Page<User> findByNameContaining(String name, Pageable pageable);
    
    List<User> findByAgeGreaterThan(Integer age, Sort sort);
}

@Service
public class UserService {
    
    public Page<User> findUsers(int page, int size, String sortBy) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortBy));
        return userRepository.findAll(pageable);
    }
    
    public Page<User> searchUsers(String name, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return userRepository.findByNameContaining(name, pageable);
    }
}
```

## Controller with Database

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping
    public ResponseEntity<Page<User>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy) {
        
        Page<User> users = userService.findUsers(page, size, sortBy);
        return ResponseEntity.ok(users);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        Optional<User> user = userService.findById(id);
        return user.map(ResponseEntity::ok)
                  .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public ResponseEntity<User> createUser(@Valid @RequestBody User user) {
        User savedUser = userService.save(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedUser);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @Valid @RequestBody User user) {
        try {
            User updatedUser = userService.update(id, user);
            return ResponseEntity.ok(updatedUser);
        } catch (UserNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
```

## Database Initialization

### data.sql (Sample Data)
```sql
INSERT INTO users (name, email, age) VALUES ('John Doe', 'john@email.com', 25);
INSERT INTO users (name, email, age) VALUES ('Jane Smith', 'jane@email.com', 30);
INSERT INTO users (name, email, age) VALUES ('Bob Johnson', 'bob@email.com', 35);
```

### schema.sql (Custom Schema)
```sql
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    age INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Testing with Database

```java
@DataJpaTest
class UserRepositoryTest {
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void shouldFindUserByEmail() {
        // Given
        User user = new User("John", "john@email.com", 25);
        entityManager.persistAndFlush(user);
        
        // When
        List<User> found = userRepository.findByEmail("john@email.com");
        
        // Then
        assertThat(found).hasSize(1);
        assertThat(found.get(0).getName()).isEqualTo("John");
    }
    
    @Test
    void shouldFindUsersByAgeRange() {
        // Given
        entityManager.persistAndFlush(new User("John", "john@email.com", 25));
        entityManager.persistAndFlush(new User("Jane", "jane@email.com", 30));
        entityManager.persistAndFlush(new User("Bob", "bob@email.com", 35));
        
        // When
        List<User> found = userRepository.findUsersByAgeRange(25, 30);
        
        // Then
        assertThat(found).hasSize(2);
    }
}
```

## Best Practices

1. **Use appropriate fetch types** (LAZY vs EAGER)
2. **Implement proper transaction boundaries**
3. **Use pagination for large datasets**
4. **Create proper indexes for query performance**
5. **Use connection pooling**
6. **Handle database exceptions properly**
7. **Use DTOs to avoid exposing entities**
8. **Implement proper validation**
9. **Use database migrations (Flyway/Liquibase)**
10. **Monitor database performance**