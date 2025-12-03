# Spring Boot Dependency Injection

## What is Dependency Injection?

Dependency Injection (DI) is a design pattern where objects receive their dependencies from external sources rather than creating them internally. Spring Boot's IoC (Inversion of Control) container manages object creation and dependency injection.

## Types of Dependency Injection

### 1. Constructor Injection (Recommended)

**Purpose**: Inject dependencies through constructor
**What it does**: Creates immutable dependencies, ensures required dependencies

```java
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final ValidationService validationService;
    
    // Constructor injection - recommended approach
    public UserService(UserRepository userRepository, 
                      EmailService emailService,
                      ValidationService validationService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
        this.validationService = validationService;
    }
    
    public User createUser(User user) {
        validationService.validate(user);
        User savedUser = userRepository.save(user);
        emailService.sendWelcomeEmail(savedUser.getEmail());
        return savedUser;
    }
}
```

**Benefits of Constructor Injection:**
- **Immutable dependencies** - Fields can be final
- **Required dependencies** - Constructor ensures all dependencies are provided
- **Fail fast** - Application won't start if dependencies are missing
- **Easy testing** - Simple to create test instances
- **Thread safe** - Immutable fields are thread safe

### 2. Setter Injection

**Purpose**: Inject dependencies through setter methods
**What it does**: Allows optional dependencies and reconfiguration

```java
@Service
public class UserService {
    
    private UserRepository userRepository;
    private EmailService emailService;
    private NotificationService notificationService; // Optional dependency
    
    @Autowired
    public void setUserRepository(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    @Autowired
    public void setEmailService(EmailService emailService) {
        this.emailService = emailService;
    }
    
    @Autowired(required = false) // Optional dependency
    public void setNotificationService(NotificationService notificationService) {
        this.notificationService = notificationService;
    }
    
    public User createUser(User user) {
        User savedUser = userRepository.save(user);
        emailService.sendWelcomeEmail(savedUser.getEmail());
        
        // Optional notification
        if (notificationService != null) {
            notificationService.sendNotification(savedUser);
        }
        
        return savedUser;
    }
}
```

### 3. Field Injection (Not Recommended)

**Purpose**: Inject dependencies directly into fields
**What it does**: Simple syntax but creates tight coupling

```java
@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository; // Avoid field injection
    
    @Autowired
    private EmailService emailService; // Hard to test
    
    public User createUser(User user) {
        User savedUser = userRepository.save(user);
        emailService.sendWelcomeEmail(savedUser.getEmail());
        return savedUser;
    }
}
```

**Why Field Injection is Not Recommended:**
- **Hard to test** - Cannot easily mock dependencies
- **Tight coupling** - Dependencies are hidden
- **Immutability issues** - Fields cannot be final
- **Circular dependencies** - Harder to detect

## @Autowired Annotation

**Purpose**: Marks dependencies for automatic injection
**What it does**: Tells Spring to inject matching beans

### Constructor Autowiring (Spring 4.3+)

```java
@Service
public class UserService {
    
    private final UserRepository userRepository;
    
    // @Autowired is optional for single constructor
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}
```

### Multiple Constructors

```java
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    // Primary constructor
    @Autowired
    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }
    
    // Alternative constructor for testing
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
        this.emailService = new MockEmailService();
    }
}
```

## Handling Multiple Implementations

### @Primary Annotation

**Purpose**: Marks primary bean when multiple candidates exist
**What it does**: Makes this bean the default choice for injection

```java
public interface MessageService {
    void sendMessage(String message);
}

@Service
@Primary // This will be injected by default
public class EmailService implements MessageService {
    @Override
    public void sendMessage(String message) {
        System.out.println("Sending email: " + message);
    }
}

@Service
public class SmsService implements MessageService {
    @Override
    public void sendMessage(String message) {
        System.out.println("Sending SMS: " + message);
    }
}

@Service
public class NotificationService {
    
    private final MessageService messageService;
    
    // EmailService will be injected due to @Primary
    public NotificationService(MessageService messageService) {
        this.messageService = messageService;
    }
}
```

### @Qualifier Annotation

**Purpose**: Specifies which bean to inject when multiple candidates exist
**What it does**: Resolves ambiguity by bean name or qualifier

```java
@Service
public class NotificationService {
    
    private final MessageService emailService;
    private final MessageService smsService;
    
    public NotificationService(@Qualifier("emailService") MessageService emailService,
                             @Qualifier("smsService") MessageService smsService) {
        this.emailService = emailService;
        this.smsService = smsService;
    }
    
    public void sendNotification(String message, String type) {
        if ("email".equals(type)) {
            emailService.sendMessage(message);
        } else if ("sms".equals(type)) {
            smsService.sendMessage(message);
        }
    }
}
```

### Custom Qualifiers

