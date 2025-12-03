# Spring Boot MVC Architecture

## What is MVC?

MVC (Model-View-Controller) is a design pattern that separates application logic into three interconnected components:

- **Model** - Represents data and business logic
- **View** - Handles the presentation layer (UI)
- **Controller** - Manages user input and coordinates between Model and View

## Spring MVC Architecture

### Flow Diagram
```
Client Request → DispatcherServlet → HandlerMapping → Controller → Service → Repository → Database
                      ↓                                    ↓         ↓          ↓
Client Response ← ViewResolver ← Model ← Controller ← Service ← Repository ← Database
```

### Components Explanation

#### 1. DispatcherServlet
**Purpose**: Front controller that handles all HTTP requests
**What it does**: Routes requests to appropriate controllers

```java
// Automatically configured in Spring Boot
// No need to configure manually like in traditional Spring MVC
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

#### 2. HandlerMapping
**Purpose**: Maps requests to handler methods
**What it does**: Determines which controller method should handle the request

```java
@Controller
@RequestMapping("/users")
public class UserController {
    
    // HandlerMapping maps GET /users/{id} to this method
    @GetMapping("/{id}")
    public String getUser(@PathVariable Long id, Model model) {
        User user = userService.findById(id);
        model.addAttribute("user", user);
        return "user-details"; // View name
    }
}
```

#### 3. Controller
**Purpose**: Handles HTTP requests and prepares response
**What it does**: Processes user input, calls business logic, prepares model data

```java
@Controller
@RequestMapping("/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    // Handle GET request
    @GetMapping
    public String listUsers(Model model) {
        List<User> users = userService.findAll();
        model.addAttribute("users", users);
        return "user-list"; // Returns view name
    }
    
    // Handle POST request
    @PostMapping
    public String createUser(@ModelAttribute User user, RedirectAttributes redirectAttributes) {
        User savedUser = userService.save(user);
        redirectAttributes.addFlashAttribute("message", "User created successfully");
        return "redirect:/users"; // Redirect to user list
    }
    
    // Handle form display
    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("user", new User());
        return "user-form";
    }
}
```

#### 4. Model
**Purpose**: Carries data between Controller and View
**What it does**: Holds data that will be displayed in the view

```java
@Controller
public class UserController {
    
    @GetMapping("/users/{id}")
    public String getUser(@PathVariable Long id, Model model) {
        User user = userService.findById(id);
        
        // Adding data to model
        model.addAttribute("user", user);
        model.addAttribute("pageTitle", "User Details");
        model.addAttribute("currentDate", LocalDate.now());
        
        return "user-details";
    }
    
    // Using ModelAndView
    @GetMapping("/users/{id}/edit")
    public ModelAndView editUser(@PathVariable Long id) {
        ModelAndView modelAndView = new ModelAndView("user-edit");
        modelAndView.addObject("user", userService.findById(id));
        modelAndView.addObject("departments", departmentService.findAll());
        return modelAndView;
    }
}
```

#### 5. View
**Purpose**: Renders the user interface
**What it does**: Displays data from model to user

**Thymeleaf Template Example:**
```html
<!-- user-details.html -->
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title th:text="${pageTitle}">User Details</title>
</head>
<body>
    <h1>User Information</h1>
    
    <div th:if="${user}">
        <p><strong>Name:</strong> <span th:text="${user.name}"></span></p>
        <p><strong>Email:</strong> <span th:text="${user.email}"></span></p>
        <p><strong>Age:</strong> <span th:text="${user.age}"></span></p>
    </div>
    
    <div th:unless="${user}">
        <p>User not found!</p>
    </div>
    
    <p>Current Date: <span th:text="${currentDate}"></span></p>
    
    <a th:href="@{/users}">Back to User List</a>
</body>
</html>
```

#### 6. ViewResolver
**Purpose**: Resolves view names to actual view implementations
**What it does**: Maps logical view names to physical view files

```properties
# application.properties
spring.mvc.view.prefix=/WEB-INF/views/
spring.mvc.view.suffix=.jsp

