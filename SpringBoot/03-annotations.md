# Spring Boot Annotations

## Core Annotations

### @SpringBootApplication
**Purpose**: Main annotation that combines three annotations
**What it does**: 
- Enables auto-configuration
- Enables component scanning
- Marks as configuration class

```java
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

**Equivalent to**:
```java
@Configuration
@EnableAutoConfiguration
@ComponentScan
public class Application {
    // ...
}
```

## Component Annotations

### @Component
**Purpose**: Generic stereotype annotation for any Spring-managed component
**What it does**: Marks class as a Spring bean for dependency injection

```java
@Component
public class EmailService {
    public void sendEmail(String message) {
        // Email sending logic
    }
}
```

### @Service
**Purpose**: Specialization of @Component for service layer
**What it does**: Indicates that class holds business logic

```java
@Service
public class UserService {
    public User findById(Long id) {
        // Business logic
        return user;
    }
}
```

### @Repository
**Purpose**: Specialization of @Component for data access layer
**What it does**: 
- Marks as data access component
- Enables automatic exception translation

```java
@Repository
public class UserRepository {
    public User save(User user) {
        // Database operations
        return user;
    }
}
```

### @Controller
**Purpose**: Marks class as Spring MVC controller
**What it does**: Handles web requests and returns views

```java
@Controller
public class HomeController {
    @RequestMapping("/")
    public String home() {
        return "index"; // Returns view name
    }
}
```

### @RestController
**Purpose**: Combination of @Controller and @ResponseBody
**What it does**: 
- Handles web requests
- Returns data directly (JSON/XML)
- No view resolution

```java
@RestController
public class ApiController {
    @GetMapping("/users")
    public List<User> getUsers() {
        return userService.findAll(); // Returns JSON
    }
}
```

## Request Mapping Annotations

### @RequestMapping
**Purpose**: Maps HTTP requests to handler methods
**What it does**: Defines URL patterns and HTTP methods

```java
@RequestMapping(value = "/users", method = RequestMethod.GET)
public List<User> getUsers() {
    return users;
}

// With multiple methods
@RequestMapping(value = "/users", method = {RequestMethod.GET, RequestMethod.POST})
public ResponseEntity<?> handleUsers() {
    // Handle both GET and POST
}
```

### @GetMapping
**Purpose**: Shortcut for @RequestMapping with GET method
**What it does**: Maps GET requests to handler methods

```java
@GetMapping("/users")
public List<User> getUsers() {
    return users;
}

@GetMapping("/users/{id}")
public User getUser(@PathVariable Long id) {
    return userService.findById(id);
}
```

### @PostMapping
**Purpose**: Shortcut for @RequestMapping with POST method
**What it does**: Maps POST requests to handler methods

```java
@PostMapping("/users")
public User createUser(@RequestBody User user) {
    return userService.save(user);
}
```

### @PutMapping
**Purpose**: Shortcut for @RequestMapping with PUT method
**What it does**: Maps PUT requests for updates

```java
@PutMapping("/users/{id}")
public User updateUser(@PathVariable Long id, @RequestBody User user) {
    return userService.update(id, user);
}
```

### @DeleteMapping
**Purpose**: Shortcut for @RequestMapping with DELETE method
**What it does**: Maps DELETE requests

```java
@DeleteMapping("/users/{id}")
public void deleteUser(@PathVariable Long id) {
    userService.delete(id);
}
```

## Parameter Annotations

### @PathVariable
**Purpose**: Extracts values from URI path
**What it does**: Binds URI template variables to method parameters

```java
@GetMapping("/users/{id}")
public User getUser(@PathVariable Long id) {
    return userService.findById(id);
}

@GetMapping("/users/{id}/posts/{postId}")
public Post getPost(@PathVariable Long id, @PathVariable Long postId) {
    return postService.findByUserAndId(id, postId);
}
```

### @RequestParam
**Purpose**: Extracts query parameters
**What it does**: Binds request parameters to method parameters

```java
@GetMapping("/users")
public List<User> getUsers(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "10") int size,
    @RequestParam(required = false) String name) {
    return userService.findUsers(page, size, name);
}
```

### @RequestBody
**Purpose**: Binds HTTP request body to method parameter
**What it does**: Deserializes request body to Java object

```java
@PostMapping("/users")
public User createUser(@RequestBody User user) {
    return userService.save(user);
}
```

### @RequestHeader
**Purpose**: Extracts HTTP header values
**What it does**: Binds header values to method parameters

```java
@GetMapping("/users")
public List<User> getUsers(@RequestHeader("Authorization") String token) {
    // Validate token and return users
    return users;
}
```

## Dependency Injection Annotations

### @Autowired
**Purpose**: Automatic dependency injection
**What it does**: Injects dependencies by type

```java
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
    
    // Constructor injection (recommended)
    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}