```java
@Qualifier
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD, ElementType.METHOD, ElementType.PARAMETER, ElementType.TYPE})
public @interface EmailNotification {
}

@Qualifier
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD, ElementType.METHOD, ElementType.PARAMETER, ElementType.TYPE})
public @interface SmsNotification {
}

@Service
@EmailNotification
public class EmailService implements MessageService {
    // Implementation
}

@Service
@SmsNotification
public class SmsService implements MessageService {
    // Implementation
}

@Service
public class NotificationService {
    
    private final MessageService emailService;
    private final MessageService smsService;
    
    public NotificationService(@EmailNotification MessageService emailService,
                             @SmsNotification MessageService smsService) {
        this.emailService = emailService;
        this.smsService = smsService;
    }
}
```

## Collection Injection

### Injecting All Implementations

```java
@Service
public class NotificationService {
    
    private final List<MessageService> messageServices;
    
    // Injects all MessageService implementations
    public NotificationService(List<MessageService> messageServices) {
        this.messageServices = messageServices;
    }
    
    public void sendToAll(String message) {
        messageServices.forEach(service -> service.sendMessage(message));
    }
}
```

### Map Injection with Bean Names

```java
@Service
public class NotificationService {
    
    private final Map<String, MessageService> messageServices;
    
    // Key = bean name, Value = bean instance
    public NotificationService(Map<String, MessageService> messageServices) {
        this.messageServices = messageServices;
    }
    
    public void sendMessage(String message, String serviceType) {
        MessageService service = messageServices.get(serviceType);
        if (service != null) {
            service.sendMessage(message);
        }
    }
}
```

## Optional Dependencies

### Using Optional

```java
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final Optional<CacheService> cacheService;
    
    public UserService(UserRepository userRepository, 
                      Optional<CacheService> cacheService) {
        this.userRepository = userRepository;
        this.cacheService = cacheService;
    }
    
    public User findById(Long id) {
        // Check cache if available
        if (cacheService.isPresent()) {
            User cachedUser = cacheService.get().getUser(id);
            if (cachedUser != null) {
                return cachedUser;
            }
        }
        
        User user = userRepository.findById(id).orElse(null);
        
        // Cache if service is available
        cacheService.ifPresent(cache -> cache.putUser(id, user));
        
        return user;
    }
}
```

### Using @Autowired(required = false)

```java
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private CacheService cacheService; // Can be null
    
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    @Autowired(required = false)
    public void setCacheService(CacheService cacheService) {
        this.cacheService = cacheService;
    }
    
    public User findById(Long id) {
        if (cacheService != null) {
            User cachedUser = cacheService.getUser(id);
            if (cachedUser != null) {
                return cachedUser;
            }
        }
        
        return userRepository.findById(id).orElse(null);
    }
}
```

## Lazy Initialization

### @Lazy Annotation

**Purpose**: Delays bean creation until first use
**What it does**: Improves startup time and handles circular dependencies

```java
@Service
@Lazy // Bean created only when first accessed
public class ExpensiveService {
    
    public ExpensiveService() {
        System.out.println("Creating expensive service...");
        // Expensive initialization
    }
    
    public void doSomething() {
        System.out.println("Doing something expensive...");
    }
}

@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final ExpensiveService expensiveService;
    
    public UserService(UserRepository userRepository, 
                      @Lazy ExpensiveService expensiveService) {
        this.userRepository = userRepository;
        this.expensiveService = expensiveService; // Proxy created, not actual bean
    }
    
    public void performExpensiveOperation() {
        expensiveService.doSomething(); // Bean created here
    }
}
```

## Circular Dependencies

### Problem Example

```java
@Service
public class ServiceA {
    
    private final ServiceB serviceB;
    
    public ServiceA(ServiceB serviceB) { // Circular dependency
        this.serviceB = serviceB;
    }
}

@Service
public class ServiceB {
    
    private final ServiceA serviceA;
    
    public ServiceB(ServiceA serviceA) { // Circular dependency
        this.serviceA = serviceA;
    }
}
```

### Solutions

#### 1. Using @Lazy

```java
@Service
public class ServiceA {
    
    private final ServiceB serviceB;
    
    public ServiceA(@Lazy ServiceB serviceB) { // Breaks circular dependency
        this.serviceB = serviceB;
    }
}

@Service
public class ServiceB {
    
    private final ServiceA serviceA;
    
    public ServiceB(ServiceA serviceA) {
        this.serviceA = serviceA;
    }
}
```

#### 2. Setter Injection

```java
@Service
public class ServiceA {
    
    private final ServiceB serviceB;
    private ServiceC serviceC;
    
    public ServiceA(ServiceB serviceB) {
        this.serviceB = serviceB;
    }
    
    @Autowired
    public void setServiceC(ServiceC serviceC) { // Setter injection
        this.serviceC = serviceC;
    }
}
```

#### 3. Redesign (Best Solution)

```java
// Extract common functionality to avoid circular dependency
@Service
public class CommonService {
    public void doCommonWork() {
        // Common functionality
    }
}

@Service
public class ServiceA {
    
    private final CommonService commonService;
    
    public ServiceA(CommonService commonService) {
        this.commonService = commonService;
    }
}

@Service
public class ServiceB {
    
    private final CommonService commonService;
    
    public ServiceB(CommonService commonService) {
        this.commonService = commonService;
    }
}
```