# For Thymeleaf (default in Spring Boot)
spring.thymeleaf.prefix=classpath:/templates/
spring.thymeleaf.suffix=.html
```

## MVC vs REST API

### Traditional MVC (Returns Views)

```java
@Controller
@RequestMapping("/web/users")
public class UserWebController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping
    public String listUsers(Model model) {
        model.addAttribute("users", userService.findAll());
        return "user-list"; // Returns HTML page
    }
    
    @GetMapping("/{id}")
    public String viewUser(@PathVariable Long id, Model model) {
        model.addAttribute("user", userService.findById(id));
        return "user-details"; // Returns HTML page
    }
    
    @PostMapping
    public String createUser(@ModelAttribute User user, RedirectAttributes redirectAttributes) {
        userService.save(user);
        redirectAttributes.addFlashAttribute("message", "User created!");
        return "redirect:/web/users";
    }
}
```

### REST API (Returns Data)

```java
@RestController
@RequestMapping("/api/users")
public class UserApiController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping
    public List<User> listUsers() {
        return userService.findAll(); // Returns JSON data
    }
    
    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.findById(id); // Returns JSON data
    }
    
    @PostMapping
    public User createUser(@RequestBody User user) {
        return userService.save(user); // Returns JSON data
    }
}
```

## Form Handling in MVC

### Form Display and Processing

```java
@Controller
@RequestMapping("/users")
public class UserFormController {
    
    @Autowired
    private UserService userService;
    
    // Display form
    @GetMapping("/new")
    public String showCreateForm(Model model) {
        model.addAttribute("user", new User());
        model.addAttribute("departments", departmentService.findAll());
        return "user-form";
    }
    
    // Process form submission
    @PostMapping
    public String processForm(@Valid @ModelAttribute("user") User user, 
                             BindingResult bindingResult, 
                             Model model,
                             RedirectAttributes redirectAttributes) {
        
        if (bindingResult.hasErrors()) {
            model.addAttribute("departments", departmentService.findAll());
            return "user-form"; // Return to form with errors
        }
        
        userService.save(user);
        redirectAttributes.addFlashAttribute("successMessage", "User created successfully!");
        return "redirect:/users";
    }
    
    // Edit form
    @GetMapping("/{id}/edit")
    public String showEditForm(@PathVariable Long id, Model model) {
        model.addAttribute("user", userService.findById(id));
        model.addAttribute("departments", departmentService.findAll());
        return "user-edit-form";
    }
    
    // Update processing
    @PostMapping("/{id}")
    public String updateUser(@PathVariable Long id,
                           @Valid @ModelAttribute("user") User user,
                           BindingResult bindingResult,
                           Model model,
                           RedirectAttributes redirectAttributes) {
        
        if (bindingResult.hasErrors()) {
            model.addAttribute("departments", departmentService.findAll());
            return "user-edit-form";
        }
        
        user.setId(id);
        userService.update(user);
        redirectAttributes.addFlashAttribute("successMessage", "User updated successfully!");
        return "redirect:/users";
    }
}
```

### Form Template (Thymeleaf)

```html
<!-- user-form.html -->
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title>Create User</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
    <div class="container mt-4">
        <h2>Create New User</h2>
        
        <!-- Success Message -->
        <div th:if="${successMessage}" class="alert alert-success" th:text="${successMessage}"></div>
        
        <!-- Form -->
        <form th:action="@{/users}" th:object="${user}" method="post">
            
            <!-- Name Field -->
            <div class="form-group">
                <label for="name">Name:</label>
                <input type="text" class="form-control" th:field="*{name}" 
                       th:classappend="${#fields.hasErrors('name')} ? 'is-invalid' : ''">
                <div th:if="${#fields.hasErrors('name')}" class="invalid-feedback">
                    <span th:errors="*{name}"></span>
                </div>
            </div>
            
            <!-- Email Field -->
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" class="form-control" th:field="*{email}"
                       th:classappend="${#fields.hasErrors('email')} ? 'is-invalid' : ''">
                <div th:if="${#fields.hasErrors('email')}" class="invalid-feedback">
                    <span th:errors="*{email}"></span>
                </div>
            </div>
            
            <!-- Age Field -->
            <div class="form-group">
                <label for="age">Age:</label>
                <input type="number" class="form-control" th:field="*{age}"
                       th:classappend="${#fields.hasErrors('age')} ? 'is-invalid' : ''">
                <div th:if="${#fields.hasErrors('age')}" class="invalid-feedback">
                    <span th:errors="*{age}"></span>
                </div>
            </div>
            
            <!-- Department Dropdown -->
            <div class="form-group">
                <label for="department">Department:</label>
                <select class="form-control" th:field="*{department.id}">
                    <option value="">Select Department</option>
                    <option th:each="dept : ${departments}" 
                            th:value="${dept.id}" 
                            th:text="${dept.name}"></option>
                </select>
            </div>
            
            <!-- Submit Button -->
            <button type="submit" class="btn btn-primary">Create User</button>
            <a th:href="@{/users}" class="btn btn-secondary">Cancel</a>
        </form>
    </div>
