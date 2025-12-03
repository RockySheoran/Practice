# Spring Boot REST API

## What is REST API?

REST (Representational State Transfer) is an architectural style for designing web services. It uses HTTP methods to perform operations on resources.

## HTTP Methods

- **GET** - Retrieve data
- **POST** - Create new resource
- **PUT** - Update existing resource
- **DELETE** - Remove resource
- **PATCH** - Partial update

## Creating REST Controller

### Basic REST Controller

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    // GET all users
    @GetMapping
    public List<User> getAllUsers() {
        return userService.findAll();
    }
    
    // GET user by ID
    @GetMapping("/{id}")
    public User getUserById(@PathVariable Long id) {
        return userService.findById(id);
    }
    
    // POST create new user
    @PostMapping
    public User createUser(@RequestBody User user) {
        return userService.save(user);
    }
    
    // PUT update user
    @PutMapping("/{id}")
    public User updateUser(@PathVariable Long id, @RequestBody User user) {
        return userService.update(id, user);
    }
    
    // DELETE user
    @DeleteMapping("/{id}")
    public void deleteUser(@PathVariable Long id) {
        userService.delete(id);
    }
}
```

## User Model

```java
public class User {
    private Long id;
    private String name;
    private String email;
    private int age;
    
    // Constructors
    public User() {}
    
    public User(String name, String email, int age) {
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
    
    public int getAge() { return age; }
    public void setAge(int age) { this.age = age; }
}
```

## Service Layer

```java
@Service
public class UserService {
    
    private List<User> users = new ArrayList<>();
    private Long nextId = 1L;
    
    public List<User> findAll() {
        return users;
    }
    
    public User findById(Long id) {
        return users.stream()
                .filter(user -> user.getId().equals(id))
                .findFirst()
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
    }
    
    public User save(User user) {
        user.setId(nextId++);
        users.add(user);
        return user;
    }
    
    public User update(Long id, User updatedUser) {
        User existingUser = findById(id);
        existingUser.setName(updatedUser.getName());
        existingUser.setEmail(updatedUser.getEmail());
        existingUser.setAge(updatedUser.getAge());
        return existingUser;
    }
    
    public void delete(Long id) {
        users.removeIf(user -> user.getId().equals(id));
    }
}
```

## Response Entity

### Using ResponseEntity for Better Control

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        try {
            User user = userService.findById(id);
            return ResponseEntity.ok(user);
        } catch (UserNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody User user) {
        User savedUser = userService.save(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedUser);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User user) {
        try {
            User updatedUser = userService.update(id, user);
            return ResponseEntity.ok(updatedUser);
        } catch (UserNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        try {
            userService.delete(id);
            return ResponseEntity.noContent().build();
        } catch (UserNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
```

## Request Parameters and Query Parameters

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    // Query parameters
    @GetMapping
    public List<User> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String name) {
        return userService.findUsers(page, size, name);
    }
    
    // Multiple path variables
    @GetMapping("/{userId}/posts/{postId}")
    public Post getUserPost(@PathVariable Long userId, @PathVariable Long postId) {
        return postService.findByUserAndId(userId, postId);
    }
    
    // Request headers
    @GetMapping("/profile")
    public User getUserProfile(@RequestHeader("Authorization") String token) {
        return userService.findByToken(token);
    }
}
```

## Exception Handling

### Custom Exception

```java
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(String message) {
        super(message);
    }
}
```

### Global Exception Handler

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleUserNotFound(UserNotFoundException e) {
        ErrorResponse error = new ErrorResponse("USER_NOT_FOUND", e.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception e) {
        ErrorResponse error = new ErrorResponse("INTERNAL_ERROR", "Something went wrong");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}
```

### Error Response Model

```java
public class ErrorResponse {
    private String code;
    private String message;
    private LocalDateTime timestamp;
    
    public ErrorResponse(String code, String message) {
        this.code = code;
        this.message = message;
        this.timestamp = LocalDateTime.now();
    }
    
    // Getters and setters
}
```

## Validation

### Adding Validation Dependencies

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

### Validated User Model

```java
public class User {
    private Long id;
    
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    private String name;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;
    
    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 100, message = "Age must be less than 100")
    private int age;
    
    // Constructors, getters, setters
}
```

### Controller with Validation

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @PostMapping
    public ResponseEntity<User> createUser(@Valid @RequestBody User user) {
        User savedUser = userService.save(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedUser);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @Valid @RequestBody User user) {
        User updatedUser = userService.update(id, user);
        return ResponseEntity.ok(updatedUser);
    }
}
```

### Validation Exception Handler

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationExceptions(
            MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        return ResponseEntity.badRequest().body(errors);
    }
}
```

## Content Negotiation

### Producing Different Content Types

```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    // Produces JSON by default
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public List<User> getUsersJson() {
        return userService.findAll();
    }
    
    // Produces XML
    @GetMapping(produces = MediaType.APPLICATION_XML_VALUE)
    public List<User> getUsersXml() {
        return userService.findAll();
    }
    
    // Consumes JSON
    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    public User createUser(@RequestBody User user) {
        return userService.save(user);
    }
}
```

## CORS Configuration

```java
@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "http://localhost:3000")
public class UserController {
    // Controller methods
}

// Or global CORS configuration
@Configuration
public class CorsConfig {
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("http://localhost:3000"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

## Testing REST API

### Test with MockMvc

```java
@WebMvcTest(UserController.class)
class UserControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void shouldGetAllUsers() throws Exception {
        List<User> users = Arrays.asList(
            new User("John", "john@email.com", 25),
            new User("Jane", "jane@email.com", 30)
        );
        
        when(userService.findAll()).thenReturn(users);
        
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].name", is("John")));
    }
    
    @Test
    void shouldCreateUser() throws Exception {
        User user = new User("John", "john@email.com", 25);
        user.setId(1L);
        
        when(userService.save(any(User.class))).thenReturn(user);
        
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\":\"John\",\"email\":\"john@email.com\",\"age\":25}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name", is("John")));
    }
}
```

## Best Practices

1. **Use proper HTTP status codes**
2. **Implement proper error handling**
3. **Add input validation**
4. **Use ResponseEntity for better control**
5. **Follow REST naming conventions**
6. **Implement pagination for large datasets**
7. **Add proper logging**
8. **Use DTOs for data transfer**
9. **Implement proper security**
10. **Write comprehensive tests**