## Bean Scopes and Injection

### Singleton Scope (Default)

```java
@Service // Singleton by default
public class UserService {
    
    private final UserRepository userRepository;
    
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}
```

### Prototype Scope

```java
@Service
@Scope("prototype") // New instance for each injection
public class TaskProcessor {
    
    private String taskId;
    
    public void processTask(String taskId) {
        this.taskId = taskId;
        // Process task
    }
}

@Service
public class TaskService {
    
    private final ApplicationContext applicationContext;
    
    public TaskService(ApplicationContext applicationContext) {
        this.applicationContext = applicationContext;
    }
    
    public void processTasks(List<String> taskIds) {
        for (String taskId : taskIds) {
            // Get new instance for each task
            TaskProcessor processor = applicationContext.getBean(TaskProcessor.class);
            processor.processTask(taskId);
        }
    }
}
```

### Request Scope (Web Applications)

```java
@Component
@Scope(value = WebApplicationContext.SCOPE_REQUEST, proxyMode = ScopedProxyMode.TARGET_CLASS)
public class RequestScopedBean {
    
    private String requestId;
    
    public RequestScopedBean() {
        this.requestId = UUID.randomUUID().toString();
        System.out.println("Created request scoped bean: " + requestId);
    }
    
    public String getRequestId() {
        return requestId;
    }
}

@RestController
public class UserController {
    
    private final RequestScopedBean requestScopedBean;
    
    public UserController(RequestScopedBean requestScopedBean) {
        this.requestScopedBean = requestScopedBean; // Proxy injected
    }
    
    @GetMapping("/users")
    public String getUsers() {
        return "Request ID: " + requestScopedBean.getRequestId(); // New bean per request
    }
}
```

## Using Lombok for DI

### @RequiredArgsConstructor

```java
@Service
@RequiredArgsConstructor // Generates constructor for final fields
public class UserService {
    
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final ValidationService validationService;
    
    // Constructor automatically generated by Lombok
    
    public User createUser(User user) {
        validationService.validate(user);
        User savedUser = userRepository.save(user);
        emailService.sendWelcomeEmail(savedUser.getEmail());
        return savedUser;
    }
}
```

### @AllArgsConstructor

```java
@Service
@AllArgsConstructor // Generates constructor for all fields
public class UserService {
    
    private final UserRepository userRepository;
    private final EmailService emailService;
    private CacheService cacheService; // Non-final field also included
    
    public User findById(Long id) {
        if (cacheService != null) {
            User cached = cacheService.get(id);
            if (cached != null) return cached;
        }
        
        return userRepository.findById(id).orElse(null);
    }
}
```

## Testing with Dependency Injection

### Unit Testing

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private EmailService emailService;
    
    @InjectMocks
    private UserService userService; // Mocks injected automatically
    
    @Test
    void shouldCreateUser() {
        // Given
        User user = new User("John", "john@email.com", 25);
        User savedUser = new User("John", "john@email.com", 25);
        savedUser.setId(1L);
        
        when(userRepository.save(user)).thenReturn(savedUser);
        
        // When
        User result = userService.createUser(user);
        
        // Then
        assertThat(result.getId()).isEqualTo(1L);
        verify(emailService).sendWelcomeEmail("john@email.com");
    }
}
```

### Integration Testing

```java
@SpringBootTest
class UserServiceIntegrationTest {
    
    @Autowired
    private UserService userService; // Real dependencies injected
    
    @MockBean
    private EmailService emailService; // Mock specific beans
    
    @Test
    void shouldCreateUserWithRealDatabase() {
        // Given
        User user = new User("John", "john@email.com", 25);
        
        // When
        User result = userService.createUser(user);
        
        // Then
        assertThat(result.getId()).isNotNull();
        verify(emailService).sendWelcomeEmail("john@email.com");
    }
}
```

## Best Practices

1. **Use Constructor Injection** - Preferred over field and setter injection
2. **Make Dependencies Final** - Ensures immutability and thread safety
3. **Avoid Circular Dependencies** - Redesign architecture if needed
4. **Use @Primary and @Qualifier** - Handle multiple implementations clearly
5. **Minimize Dependencies** - Keep classes focused and cohesive
6. **Use Interfaces** - Program to interfaces, not implementations
7. **Handle Optional Dependencies** - Use Optional or required=false
8. **Avoid Field Injection** - Makes testing difficult
9. **Use Lombok** - Reduce boilerplate with @RequiredArgsConstructor
10. **Test Dependencies** - Mock dependencies in unit tests

## Common Pitfalls

1. **Too Many Dependencies** - Sign of poor design
2. **Circular Dependencies** - Indicates architectural problems
3. **Field Injection** - Makes testing and maintenance difficult
4. **Missing @Component** - Bean not registered in container
5. **Wrong Scope** - Using prototype when singleton is needed
6. **Null Dependencies** - Not handling optional dependencies properly
7. **Tight Coupling** - Not using interfaces for dependencies
8. **Late Initialization** - Dependencies not available when needed