# Springklr Java Interview Questions (0-100% Coverage)

## Table of Contents
1. [Core Java Fundamentals](#core-java-fundamentals)
2. [Object-Oriented Programming](#object-oriented-programming)
3. [Collections Framework](#collections-framework)
4. [Multithreading & Concurrency](#multithreading--concurrency)
5. [Spring Framework](#spring-framework)
6. [Spring Boot](#spring-boot)
7. [Database & JPA/Hibernate](#database--jpahibernate)
8. [Microservices](#microservices)
9. [REST APIs](#rest-apis)
10. [Testing](#testing)
11. [Design Patterns](#design-patterns)
12. [System Design](#system-design)
13. [Performance & Optimization](#performance--optimization)
14. [Security](#security)
15. [Advanced Topics](#advanced-topics)

---

## Core Java Fundamentals

### Basic Level (0-30%)

**Q1: What is Java and what are its key features?**
- Platform independence (Write Once, Run Anywhere)
- Object-oriented programming
- Automatic memory management (Garbage Collection)
- Strong type checking
- Multithreading support
- Security features

**Q2: Explain the difference between JDK, JRE, and JVM.**
- JVM: Java Virtual Machine - executes bytecode
- JRE: Java Runtime Environment - JVM + libraries
- JDK: Java Development Kit - JRE + development tools

**Q3: What are the primitive data types in Java?**
- byte (8-bit), short (16-bit), int (32-bit), long (64-bit)
- float (32-bit), double (64-bit)
- char (16-bit), boolean

**Q4: Difference between == and equals() method?**
- == compares references for objects, values for primitives
- equals() compares object content (can be overridden)

**Q5: What is autoboxing and unboxing?**
- Autoboxing: automatic conversion from primitive to wrapper class
- Unboxing: automatic conversion from wrapper class to primitive

### Intermediate Level (30-60%)

**Q6: Explain String, StringBuffer, and StringBuilder.**
- String: immutable, thread-safe
- StringBuffer: mutable, thread-safe, synchronized
- StringBuilder: mutable, not thread-safe, faster

**Q7: What is the difference between final, finally, and finalize?**
- final: keyword for constants, preventing inheritance/overriding
- finally: block that always executes in try-catch
- finalize: method called by garbage collector

**Q8: Explain exception hierarchy in Java.**
- Throwable → Error & Exception
- Exception → RuntimeException (unchecked) & Checked exceptions
- Common exceptions: NullPointerException, ArrayIndexOutOfBoundsException

**Q9: What are functional interfaces and lambda expressions?**
- Functional interface: interface with single abstract method
- Lambda: anonymous function implementation
- Example: `(x, y) -> x + y`

**Q10: Explain Stream API and its benefits.**
- Functional-style operations on collections
- Lazy evaluation, parallel processing
- Methods: filter, map, reduce, collect

### Advanced Level (60-80%)

**Q11: How does garbage collection work in Java?**
- Automatic memory management
- Generational GC: Young generation (Eden, S0, S1), Old generation
- GC algorithms: Serial, Parallel, G1, ZGC

**Q12: What is reflection and when to use it?**
- Runtime inspection and modification of classes
- Use cases: frameworks, serialization, testing
- Performance overhead considerations

**Q13: Explain Java memory model.**
- Heap: object storage (Young + Old generation)
- Stack: method calls, local variables
- Method Area: class metadata, constant pool
- PC Register, Native Method Stack

---

## Object-Oriented Programming

### Basic Level (0-30%)

**Q14: What are the four pillars of OOP?**
- Encapsulation: data hiding with access modifiers
- Inheritance: IS-A relationship
- Polymorphism: method overloading/overriding
- Abstraction: hiding implementation details

**Q15: Difference between method overloading and overriding?**
- Overloading: same method name, different parameters (compile-time)
- Overriding: same signature in parent-child classes (runtime)

**Q16: What is constructor chaining?**
- Calling one constructor from another using this() or super()
- Must be first statement in constructor

### Intermediate Level (30-60%)

**Q17: Explain abstract classes vs interfaces.**
- Abstract class: can have concrete methods, single inheritance
- Interface: only abstract methods (Java 8+ allows default), multiple inheritance
- Java 8+: interfaces can have default and static methods

**Q18: What is composition vs inheritance?**
- Inheritance: IS-A relationship, tight coupling
- Composition: HAS-A relationship, loose coupling, preferred approach

**Q19: Explain access modifiers in Java.**
- private: same class only
- default: same package
- protected: same package + subclasses
- public: everywhere

### Advanced Level (60-80%)

**Q20: What are design principles (SOLID)?**
- Single Responsibility Principle
- Open/Closed Principle
- Liskov Substitution Principle
- Interface Segregation Principle
- Dependency Inversion Principle

---

## Collections Framework

### Basic Level (0-30%)

**Q21: Explain the Collections hierarchy.**
- Collection → List, Set, Queue
- Map (separate hierarchy)
- Common implementations: ArrayList, LinkedList, HashSet, HashMap

**Q22: Difference between ArrayList and LinkedList?**
- ArrayList: dynamic array, fast random access, slow insertion/deletion
- LinkedList: doubly-linked list, slow random access, fast insertion/deletion

**Q23: What is the difference between Set and List?**
- List: allows duplicates, maintains insertion order
- Set: no duplicates, may or may not maintain order

### Intermediate Level (30-60%)

**Q24: HashMap vs HashTable vs ConcurrentHashMap?**
- HashMap: not thread-safe, allows null
- HashTable: thread-safe (synchronized), no null
- ConcurrentHashMap: thread-safe, better performance, no null

**Q25: How does HashMap work internally?**
- Array of buckets, hash function determines bucket
- Collision handling: chaining (linked list/tree)
- Load factor, rehashing when threshold exceeded

**Q26: What are fail-fast and fail-safe iterators?**
- Fail-fast: throws ConcurrentModificationException (ArrayList, HashMap)
- Fail-safe: works on copy, no exception (ConcurrentHashMap, CopyOnWriteArrayList)

### Advanced Level (60-80%)

**Q27: Explain TreeMap and its internal working.**
- Red-Black tree implementation
- Sorted order based on keys
- O(log n) operations

**Q28: What is the difference between Comparable and Comparator?**
- Comparable: natural ordering, compareTo() method
- Comparator: custom ordering, compare() method
- Functional interface in Java 8+

---

## Multithreading & Concurrency

### Basic Level (0-30%)

**Q29: What is multithreading and its benefits?**
- Concurrent execution of multiple threads
- Benefits: better resource utilization, responsiveness, parallelism

**Q30: How to create threads in Java?**
- Extend Thread class
- Implement Runnable interface
- Use Callable with ExecutorService

**Q31: Explain thread lifecycle.**
- NEW → RUNNABLE → BLOCKED/WAITING/TIMED_WAITING → TERMINATED

### Intermediate Level (30-60%)

**Q32: What is synchronization and why is it needed?**
- Controlling access to shared resources
- Prevents race conditions and data inconsistency
- synchronized keyword, locks

**Q33: Difference between wait() and sleep()?**
- wait(): releases lock, must be in synchronized block
- sleep(): doesn't release lock, static method

**Q34: What is deadlock and how to prevent it?**
- Circular dependency of locks
- Prevention: lock ordering, timeout, deadlock detection

### Advanced Level (60-80%)

**Q35: Explain ExecutorService and thread pools.**
- Framework for managing threads
- Types: FixedThreadPool, CachedThreadPool, SingleThreadExecutor
- Benefits: thread reuse, better resource management

**Q36: What are concurrent collections?**
- Thread-safe collections: ConcurrentHashMap, CopyOnWriteArrayList
- BlockingQueue implementations
- Better performance than synchronized collections

**Q37: Explain volatile keyword.**
- Ensures visibility of changes across threads
- Prevents instruction reordering
- Not atomic for compound operations

---

## Spring Framework

### Basic Level (0-30%)

**Q38: What is Spring Framework and its benefits?**
- Comprehensive framework for enterprise Java
- Benefits: DI, AOP, transaction management, testing support

**Q39: What is Dependency Injection?**
- Design pattern where dependencies are provided externally
- Types: Constructor, Setter, Field injection
- Reduces coupling, improves testability

**Q40: Explain IoC (Inversion of Control).**
- Control of object creation transferred to framework
- Container manages object lifecycle
- ApplicationContext, BeanFactory

### Intermediate Level (30-60%)

**Q41: What are Spring Bean scopes?**
- Singleton: one instance per container (default)
- Prototype: new instance each time
- Request, Session, Application (web-specific)

**Q42: Explain Spring AOP.**
- Aspect-Oriented Programming
- Cross-cutting concerns: logging, security, transactions
- Concepts: Aspect, Advice, Pointcut, Join Point

**Q43: What is Spring MVC architecture?**
- Model-View-Controller pattern
- DispatcherServlet, Controller, ViewResolver
- Request flow: Client → DispatcherServlet → Controller → Service → Repository

### Advanced Level (60-80%)

**Q44: Explain Spring transaction management.**
- Declarative: @Transactional annotation
- Programmatic: TransactionTemplate
- Propagation levels, isolation levels

**Q45: What are Spring profiles?**
- Environment-specific configuration
- @Profile annotation, spring.profiles.active
- Different beans for different environments

---

## Spring Boot

### Basic Level (0-30%)

**Q46: What is Spring Boot and its advantages?**
- Opinionated framework built on Spring
- Auto-configuration, embedded servers, starter dependencies
- Rapid application development

**Q47: Explain Spring Boot starters.**
- Pre-configured dependency sets
- Examples: spring-boot-starter-web, spring-boot-starter-data-jpa
- Reduces configuration overhead

**Q48: What is auto-configuration in Spring Boot?**
- Automatic configuration based on classpath
- @EnableAutoConfiguration, @SpringBootApplication
- Can be customized or disabled

### Intermediate Level (30-60%)

**Q49: Explain Spring Boot Actuator.**
- Production-ready features
- Endpoints: health, metrics, info, beans
- Monitoring and management capabilities

**Q50: What are configuration properties in Spring Boot?**
- External configuration: application.properties/yml
- @ConfigurationProperties, @Value
- Profile-specific properties

**Q51: How to create custom auto-configuration?**
- @Configuration + @ConditionalOn* annotations
- META-INF/spring.factories file
- Custom starter creation

### Advanced Level (60-80%)

**Q52: Explain Spring Boot testing.**
- @SpringBootTest for integration tests
- @WebMvcTest for web layer
- @DataJpaTest for repository layer
- TestContainers for database testing

---

## Database & JPA/Hibernate

### Basic Level (0-30%)

**Q53: What is JPA and its benefits?**
- Java Persistence API - ORM specification
- Database independence, object-relational mapping
- Hibernate is popular implementation

**Q54: Explain basic JPA annotations.**
- @Entity, @Table, @Id, @GeneratedValue
- @Column, @JoinColumn, @OneToMany, @ManyToOne

**Q55: What is EntityManager?**
- Interface for persistence operations
- CRUD operations: persist, find, merge, remove
- Query execution

### Intermediate Level (30-60%)

**Q56: Explain JPA relationships.**
- @OneToOne, @OneToMany, @ManyToOne, @ManyToMany
- Cascade types, fetch types (LAZY, EAGER)
- Bidirectional relationships

**Q57: What is the difference between save() and saveAndFlush()?**
- save(): persists entity, may not immediately sync to DB
- saveAndFlush(): persists and immediately flushes to DB

**Q58: Explain JPQL vs Native SQL.**
- JPQL: object-oriented query language
- Native SQL: database-specific SQL
- @Query annotation usage

### Advanced Level (60-80%)

**Q59: What is Hibernate caching?**
- First-level cache: session-level (mandatory)
- Second-level cache: SessionFactory-level (optional)
- Query cache for query results

**Q60: Explain N+1 problem and solutions.**
- Problem: additional queries for each result
- Solutions: JOIN FETCH, @EntityGraph, batch fetching
- Proper fetch strategy selection

---

## Microservices

### Basic Level (0-30%)

**Q61: What are microservices and their benefits?**
- Architectural pattern: small, independent services
- Benefits: scalability, technology diversity, fault isolation
- Challenges: complexity, network latency, data consistency

**Q62: Microservices vs Monolithic architecture?**
- Monolithic: single deployable unit, shared database
- Microservices: multiple services, separate databases
- Trade-offs in complexity vs scalability

### Intermediate Level (30-60%)

**Q63: How do microservices communicate?**
- Synchronous: REST APIs, gRPC
- Asynchronous: Message queues, event streaming
- Service discovery, load balancing

**Q64: What is API Gateway?**
- Single entry point for client requests
- Features: routing, authentication, rate limiting
- Examples: Spring Cloud Gateway, Zuul

**Q65: Explain service discovery.**
- Mechanism to locate services dynamically
- Client-side vs server-side discovery
- Tools: Eureka, Consul, Kubernetes DNS

### Advanced Level (60-80%)

**Q66: What is Circuit Breaker pattern?**
- Prevents cascading failures
- States: Closed, Open, Half-Open
- Implementation: Hystrix, Resilience4j

**Q67: How to handle distributed transactions?**
- Saga pattern: choreography vs orchestration
- Two-phase commit (2PC)
- Event sourcing, CQRS

---

## REST APIs

### Basic Level (0-30%)

**Q68: What is REST and its principles?**
- Representational State Transfer
- Principles: stateless, cacheable, uniform interface
- HTTP methods: GET, POST, PUT, DELETE

**Q69: Explain HTTP status codes.**
- 2xx: Success (200 OK, 201 Created)
- 4xx: Client errors (400 Bad Request, 404 Not Found)
- 5xx: Server errors (500 Internal Server Error)

**Q70: What is the difference between PUT and POST?**
- POST: create new resource, not idempotent
- PUT: create/update resource, idempotent

### Intermediate Level (30-60%)

**Q71: How to handle validation in REST APIs?**
- @Valid annotation with Bean Validation
- Custom validators, @ControllerAdvice for global handling
- Input validation, business rule validation

**Q72: Explain REST API versioning strategies.**
- URL versioning: /api/v1/users
- Header versioning: Accept: application/vnd.api+json;version=1
- Parameter versioning: /api/users?version=1

**Q73: What is HATEOAS?**
- Hypermedia as the Engine of Application State
- Self-descriptive APIs with links
- Spring HATEOAS implementation

### Advanced Level (60-80%)

**Q74: How to implement API security?**
- Authentication: JWT, OAuth 2.0
- Authorization: role-based, method-level security
- HTTPS, input validation, rate limiting

**Q75: Explain API documentation.**
- OpenAPI/Swagger specification
- Springdoc-openapi for Spring Boot
- Interactive documentation, code generation

---

## Testing

### Basic Level (0-30%)

**Q76: What are different types of testing?**
- Unit testing: individual components
- Integration testing: component interactions
- End-to-end testing: complete user workflows

**Q77: Explain JUnit basics.**
- @Test, @BeforeEach, @AfterEach
- Assertions: assertEquals, assertTrue, assertThrows
- Test lifecycle, parameterized tests

### Intermediate Level (30-60%)

**Q78: What is Mockito and how to use it?**
- Mocking framework for unit tests
- @Mock, @InjectMocks annotations
- when().thenReturn(), verify() methods

**Q79: Explain test slices in Spring Boot.**
- @WebMvcTest: web layer testing
- @DataJpaTest: repository layer testing
- @JsonTest: JSON serialization testing

### Advanced Level (60-80%)

**Q80: What is Test-Driven Development (TDD)?**
- Red-Green-Refactor cycle
- Write test first, then implementation
- Benefits: better design, confidence, documentation

**Q81: How to test microservices?**
- Contract testing: Pact, Spring Cloud Contract
- Integration testing with TestContainers
- End-to-end testing strategies

---

## Design Patterns

### Basic Level (0-30%)

**Q82: What are design patterns and their types?**
- Reusable solutions to common problems
- Types: Creational, Structural, Behavioral
- Gang of Four patterns

**Q83: Explain Singleton pattern.**
- Ensures single instance of class
- Thread-safe implementations
- Use cases: database connections, logging

### Intermediate Level (30-60%)

**Q84: What is Factory pattern?**
- Creates objects without specifying exact class
- Factory Method vs Abstract Factory
- Encapsulates object creation logic

**Q85: Explain Observer pattern.**
- One-to-many dependency between objects
- Subject notifies observers of state changes
- Implementation in Java: Observable/Observer

**Q86: What is Strategy pattern?**
- Defines family of algorithms, makes them interchangeable
- Encapsulates algorithms in separate classes
- Runtime algorithm selection

### Advanced Level (60-80%)

**Q87: Explain Builder pattern.**
- Constructs complex objects step by step
- Fluent interface, method chaining
- Useful for objects with many optional parameters

**Q88: What is Command pattern?**
- Encapsulates request as object
- Parameterize objects with different requests
- Support undo operations, queuing

---

## System Design

### Intermediate Level (30-60%)

**Q89: How to design a scalable web application?**
- Load balancing, horizontal scaling
- Database sharding, caching strategies
- CDN, microservices architecture

**Q90: Explain caching strategies.**
- Cache-aside, write-through, write-behind
- Levels: browser, CDN, application, database
- Tools: Redis, Memcached, Hazelcast

**Q91: What is database sharding?**
- Horizontal partitioning of data
- Sharding strategies: range, hash, directory
- Challenges: cross-shard queries, rebalancing

### Advanced Level (60-80%)

**Q92: How to handle high availability?**
- Redundancy, failover mechanisms
- Health checks, circuit breakers
- Disaster recovery planning

**Q93: Explain event-driven architecture.**
- Asynchronous communication via events
- Event sourcing, CQRS pattern
- Message brokers: Kafka, RabbitMQ

---

## Performance & Optimization

### Intermediate Level (30-60%)

**Q94: How to optimize Java application performance?**
- JVM tuning: heap size, GC algorithms
- Code optimization: algorithms, data structures
- Database optimization: indexing, query tuning

**Q95: Explain memory leaks in Java.**
- Common causes: static collections, listeners, connections
- Detection: profilers, heap dumps
- Prevention: proper resource management

### Advanced Level (60-80%)

**Q96: What is JVM profiling?**
- Performance analysis tools
- CPU profiling, memory profiling
- Tools: JProfiler, VisualVM, JFR

**Q97: How to optimize database performance?**
- Proper indexing strategies
- Query optimization, connection pooling
- Database monitoring and tuning

---

## Security

### Intermediate Level (30-60%)

**Q98: How to implement authentication in Spring?**
- Spring Security framework
- Authentication providers, user details service
- JWT token-based authentication

**Q99: What are common security vulnerabilities?**
- SQL injection, XSS, CSRF
- Input validation, output encoding
- OWASP Top 10 security risks

### Advanced Level (60-80%)

**Q100: Explain OAuth 2.0 and JWT.**
- OAuth 2.0: authorization framework
- JWT: JSON Web Token for stateless authentication
- Token validation, refresh tokens

---

## Advanced Topics

### Advanced Level (80-100%)

**Q101: What is reactive programming?**
- Asynchronous, non-blocking programming
- Spring WebFlux, Project Reactor
- Backpressure handling, reactive streams

**Q102: Explain Java modules (JPMS).**
- Java Platform Module System (Java 9+)
- module-info.java, exports, requires
- Strong encapsulation, reliable configuration

**Q103: What are records in Java?**
- Immutable data carriers (Java 14+)
- Automatic generation of constructor, getters, equals, hashCode
- Compact syntax for data classes

**Q104: Explain virtual threads (Project Loom).**
- Lightweight threads (Java 19+)
- Better scalability for I/O-bound applications
- Structured concurrency

**Q105: What is GraalVM and native images?**
- High-performance runtime
- Ahead-of-time compilation
- Faster startup, lower memory footprint

---

## Coding Challenges (Practical Questions)

**Q106: Implement a thread-safe Singleton.**
```java
public class Singleton {
    private static volatile Singleton instance;
    
    private Singleton() {}
    
    public static Singleton getInstance() {
        if (instance == null) {
            synchronized (Singleton.class) {
                if (instance == null) {
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}
```

**Q107: Create a custom annotation for logging.**
**Q108: Implement a simple connection pool.**
**Q109: Design a rate limiter.**
**Q110: Create a custom Spring Boot starter.**

---

## Behavioral & Scenario Questions

**Q111: How do you handle production issues?**
**Q112: Describe your approach to code reviews.**
**Q113: How do you stay updated with Java technologies?**
**Q114: Explain a challenging technical problem you solved.**
**Q115: How do you ensure code quality in your projects?**

---

## Tips for Springklr Interview Success

1. **Focus on Spring ecosystem** - Deep knowledge of Spring Boot, Spring Security, Spring Data
2. **Microservices expertise** - Understanding of distributed systems, service communication
3. **Database proficiency** - JPA/Hibernate, query optimization, transaction management
4. **Testing knowledge** - Unit testing, integration testing, mocking frameworks
5. **System design skills** - Scalability, performance, reliability considerations
6. **Practical experience** - Be ready to discuss real projects and challenges
7. **Code quality** - Clean code principles, design patterns, best practices
8. **Problem-solving** - Analytical thinking, debugging skills
9. **Communication** - Explain complex concepts clearly
10. **Continuous learning** - Stay updated with latest Java and Spring features

---

*This comprehensive guide covers 0-100% of Java interview topics commonly asked at Springklr. Practice these questions, understand the concepts deeply, and be prepared to provide practical examples from your experience.*