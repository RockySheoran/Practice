# Java Interview Questions - Complete Guide

## Table of Contents
1. [Core Java Basics](#core-java-basics)
2. [Object-Oriented Programming](#object-oriented-programming)
3. [Collections Framework](#collections-framework)
4. [Exception Handling](#exception-handling)
5. [Multithreading](#multithreading)
6. [Memory Management](#memory-management)
7. [Java 8+ Features](#java-8-features)
8. [Design Patterns](#design-patterns)
9. [Spring Framework](#spring-framework)
10. [Advanced Topics](#advanced-topics)

---

## Core Java Basics

### 1. What is Java and what are its key features?
**Answer**: Java is a high-level, object-oriented programming language developed by Sun Microsystems. Key features include:
- **Platform Independence**: Write Once, Run Anywhere (WORA)
- **Object-Oriented**: Supports encapsulation, inheritance, polymorphism
- **Secure**: Built-in security features, no explicit pointers
- **Robust**: Strong memory management, exception handling
- **Multithreaded**: Built-in support for concurrent programming
- **Simple**: Easy to learn and use syntax

### 2. Explain JVM, JRE, and JDK
**Answer**:
- **JVM (Java Virtual Machine)**: Runtime environment that executes Java bytecode
- **JRE (Java Runtime Environment)**: JVM + libraries needed to run Java applications
- **JDK (Java Development Kit)**: JRE + development tools (compiler, debugger, etc.)

### 3. What is the difference between == and equals() method?
**Answer**:
- **==**: Compares references (memory addresses) for objects, values for primitives
- **equals()**: Compares actual content/values of objects
```java
String s1 = new String("Hello");
String s2 = new String("Hello");
System.out.println(s1 == s2);        // false (different references)
System.out.println(s1.equals(s2));   // true (same content)
```

### 4. What is the difference between String, StringBuffer, and StringBuilder?
**Answer**:
- **String**: Immutable, thread-safe, creates new object for modifications
- **StringBuffer**: Mutable, thread-safe (synchronized), better for multi-threaded environments
- **StringBuilder**: Mutable, not thread-safe, faster performance in single-threaded environments

```java
// String - creates new objects
String str = "Hello";
str += " World"; // Creates new String object

// StringBuilder - modifies existing buffer
StringBuilder sb = new StringBuilder("Hello");
sb.append(" World"); // Modifies existing buffer
```

### 5. What are access modifiers in Java?
**Answer**:
- **public**: Accessible from anywhere
- **protected**: Accessible within package and subclasses
- **default (package-private)**: Accessible within same package only
- **private**: Accessible within same class only

### 6. What is the difference between static and non-static methods?
**Answer**:
- **Static methods**: Belong to class, called without creating instance, cannot access instance variables
- **Non-static methods**: Belong to instance, require object creation, can access both static and instance variables

```java
public class Example {
    static int staticVar = 10;
    int instanceVar = 20;
    
    static void staticMethod() {
        System.out.println(staticVar); // OK
        // System.out.println(instanceVar); // Error - cannot access instance variable
    }
    
    void instanceMethod() {
        System.out.println(staticVar);    // OK
        System.out.println(instanceVar);  // OK
    }
}
```

### 7. What is method overloading and overriding?
**Answer**:
- **Overloading**: Same method name with different parameters (compile-time polymorphism)
- **Overriding**: Subclass provides specific implementation of parent class method (runtime polymorphism)

```java
// Overloading
public class Calculator {
    public int add(int a, int b) { return a + b; }
    public double add(double a, double b) { return a + b; }
}

// Overriding
class Animal {
    public void makeSound() { System.out.println("Animal sound"); }
}
class Dog extends Animal {
    @Override
    public void makeSound() { System.out.println("Woof!"); }
}
```

### 8. What is the final keyword in Java?
**Answer**:
- **final variable**: Cannot be reassigned (constant)
- **final method**: Cannot be overridden
- **final class**: Cannot be extended (e.g., String, Integer)

```java
final int x = 10;        // Constant
final void method() {}   // Cannot be overridden
final class MyClass {}   // Cannot be extended
```

### 9. What is the difference between abstract class and interface?
**Answer**:

| Abstract Class | Interface |
|----------------|-----------|
| Can have concrete methods | All methods abstract (before Java 8) |
| Can have instance variables | Only constants (public static final) |
| Single inheritance | Multiple inheritance |
| Can have constructors | Cannot have constructors |
| Can have any access modifier | Methods are public by default |

### 10. What is autoboxing and unboxing?
**Answer**:
- **Autoboxing**: Automatic conversion of primitive to wrapper class
- **Unboxing**: Automatic conversion of wrapper class to primitive

```java
Integer i = 10;        // Autoboxing (int to Integer)
int j = i;             // Unboxing (Integer to int)
```

---

## Object-Oriented Programming

### 11. What are the four pillars of OOP?
**Answer**:
1. **Encapsulation**: Bundling data and methods, hiding internal details
2. **Inheritance**: Creating new classes based on existing classes
3. **Polymorphism**: Same interface, different implementations
4. **Abstraction**: Hiding complex implementation details

### 12. What is encapsulation and how do you achieve it?
**Answer**: Encapsulation is wrapping data and methods together and restricting direct access to data. Achieved through:
- Private instance variables
- Public getter/setter methods
- Validation in setter methods

```java
public class Person {
    private String name;
    private int age;
    
    public String getName() { return name; }
    
    public void setAge(int age) {
        if (age > 0 && age < 150) {
            this.age = age;
        }
    }
}
```

### 13. What is inheritance and its types?
**Answer**: Inheritance allows creating new classes based on existing classes.
- **Single Inheritance**: One parent class
- **Multilevel Inheritance**: Chain of inheritance (A → B → C)
- **Hierarchical Inheritance**: Multiple classes inherit from one parent
- **Multiple Inheritance**: Not supported in Java (use interfaces)

### 14. What is polymorphism? Explain with examples.
**Answer**: Polymorphism means "many forms" - same interface, different implementations.

**Compile-time Polymorphism (Method Overloading)**:
```java
public class MathUtils {
    public int add(int a, int b) { return a + b; }
    public double add(double a, double b) { return a + b; }
}
```

**Runtime Polymorphism (Method Overriding)**:
```java
Animal animal = new Dog();
animal.makeSound(); // Calls Dog's makeSound() method
```

### 15. What is the super keyword?
**Answer**: `super` refers to the immediate parent class:
- `super()`: Calls parent constructor
- `super.method()`: Calls parent method
- `super.variable`: Accesses parent variable

```java
class Parent {
    String name = "Parent";
    public void display() { System.out.println("Parent display"); }
}

class Child extends Parent {
    String name = "Child";
    
    public void display() {
        super.display();           // Calls parent method
        System.out.println(super.name); // Accesses parent variable
    }
}
```

---

## Collections Framework

### 16. What is the Collections Framework hierarchy?
**Answer**: 
```
Collection (Interface)
├── List (Interface)
│   ├── ArrayList
│   ├── LinkedList
│   └── Vector
├── Set (Interface)
│   ├── HashSet
│   ├── LinkedHashSet
│   └── TreeSet
└── Queue (Interface)
    ├── PriorityQueue
    └── LinkedList

Map (Interface)
├── HashMap
├── LinkedHashMap
├── TreeMap
└── Hashtable
```

### 17. What is the difference between ArrayList and LinkedList?
**Answer**:

| ArrayList | LinkedList |
|-----------|------------|
| Dynamic array implementation | Doubly linked list implementation |
| Fast random access O(1) | Sequential access O(n) |
| Slow insertion/deletion O(n) | Fast insertion/deletion O(1) |
| Less memory overhead | More memory overhead (node pointers) |
| Better for frequent access | Better for frequent modifications |

### 18. What is the difference between HashMap and Hashtable?
**Answer**:

| HashMap | Hashtable |
|---------|-----------|
| Not synchronized (not thread-safe) | Synchronized (thread-safe) |
| Allows null key and values | Doesn't allow null key or values |
| Introduced in Java 1.2 | Legacy class (Java 1.0) |
| Better performance | Slower due to synchronization |
| Fail-fast iterator | Fail-safe iterator |

### 19. How does HashMap work internally?
**Answer**: HashMap uses array of buckets with hashing:
1. **Hash Function**: Calculates hash code for key
2. **Bucket Index**: `hash % array_length`
3. **Collision Handling**: Uses linked list (Java 7) or balanced tree (Java 8+)
4. **Load Factor**: Default 0.75, triggers resizing when exceeded

```java
// Simplified HashMap working
public class SimpleHashMap<K, V> {
    private Node<K, V>[] buckets;
    private int size;
    
    static class Node<K, V> {
        K key;
        V value;
        Node<K, V> next;
    }
    
    public V put(K key, V value) {
        int index = hash(key) % buckets.length;
        // Handle collision with chaining
        // Insert or update value
        return value;
    }
}
```

### 20. What is the difference between HashSet and TreeSet?
**Answer**:

| HashSet | TreeSet |
|---------|---------|
| Hash table implementation | Red-Black tree implementation |
| O(1) average time complexity | O(log n) time complexity |
| No ordering | Sorted order (natural or custom) |
| Allows null values | Doesn't allow null values |
| Better performance | Slower but maintains order |

### 21. What is Iterator and ListIterator?
**Answer**:
- **Iterator**: Forward-only traversal, works with all collections
- **ListIterator**: Bidirectional traversal, only for List implementations

```java
List<String> list = Arrays.asList("A", "B", "C");

// Iterator
Iterator<String> iter = list.iterator();
while (iter.hasNext()) {
    System.out.println(iter.next());
}

// ListIterator
ListIterator<String> listIter = list.listIterator();
while (listIter.hasNext()) {
    System.out.println(listIter.next());
}
while (listIter.hasPrevious()) {
    System.out.println(listIter.previous());
}
```

### 22. What is the difference between Comparable and Comparator?
**Answer**:

| Comparable | Comparator |
|------------|------------|
| Natural ordering | Custom ordering |
| Single sorting sequence | Multiple sorting sequences |
| Modifies original class | External class |
| compareTo() method | compare() method |

```java
// Comparable
class Student implements Comparable<Student> {
    private String name;
    private int age;
    
    @Override
    public int compareTo(Student other) {
        return this.age - other.age; // Sort by age
    }
}

// Comparator
Comparator<Student> nameComparator = (s1, s2) -> s1.getName().compareTo(s2.getName());
Collections.sort(students, nameComparator);
```

---

## Exception Handling

### 23. What is Exception Handling in Java?
**Answer**: Exception handling is a mechanism to handle runtime errors gracefully using try-catch-finally blocks.

**Exception Hierarchy**:
```
Throwable
├── Error (System errors, not recoverable)
└── Exception
    ├── RuntimeException (Unchecked)
    │   ├── NullPointerException
    │   ├── ArrayIndexOutOfBoundsException
    │   └── IllegalArgumentException
    └── Checked Exceptions
        ├── IOException
        ├── SQLException
        └── ClassNotFoundException
```

### 24. What is the difference between checked and unchecked exceptions?
**Answer**:

| Checked Exceptions | Unchecked Exceptions |
|-------------------|---------------------|
| Compile-time checking | Runtime checking |
| Must be handled or declared | Optional handling |
| Extend Exception class | Extend RuntimeException |
| IOException, SQLException | NullPointerException, ArrayIndexOutOfBoundsException |

### 25. What is the difference between throw and throws?
**Answer**:
- **throw**: Used to explicitly throw an exception
- **throws**: Used in method signature to declare exceptions

```java
public void method1() throws IOException {
    // Method may throw IOException
}

public void method2() {
    if (condition) {
        throw new IllegalArgumentException("Invalid argument");
    }
}
```

### 26. Can we have multiple catch blocks?
**Answer**: Yes, but specific exceptions should come before general ones.

```java
try {
    // risky code
} catch (FileNotFoundException e) {
    // Handle specific exception first
} catch (IOException e) {
    // Handle general exception
} catch (Exception e) {
    // Handle most general exception last
}
```

### 27. What is try-with-resources?
**Answer**: Automatic resource management introduced in Java 7.

```java
// Traditional approach
FileInputStream fis = null;
try {
    fis = new FileInputStream("file.txt");
    // use fis
} catch (IOException e) {
    e.printStackTrace();
} finally {
    if (fis != null) {
        try {
            fis.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

// Try-with-resources
try (FileInputStream fis = new FileInputStream("file.txt")) {
    // use fis
} catch (IOException e) {
    e.printStackTrace();
} // fis.close() called automatically
```

---

## Multithreading

### 28. What is multithreading and its advantages?
**Answer**: Multithreading allows concurrent execution of multiple threads.

**Advantages**:
- Better CPU utilization
- Improved application responsiveness
- Parallel processing
- Resource sharing

### 29. How can you create a thread in Java?
**Answer**: Three ways to create threads:

```java
// 1. Extending Thread class
class MyThread extends Thread {
    @Override
    public void run() {
        System.out.println("Thread running: " + Thread.currentThread().getName());
    }
}

// 2. Implementing Runnable interface
class MyRunnable implements Runnable {
    @Override
    public void run() {
        System.out.println("Runnable running: " + Thread.currentThread().getName());
    }
}

// 3. Using Callable interface (returns result)
class MyCallable implements Callable<String> {
    @Override
    public String call() throws Exception {
        return "Result from callable";
    }
}

// Usage
MyThread thread1 = new MyThread();
thread1.start();

Thread thread2 = new Thread(new MyRunnable());
thread2.start();

ExecutorService executor = Executors.newSingleThreadExecutor();
Future<String> future = executor.submit(new MyCallable());
```

### 30. What is synchronization and why is it needed?
**Answer**: Synchronization prevents thread interference and memory consistency errors.

```java
public class Counter {
    private int count = 0;
    
    // Synchronized method
    public synchronized void increment() {
        count++;
    }
    
    // Synchronized block
    public void decrement() {
        synchronized (this) {
            count--;
        }
    }
    
    public int getCount() {
        return count;
    }
}
```

### 31. What is the difference between wait() and sleep()?
**Answer**:

| wait() | sleep() |
|--------|---------|
| Object class method | Thread class method |
| Releases lock | Doesn't release lock |
| Must be called in synchronized context | Can be called anywhere |
| Woken up by notify()/notifyAll() | Wakes up after specified time |

### 32. What is deadlock and how to prevent it?
**Answer**: Deadlock occurs when two or more threads wait for each other indefinitely.

**Prevention strategies**:
- Avoid nested locks
- Use timeout for lock acquisition
- Lock ordering
- Use concurrent collections

```java
// Deadlock example
public class DeadlockExample {
    private final Object lock1 = new Object();
    private final Object lock2 = new Object();
    
    public void method1() {
        synchronized (lock1) {
            synchronized (lock2) {
                // Do something
            }
        }
    }
    
    public void method2() {
        synchronized (lock2) {  // Different order - potential deadlock
            synchronized (lock1) {
                // Do something
            }
        }
    }
}
```

### 33. What is ThreadLocal?
**Answer**: ThreadLocal provides thread-local variables where each thread has its own copy.

```java
public class ThreadLocalExample {
    private static ThreadLocal<Integer> threadLocal = new ThreadLocal<Integer>() {
        @Override
        protected Integer initialValue() {
            return 0;
        }
    };
    
    public static void main(String[] args) {
        Runnable task = () -> {
            threadLocal.set((int) (Math.random() * 100));
            System.out.println("Thread: " + Thread.currentThread().getName() + 
                             ", Value: " + threadLocal.get());
        };
        
        Thread t1 = new Thread(task);
        Thread t2 = new Thread(task);
        t1.start();
        t2.start();
    }
}
```

---

## Memory Management

### 34. Explain Java Memory Model
**Answer**: Java memory is divided into:

**Heap Memory**:
- **Young Generation**: Eden space, Survivor spaces (S0, S1)
- **Old Generation**: Long-lived objects
- **Metaspace**: Class metadata (Java 8+)

**Non-Heap Memory**:
- **Method Area**: Class-level data
- **PC Registers**: Program counter for each thread
- **Native Method Stacks**: Native method calls
- **JVM Stacks**: Method call frames

### 35. What is Garbage Collection?
**Answer**: Automatic memory management that reclaims memory used by objects no longer reachable.

**GC Types**:
- **Serial GC**: Single-threaded, suitable for small applications
- **Parallel GC**: Multi-threaded, default for server applications
- **G1 GC**: Low-latency collector for large heaps
- **ZGC/Shenandoah**: Ultra-low latency collectors

### 36. What are strong, weak, soft, and phantom references?
**Answer**:

| Reference Type | GC Behavior | Use Case |
|----------------|-------------|----------|
| Strong | Never collected if reachable | Normal object references |
| Weak | Collected in next GC cycle | Caches, observer patterns |
| Soft | Collected when memory is low | Memory-sensitive caches |
| Phantom | Collected, but reference queued | Cleanup actions |

```java
// Strong reference
Object obj = new Object();

// Weak reference
WeakReference<Object> weakRef = new WeakReference<>(obj);

// Soft reference
SoftReference<Object> softRef = new SoftReference<>(obj);

// Phantom reference
ReferenceQueue<Object> queue = new ReferenceQueue<>();
PhantomReference<Object> phantomRef = new PhantomReference<>(obj, queue);
```

### 37. What causes OutOfMemoryError?
**Answer**: Common causes:
- **Heap Space**: Too many objects in heap
- **Metaspace**: Too many classes loaded
- **Stack Overflow**: Deep recursion or large local variables
- **Memory Leaks**: Objects not properly dereferenced

---

## Java 8+ Features

### 38. What are Lambda expressions?
**Answer**: Lambda expressions provide a concise way to represent anonymous functions.

```java
// Traditional approach
Comparator<String> comparator = new Comparator<String>() {
    @Override
    public int compare(String s1, String s2) {
        return s1.compareTo(s2);
    }
};

// Lambda expression
Comparator<String> lambdaComparator = (s1, s2) -> s1.compareTo(s2);

// Method reference
Comparator<String> methodRef = String::compareTo;
```

### 39. What are Functional Interfaces?
**Answer**: Interfaces with exactly one abstract method, can be used with lambda expressions.

**Built-in Functional Interfaces**:
```java
// Predicate<T> - takes T, returns boolean
Predicate<Integer> isEven = n -> n % 2 == 0;

// Function<T, R> - takes T, returns R
Function<String, Integer> stringLength = s -> s.length();

// Consumer<T> - takes T, returns void
Consumer<String> printer = s -> System.out.println(s);

// Supplier<T> - takes nothing, returns T
Supplier<Double> randomSupplier = () -> Math.random();
```

### 40. What is Stream API?
**Answer**: Stream API provides functional-style operations on collections.

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

// Filter, map, and collect
List<Integer> evenSquares = numbers.stream()
    .filter(n -> n % 2 == 0)
    .map(n -> n * n)
    .collect(Collectors.toList());

// Reduce operation
int sum = numbers.stream()
    .reduce(0, Integer::sum);

// Parallel processing
long count = numbers.parallelStream()
    .filter(n -> n > 5)
    .count();
```

### 41. What are Optional classes?
**Answer**: Optional is a container that may or may not contain a value, helps avoid NullPointerException.

```java
Optional<String> optional = Optional.of("Hello");

// Check if value is present
if (optional.isPresent()) {
    System.out.println(optional.get());
}

// Functional approach
optional.ifPresent(System.out::println);

// Provide default value
String value = optional.orElse("Default");

// Chain operations
optional.map(String::toUpperCase)
        .filter(s -> s.length() > 3)
        .ifPresent(System.out::println);
```

### 42. What are default and static methods in interfaces?
**Answer**: Java 8 introduced default and static methods in interfaces.

```java
public interface MyInterface {
    // Abstract method
    void abstractMethod();
    
    // Default method
    default void defaultMethod() {
        System.out.println("Default implementation");
    }
    
    // Static method
    static void staticMethod() {
        System.out.println("Static method in interface");
    }
}
```

---

## Design Patterns

### 43. What is Singleton pattern and how to implement it?
**Answer**: Singleton ensures only one instance of a class exists.

```java
// Thread-safe Singleton
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

// Enum Singleton (recommended)
public enum SingletonEnum {
    INSTANCE;
    
    public void doSomething() {
        // Implementation
    }
}
```

### 44. Explain Factory pattern
**Answer**: Factory pattern creates objects without specifying exact classes.

```java
// Product interface
interface Shape {
    void draw();
}

// Concrete products
class Circle implements Shape {
    public void draw() { System.out.println("Drawing Circle"); }
}

class Rectangle implements Shape {
    public void draw() { System.out.println("Drawing Rectangle"); }
}

// Factory
class ShapeFactory {
    public static Shape createShape(String type) {
        switch (type.toLowerCase()) {
            case "circle": return new Circle();
            case "rectangle": return new Rectangle();
            default: throw new IllegalArgumentException("Unknown shape");
        }
    }
}
```

### 45. What is Observer pattern?
**Answer**: Observer pattern defines one-to-many dependency between objects.

```java
interface Observer {
    void update(String message);
}

class Subject {
    private List<Observer> observers = new ArrayList<>();
    
    public void addObserver(Observer observer) {
        observers.add(observer);
    }
    
    public void notifyObservers(String message) {
        for (Observer observer : observers) {
            observer.update(message);
        }
    }
}
```

---

## Spring Framework

### 46. What is Spring Framework?
**Answer**: Spring is a comprehensive framework for enterprise Java development providing:
- **Dependency Injection**: Inversion of Control container
- **AOP**: Aspect-Oriented Programming
- **Data Access**: JDBC, ORM integration
- **Web**: MVC framework
- **Security**: Authentication and authorization

### 47. What is Dependency Injection?
**Answer**: DI is a design pattern where objects receive dependencies from external sources rather than creating them.

```java
// Without DI
public class OrderService {
    private PaymentService paymentService = new PaymentService(); // Tight coupling
}

// With DI
@Service
public class OrderService {
    private final PaymentService paymentService;
    
    @Autowired
    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService; // Loose coupling
    }
}
```

### 48. What are Spring Bean scopes?
**Answer**:
- **Singleton**: One instance per Spring container (default)
- **Prototype**: New instance for each request
- **Request**: One instance per HTTP request
- **Session**: One instance per HTTP session
- **Application**: One instance per ServletContext

### 49. What is Spring Boot?
**Answer**: Spring Boot provides auto-configuration and starter dependencies to simplify Spring application development.

**Key Features**:
- Auto-configuration
- Embedded servers (Tomcat, Jetty)
- Production-ready features (metrics, health checks)
- No XML configuration required

---

## Advanced Topics

### 50. What is Reflection in Java?
**Answer**: Reflection allows examining and modifying classes, methods, and fields at runtime.

```java
Class<?> clazz = String.class;

// Get methods
Method[] methods = clazz.getMethods();

// Get fields
Field[] fields = clazz.getDeclaredFields();

// Create instance
Constructor<?> constructor = clazz.getConstructor(String.class);
Object instance = constructor.newInstance("Hello");

// Invoke method
Method lengthMethod = clazz.getMethod("length");
int length = (Integer) lengthMethod.invoke(instance);
```

### 51. What are Annotations in Java?
**Answer**: Annotations provide metadata about code elements.

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface MyAnnotation {
    String value() default "";
    int priority() default 1;
}

public class Example {
    @MyAnnotation(value = "test", priority = 5)
    public void annotatedMethod() {
        // Method implementation
    }
}
```

### 52. What is Serialization?
**Answer**: Serialization converts objects into byte streams for storage or transmission.

```java
// Serializable class
public class Person implements Serializable {
    private static final long serialVersionUID = 1L;
    private String name;
    private transient String password; // Not serialized
    
    // Constructor, getters, setters
}

// Serialization
ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("person.ser"));
oos.writeObject(person);

// Deserialization
ObjectInputStream ois = new ObjectInputStream(new FileInputStream("person.ser"));
Person deserializedPerson = (Person) ois.readObject();
```

### 53. What is the difference between JIT and AOT compilation?
**Answer**:
- **JIT (Just-In-Time)**: Compiles bytecode to native code at runtime
- **AOT (Ahead-Of-Time)**: Compiles source code to native code before runtime

### 54. What are the new features in Java 11, 17, and 21?
**Answer**:

**Java 11**:
- Local variable syntax for lambda parameters
- HTTP Client API
- String methods (isBlank(), lines(), strip())

**Java 17**:
- Sealed classes
- Pattern matching for instanceof
- Records
- Text blocks

**Java 21**:
- Virtual threads
- Pattern matching for switch
- Sequenced collections

### 55. What is the difference between fail-fast and fail-safe iterators?
**Answer**:
- **Fail-fast**: Throws ConcurrentModificationException if collection is modified during iteration (ArrayList, HashMap)
- **Fail-safe**: Creates copy of collection, doesn't throw exception (CopyOnWriteArrayList, ConcurrentHashMap)

---

This comprehensive guide covers the most important Java interview questions across all experience levels. Practice these concepts with code examples to strengthen your understanding and interview preparation.