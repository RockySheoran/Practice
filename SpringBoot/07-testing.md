# Spring Boot Testing

## Testing Overview

Spring Boot provides excellent testing support with various annotations and utilities to test different layers of your application.

## Testing Dependencies

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

This includes:
- JUnit 5
- Mockito
- AssertJ
- Hamcrest
- Spring Test & Spring Boot Test

## Testing Annotations

### @SpringBootTest
**Purpose**: Integration testing annotation
**What it does**: Loads complete Spring application context

```java
@SpringBootTest
class ApplicationIntegrationTest {
    
    @Autowired
    private UserService userService;
    
    @Test
    void contextLoads() {
        assertThat(userService).isNotNull();
    }
}
```

### @WebMvcTest
**Purpose**: Testing web layer only
**What it does**: Loads only web-related components (Controllers, Filters, etc.)

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
                .andExpect(jsonPath("$[0].name", is("John")))
                .andExpect(jsonPath("$[1].name", is("Jane")));
    }
}
```

### @DataJpaTest
**Purpose**: Testing JPA repositories
**What it does**: Configures in-memory database and JPA components only

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
        Optional<User> found = userRepository.findByEmail("john@email.com");
        
        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getName()).isEqualTo("John");
    }
    
    @Test
    void shouldFindUsersByAgeGreaterThan() {
        // Given
        entityManager.persistAndFlush(new User("John", "john@email.com", 25));
        entityManager.persistAndFlush(new User("Jane", "jane@email.com", 30));
        entityManager.persistAndFlush(new User("Bob", "bob@email.com", 20));
        
        // When
        List<User> users = userRepository.findByAgeGreaterThan(22);
        
        // Then
        assertThat(users).hasSize(2);
        assertThat(users).extracting(User::getName).containsExactlyInAnyOrder("John", "Jane");
    }
}
```

### @JsonTest
**Purpose**: Testing JSON serialization/deserialization
**What it does**: Loads JSON-related components

```java
@JsonTest
class UserJsonTest {
    
    @Autowired
    private JacksonTester<User> json;
    
    @Test
    void shouldSerializeUser() throws Exception {
        User user = new User("John", "john@email.com", 25);
        user.setId(1L);
        
        assertThat(json.write(user)).isEqualToJson("user.json");
        assertThat(json.write(user)).hasJsonPathStringValue("@.name");
        assertThat(json.write(user)).extractingJsonPathStringValue("@.name").isEqualTo("John");
    }
    
    @Test
    void shouldDeserializeUser() throws Exception {
        String content = "{\"id\":1,\"name\":\"John\",\"email\":\"john@email.com\",\"age\":25}";
        
        assertThat(json.parse(content)).usingRecursiveComparison()
                .isEqualTo(new User("John", "john@email.com", 25));
    }
}
```

## Unit Testing