</body>
</html>
```

## Data Binding and Validation

### Model Attributes

```java
@Controller
public class UserController {
    
    // Method-level model attribute
    @ModelAttribute("departments")
    public List<Department> populateDepartments() {
        return departmentService.findAll();
    }
    
    // This will be available in all views handled by this controller
    @ModelAttribute("companyName")
    public String getCompanyName() {
        return "My Company";
    }
    
    @GetMapping("/users/new")
    public String showForm(Model model) {
        model.addAttribute("user", new User());
        // departments and companyName are automatically available
        return "user-form";
    }
}
```

### Validation

```java
// User Entity with Validation
public class User {
    
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    private String name;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Please provide a valid email")
    private String email;
    
    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 100, message = "Age must be less than 100")
    private Integer age;
    
    // Getters and setters
}

// Controller with Validation
@Controller
public class UserController {
    
    @PostMapping("/users")
    public String createUser(@Valid @ModelAttribute("user") User user,
                           BindingResult bindingResult,
                           Model model) {
        
        // Check for validation errors
        if (bindingResult.hasErrors()) {
            // Add any additional model attributes needed for the form
            model.addAttribute("departments", departmentService.findAll());
            return "user-form"; // Return to form with errors
        }
        
        // Process valid user
        userService.save(user);
        return "redirect:/users";
    }
}
```

## Exception Handling in MVC

```java
@ControllerAdvice
public class WebExceptionHandler {
    
    @ExceptionHandler(UserNotFoundException.class)
    public String handleUserNotFound(UserNotFoundException ex, Model model) {
        model.addAttribute("error", "User not found: " + ex.getMessage());
        return "error/404"; // Return error view
    }
    
    @ExceptionHandler(Exception.class)
    public String handleGeneral(Exception ex, Model model) {
        model.addAttribute("error", "An unexpected error occurred");
        return "error/500"; // Return error view
    }
}
```

## Session Management

```java
@Controller
@SessionAttributes("user")
public class UserSessionController {
    
    @GetMapping("/users/session")
    public String startSession(Model model) {
        User user = new User();
        model.addAttribute("user", user); // Stored in session
        return "user-session-form";
    }
    
    @PostMapping("/users/session/step1")
    public String processStep1(@ModelAttribute("user") User user) {
        // User object is retrieved from session and updated
        return "user-session-step2";
    }
    
    @PostMapping("/users/session/complete")
    public String completeSession(@ModelAttribute("user") User user, 
                                SessionStatus sessionStatus) {
        userService.save(user);
        sessionStatus.setComplete(); // Clear session
        return "redirect:/users";
    }
}
```

## Interceptors

```java
@Component
public class LoggingInterceptor implements HandlerInterceptor {
    
    private static final Logger logger = LoggerFactory.getLogger(LoggingInterceptor.class);
    
    @Override
    public boolean preHandle(HttpServletRequest request, 
                           HttpServletResponse response, 
                           Object handler) throws Exception {
        logger.info("Request URL: {}", request.getRequestURL());
        return true; // Continue processing
    }
    
    @Override
    public void postHandle(HttpServletRequest request, 
                          HttpServletResponse response, 
                          Object handler, 
                          ModelAndView modelAndView) throws Exception {
        if (modelAndView != null) {
            logger.info("View Name: {}", modelAndView.getViewName());
        }
    }
    
    @Override
    public void afterCompletion(HttpServletRequest request, 
                              HttpServletResponse response, 
                              Object handler, 
                              Exception ex) throws Exception {
        logger.info("Request completed");
    }
}

// Register Interceptor
@Configuration
public class WebConfig implements WebMvcConfigurer {
    
    @Autowired
    private LoggingInterceptor loggingInterceptor;
    
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(loggingInterceptor)
                .addPathPatterns("/users/**")
                .excludePathPatterns("/users/api/**");
    }
}
```

## Best Practices for MVC

1. **Separation of Concerns** - Keep controllers thin, business logic in services
2. **Use DTOs** - Don't expose entities directly in views
3. **Validation** - Always validate user input
4. **Error Handling** - Implement proper error pages
5. **Security** - Protect against CSRF, XSS attacks
6. **Performance** - Use caching for frequently accessed data
7. **Testing** - Write tests for controllers using MockMvc
8. **Clean URLs** - Use RESTful URL patterns
9. **Internationalization** - Support multiple languages
10. **Accessibility** - Make views accessible to all users