```

### @Qualifier
**Purpose**: Specifies which bean to inject when multiple candidates exist
**What it does**: Resolves ambiguity in dependency injection

```java
@Service
public class NotificationService {
    @Autowired
    @Qualifier("emailService")
    private MessageService messageService;
}

@Service("emailService")
public class EmailService implements MessageService {
    // Implementation
}

@Service("smsService")
public class SmsService implements MessageService {
    // Implementation
}
```

### @Primary
**Purpose**: Indicates primary bean when multiple candidates exist
**What it does**: Makes this bean the default choice for injection

```java
@Service
@Primary
public class EmailService implements MessageService {
    // This will be injected by default
}
```

## Configuration Annotations

### @Configuration
**Purpose**: Indicates class contains bean definitions
**What it does**: Marks class as source of bean definitions

```java
@Configuration
public class AppConfig {
    @Bean
    public DataSource dataSource() {
        return new HikariDataSource();
    }
}
```

### @Bean
**Purpose**: Indicates method produces a bean
**What it does**: Registers method return value as Spring bean

```java
@Configuration
public class DatabaseConfig {
    @Bean
    public DataSource dataSource() {
        HikariDataSource dataSource = new HikariDataSource();
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/mydb");
        return dataSource;
    }
}
```

### @Value
**Purpose**: Injects values from properties files
**What it does**: Binds property values to fields/parameters

```java
@Service
public class EmailService {
    @Value("${app.email.from}")
    private String fromEmail;
    
    @Value("${app.email.timeout:5000}")
    private int timeout; // Default value 5000
}
```

### @ConfigurationProperties
**Purpose**: Binds properties to Java objects
**What it does**: Maps property prefixes to object fields

```java
@ConfigurationProperties(prefix = "app.database")
@Component
public class DatabaseProperties {
    private String url;
    private String username;
    private String password;
    private int maxConnections;
    
    // Getters and setters
}
```

## Validation Annotations

### @Valid
**Purpose**: Triggers validation on method parameters/return values
**What it does**: Validates object using Bean Validation

```java
@PostMapping("/users")
public User createUser(@Valid @RequestBody User user) {
    return userService.save(user);
}
```

### @NotNull, @NotEmpty, @NotBlank
**Purpose**: Validation constraints
**What they do**: Validate field values

```java
public class User {
    @NotNull(message = "Name cannot be null")
    @NotBlank(message = "Name cannot be blank")
    private String name;
    
    @Email(message = "Invalid email format")
    private String email;
    
    @Min(value = 18, message = "Age must be at least 18")
    private int age;
}
```

## Conditional Annotations

### @ConditionalOnProperty
**Purpose**: Conditional bean creation based on properties
**What it does**: Creates bean only if property condition is met

```java
@Service
@ConditionalOnProperty(name = "feature.email.enabled", havingValue = "true")
public class EmailService {
    // Only created if feature.email.enabled=true
}
```

### @ConditionalOnClass
**Purpose**: Conditional bean creation based on class presence
**What it does**: Creates bean only if specified class is on classpath

```java
@Configuration
@ConditionalOnClass(DataSource.class)
public class DatabaseConfig {
    // Only if DataSource class is available
}
```

## Testing Annotations

### @SpringBootTest
**Purpose**: Integration testing annotation
**What it does**: Loads complete Spring application context

```java
@SpringBootTest
class UserServiceTest {
    @Autowired
    private UserService userService;
    
    @Test
    void testFindUser() {
        // Test with full context
    }
}
```

### @WebMvcTest
**Purpose**: Testing web layer only
**What it does**: Loads only web-related components

```java
@WebMvcTest(UserController.class)
class UserControllerTest {
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
}
```

### @DataJpaTest
**Purpose**: Testing JPA repositories
**What it does**: Configures in-memory database and JPA components

```java
@DataJpaTest
class UserRepositoryTest {
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
}
```