### Service Layer Testing

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void shouldFindAllUsers() {
        // Given
        List<User> users = Arrays.asList(
            new User("John", "john@email.com", 25),
            new User("Jane", "jane@email.com", 30)
        );
        when(userRepository.findAll()).thenReturn(users);
        
        // When
        List<User> result = userService.findAll();
        
        // Then
        assertThat(result).hasSize(2);
        assertThat(result).extracting(User::getName).containsExactly("John", "Jane");
    }
    
    @Test
    void shouldFindUserById() {
        // Given
        User user = new User("John", "john@email.com", 25);
        user.setId(1L);
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        
        // When
        Optional<User> result = userService.findById(1L);
        
        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getName()).isEqualTo("John");
    }
    
    @Test
    void shouldThrowExceptionWhenUserNotFound() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.empty());
        
        // When & Then
        assertThatThrownBy(() -> userService.findById(1L))
                .isInstanceOf(UserNotFoundException.class)
                .hasMessage("User not found with id: 1");
    }
    
    @Test
    void shouldSaveUser() {
        // Given
        User user = new User("John", "john@email.com", 25);
        User savedUser = new User("John", "john@email.com", 25);
        savedUser.setId(1L);
        
        when(userRepository.save(user)).thenReturn(savedUser);
        
        // When
        User result = userService.save(user);
        
        // Then
        assertThat(result.getId()).isEqualTo(1L);
        assertThat(result.getName()).isEqualTo("John");
        verify(userRepository).save(user);
    }
}
```

## Integration Testing

### Full Integration Test

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(locations = "classpath:application-test.properties")
class UserIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private UserRepository userRepository;
    
    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }
    
    @Test
    void shouldCreateAndRetrieveUser() {
        // Given
        User user = new User("John", "john@email.com", 25);
        
        // When - Create user
        ResponseEntity<User> createResponse = restTemplate.postForEntity("/api/users", user, User.class);
        
        // Then - Verify creation
        assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(createResponse.getBody().getId()).isNotNull();
        
        Long userId = createResponse.getBody().getId();
        
        // When - Retrieve user
        ResponseEntity<User> getResponse = restTemplate.getForEntity("/api/users/" + userId, User.class);
        
        // Then - Verify retrieval
        assertThat(getResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(getResponse.getBody().getName()).isEqualTo("John");
        assertThat(getResponse.getBody().getEmail()).isEqualTo("john@email.com");
    }
    
    @Test
    void shouldUpdateUser() {
        // Given
        User user = userRepository.save(new User("John", "john@email.com", 25));
        User updatedUser = new User("John Doe", "johndoe@email.com", 26);
        
        // When
        restTemplate.put("/api/users/" + user.getId(), updatedUser);
        
        // Then
        User result = userRepository.findById(user.getId()).orElse(null);
        assertThat(result).isNotNull();
        assertThat(result.getName()).isEqualTo("John Doe");
        assertThat(result.getEmail()).isEqualTo("johndoe@email.com");
        assertThat(result.getAge()).isEqualTo(26);
    }
    
    @Test
    void shouldDeleteUser() {
        // Given
        User user = userRepository.save(new User("John", "john@email.com", 25));
        
        // When
        restTemplate.delete("/api/users/" + user.getId());
        
        // Then
        Optional<User> result = userRepository.findById(user.getId());
        assertThat(result).isEmpty();
    }
}
```

## Testing with Security

### Security Test Configuration

```java
@TestConfiguration
public class TestSecurityConfig {
    
    @Bean
    @Primary
    public UserDetailsService userDetailsService() {
        User user = User.builder()
                .username("testuser")
                .password("{noop}password")
                .roles("USER")
                .build();
        
        User admin = User.builder()
                .username("admin")
                .password("{noop}password")
                .roles("ADMIN")
                .build();
        
        return new InMemoryUserDetailsManager(user, admin);
    }
}
```

### Testing Secured Endpoints

```java
@WebMvcTest(UserController.class)
@Import(TestSecurityConfig.class)
class SecuredUserControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    @WithMockUser(roles = "ADMIN")
    void shouldAllowAdminToGetAllUsers() throws Exception {
        List<User> users = Arrays.asList(new User("John", "john@email.com", 25));
        when(userService.findAll()).thenReturn(users);
        
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));
    }
    
    @Test
    @WithMockUser(roles = "USER")
    void shouldForbidUserFromGettingAllUsers() throws Exception {
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isForbidden());
    }
    
    @Test
    void shouldRequireAuthenticationForProtectedEndpoint() throws Exception {
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isUnauthorized());
    }
}
```

## Testing with Profiles

### Test Properties

```properties
# application-test.properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true

logging.level.org.springframework.web=DEBUG
```

### Profile-specific Test

```java
@SpringBootTest
@ActiveProfiles("test")
class ProfileSpecificTest {
    
    @Value("${spring.datasource.url}")
    private String datasourceUrl;
    
    @Test
    void shouldUseTestProfile() {
        assertThat(datasourceUrl).contains("h2:mem:testdb");
    }
}
```

## Test Slices

### Custom Test Slice

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@BootstrapWith(SpringBootTestContextBootstrapper.class)
@ExtendWith(SpringExtension.class)
@OverrideAutoConfiguration(enabled = false)
@TypeExcludeFilters(ServiceLayerTestTypeExcludeFilter.class)
@AutoConfigureCache
@AutoConfigureTestDatabase
@AutoConfigureTestEntityManager
@ImportAutoConfiguration
public @interface ServiceLayerTest {
}

// Usage
@ServiceLayerTest
class UserServiceLayerTest {
    
    @Autowired
    private UserService userService;
    
    @MockBean
    private UserRepository userRepository;
    
    // Test methods
}
```

## Test Data Builders

### Test Data Builder Pattern

```java
public class UserTestDataBuilder {
    private String name = "Default Name";
    private String email = "default@email.com";
    private Integer age = 25;
    
    public static UserTestDataBuilder aUser() {
        return new UserTestDataBuilder();
    }
    
    public UserTestDataBuilder withName(String name) {
        this.name = name;
        return this;
    }
    
    public UserTestDataBuilder withEmail(String email) {
        this.email = email;
        return this;
    }
    
    public UserTestDataBuilder withAge(Integer age) {
        this.age = age;
        return this;
    }
    
    public User build() {
        return new User(name, email, age);
    }
}

// Usage in tests
@Test
void shouldCreateUser() {
    User user = aUser()
            .withName("John")
            .withEmail("john@email.com")
            .withAge(30)
            .build();
    
    assertThat(user.getName()).isEqualTo("John");
}
```

## Parameterized Tests

```java
class UserValidationTest {
    
    @ParameterizedTest
    @ValueSource(strings = {"", " ", "a", "ab"})
    void shouldRejectInvalidNames(String name) {
        User user = new User(name, "test@email.com", 25);
        
        Set<ConstraintViolation<User>> violations = validator.validate(user);
        
        assertThat(violations).isNotEmpty();
    }
    
    @ParameterizedTest
    @CsvSource({
        "John, john@email.com, 25, true",
        "'', john@email.com, 25, false",
        "John, invalid-email, 25, false",
        "John, john@email.com, 17, false"
    })
    void shouldValidateUser(String name, String email, int age, boolean expectedValid) {
        User user = new User(name, email, age);
        
        Set<ConstraintViolation<User>> violations = validator.validate(user);
        
        assertThat(violations.isEmpty()).isEqualTo(expectedValid);
    }
    
    @ParameterizedTest
    @MethodSource("provideUsersForValidation")
    void shouldValidateUsersFromMethodSource(User user, boolean expectedValid) {
        Set<ConstraintViolation<User>> violations = validator.validate(user);
        
        assertThat(violations.isEmpty()).isEqualTo(expectedValid);
    }
    
    private static Stream<Arguments> provideUsersForValidation() {
        return Stream.of(
            Arguments.of(new User("John", "john@email.com", 25), true),
            Arguments.of(new User("", "john@email.com", 25), false),
            Arguments.of(new User("John", "invalid", 25), false)
        );
    }
}
```

## Test Configuration

### Test Application Properties

```yaml
# application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    driver-class-name: org.h2.Driver
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
  h2:
    console:
      enabled: true

logging:
  level:
    org.springframework.web: DEBUG
    org.hibernate.SQL: DEBUG
```

## Best Practices

1. **Use appropriate test slices** - Don't load full context when not needed
2. **Mock external dependencies** - Use @MockBean for Spring beans
3. **Test behavior, not implementation** - Focus on what, not how
4. **Use meaningful test names** - Describe what is being tested
5. **Follow AAA pattern** - Arrange, Act, Assert
6. **Use test data builders** - Create reusable test data
7. **Test edge cases** - Include boundary conditions
8. **Keep tests independent** - Each test should be able to run in isolation
9. **Use proper assertions** - Use AssertJ for better readability
10. **Clean up test data** - Use @Transactional or manual cleanup

## Common Testing Patterns

### Testing Exceptions

```java
@Test
void shouldThrowExceptionWhenUserNotFound() {
    when(userRepository.findById(1L)).thenReturn(Optional.empty());
    
    assertThatThrownBy(() -> userService.findById(1L))
            .isInstanceOf(UserNotFoundException.class)
            .hasMessage("User not found with id: 1");
}
```

### Testing Async Operations

```java
@Test
void shouldProcessUserAsync() throws Exception {
    CompletableFuture<User> future = userService.processUserAsync(user);
    
    User result = future.get(5, TimeUnit.SECONDS);
    
    assertThat(result).isNotNull();
    assertThat(result.isProcessed()).isTrue();
}
```

### Testing with Time

```java
@Test
void shouldSetCreationTime() {
    LocalDateTime before = LocalDateTime.now();
    
    User user = userService.createUser(new User("John", "john@email.com", 25));
    
    LocalDateTime after = LocalDateTime.now();
    
    assertThat(user.getCreatedAt()).isBetween(before, after);
}
```