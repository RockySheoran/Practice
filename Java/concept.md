# Java Concepts: Zero to Advanced

## Table of Contents
1. [Java Basics](#java-basics)
2. [Object-Oriented Programming](#object-oriented-programming)
3. [Data Types and Variables](#data-types-and-variables)
4. [Control Structures](#control-structures)
5. [Arrays and Collections](#arrays-and-collections)
6. [Exception Handling](#exception-handling)
7. [Multithreading](#multithreading)
8. [File I/O](#file-io)
9. [Generics](#generics)
10. [Lambda Expressions](#lambda-expressions)
11. [Stream API](#stream-api)
12. [Design Patterns](#design-patterns)
13. [Advanced Topics](#advanced-topics)

---

## Java Basics

### What is Java?
Java is a high-level, object-oriented programming language developed by Sun Microsystems (now Oracle). It follows the principle "Write Once, Run Anywhere" (WORA).

**Key Features:**
- Platform Independent
- Object-Oriented
- Secure
- Robust
- Multithreaded

### JVM, JRE, and JDK
- **JVM (Java Virtual Machine)**: Runtime environment that executes Java bytecode
- **JRE (Java Runtime Environment)**: JVM + libraries needed to run Java applications
- **JDK (Java Development Kit)**: JRE + development tools (compiler, debugger)

### Hello World Program
```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

### Java Program Structure
```java
// Package declaration (optional)
package com.example;

// Import statements
import java.util.Scanner;

// Class declaration
public class MyClass {
    // Class variables
    static int classVar = 10;
    
    // Instance variables
    int instanceVar = 20;
    
    // Constructor
    public MyClass() {
        // Initialization code
    }
    
    // Methods
    public void myMethod() {
        // Method body
    }
    
    // Main method
    public static void main(String[] args) {
        // Program entry point
    }
}
```

---

## Data Types and Variables

### Primitive Data Types
```java
// Integer types
byte b = 127;           // 8-bit, -128 to 127
short s = 32767;        // 16-bit, -32,768 to 32,767
int i = 2147483647;     // 32-bit, -2^31 to 2^31-1
long l = 9223372036854775807L; // 64-bit, -2^63 to 2^63-1

// Floating-point types
float f = 3.14f;        // 32-bit IEEE 754
double d = 3.14159;     // 64-bit IEEE 754

// Character type
char c = 'A';           // 16-bit Unicode character

// Boolean type
boolean flag = true;    // true or false
```

### Reference Data Types
```java
// String
String name = "John Doe";

// Arrays
int[] numbers = {1, 2, 3, 4, 5};
String[] names = new String[10];

// Objects
Scanner scanner = new Scanner(System.in);
```

### Variable Types
```java
public class VariableTypes {
    // Class/Static variables
    static int classVariable = 100;
    
    // Instance variables
    int instanceVariable = 200;
    
    public void method() {
        // Local variables
        int localVariable = 300;
    }
}
```

---

## Control Structures

### Conditional Statements
```java
// if-else
int age = 18;
if (age >= 18) {
    System.out.println("Adult");
} else if (age >= 13) {
    System.out.println("Teenager");
} else {
    System.out.println("Child");
}

// switch
int day = 3;
switch (day) {
    case 1:
        System.out.println("Monday");
        break;
    case 2:
        System.out.println("Tuesday");
        break;
    default:
        System.out.println("Other day");
}

// Ternary operator
String result = (age >= 18) ? "Adult" : "Minor";
```

### Loops
```java
// for loop
for (int i = 0; i < 5; i++) {
    System.out.println("Count: " + i);
}

// Enhanced for loop (for-each)
int[] array = {1, 2, 3, 4, 5};
for (int num : array) {
    System.out.println(num);
}

// while loop
int count = 0;
while (count < 5) {
    System.out.println("Count: " + count);
    count++;
}

// do-while loop
int i = 0;
do {
    System.out.println("Value: " + i);
    i++;
} while (i < 3);
```

---

## Object-Oriented Programming

### Classes and Objects
```java
public class Car {
    // Instance variables (attributes)
    private String brand;
    private String model;
    private int year;
    
    // Constructor
    public Car(String brand, String model, int year) {
        this.brand = brand;
        this.model = model;
        this.year = year;
    }
    
    // Methods (behavior)
    public void start() {
        System.out.println("Car is starting...");
    }
    
    public void displayInfo() {
        System.out.println(year + " " + brand + " " + model);
    }
    
    // Getters and Setters
    public String getBrand() {
        return brand;
    }
    
    public void setBrand(String brand) {
        this.brand = brand;
    }
}

// Creating objects
Car myCar = new Car("Toyota", "Camry", 2022);
myCar.start();
myCar.displayInfo();
```

### Encapsulation
```java
public class BankAccount {
    private double balance;  // Private field
    
    public BankAccount(double initialBalance) {
        this.balance = initialBalance;
    }
    
    // Public methods to access private fields
    public double getBalance() {
        return balance;
    }
    
    public void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
        }
    }
    
    public boolean withdraw(double amount) {
        if (amount > 0 && amount <= balance) {
            balance -= amount;
            return true;
        }
        return false;
    }
}
```

### Inheritance
```java
// Parent class
public class Animal {
    protected String name;
    protected int age;
    
    public Animal(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    public void eat() {
        System.out.println(name + " is eating");
    }
    
    public void sleep() {
        System.out.println(name + " is sleeping");
    }
}

// Child class
public class Dog extends Animal {
    private String breed;
    
    public Dog(String name, int age, String breed) {
        super(name, age);  // Call parent constructor
        this.breed = breed;
    }
    
    public void bark() {
        System.out.println(name + " is barking");
    }
    
    @Override
    public void eat() {
        System.out.println(name + " the dog is eating dog food");
    }
}
```

### Polymorphism
```java
// Method Overloading (Compile-time polymorphism)
public class Calculator {
    public int add(int a, int b) {
        return a + b;
    }
    
    public double add(double a, double b) {
        return a + b;
    }
    
    public int add(int a, int b, int c) {
        return a + b + c;
    }
}

// Method Overriding (Runtime polymorphism)
public class Shape {
    public void draw() {
        System.out.println("Drawing a shape");
    }
}

public class Circle extends Shape {
    @Override
    public void draw() {
        System.out.println("Drawing a circle");
    }
}

public class Rectangle extends Shape {
    @Override
    public void draw() {
        System.out.println("Drawing a rectangle");
    }
}

// Usage
Shape[] shapes = {new Circle(), new Rectangle()};
for (Shape shape : shapes) {
    shape.draw();  // Calls appropriate overridden method
}
```

### Abstraction
```java
// Abstract class
public abstract class Vehicle {
    protected String brand;
    
    public Vehicle(String brand) {
        this.brand = brand;
    }
    
    // Abstract method (must be implemented by subclasses)
    public abstract void start();
    
    // Concrete method
    public void stop() {
        System.out.println("Vehicle stopped");
    }
}

public class Motorcycle extends Vehicle {
    public Motorcycle(String brand) {
        super(brand);
    }
    
    @Override
    public void start() {
        System.out.println("Motorcycle started with kick");
    }
}

// Interface
public interface Drawable {
    void draw();  // Abstract method (public by default)
    
    default void print() {  // Default method (Java 8+)
        System.out.println("Printing...");
    }
}

public class Square implements Drawable {
    @Override
    public void draw() {
        System.out.println("Drawing a square");
    }
}
```

---

## Arrays and Collections

### Arrays
```java
// Array declaration and initialization
int[] numbers = new int[5];  // Creates array of size 5
int[] values = {1, 2, 3, 4, 5};  // Initialize with values

// Multidimensional arrays
int[][] matrix = new int[3][3];
int[][] grid = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};

// Array operations
System.out.println("Length: " + numbers.length);
for (int i = 0; i < numbers.length; i++) {
    numbers[i] = i * 2;
}

// Enhanced for loop
for (int num : values) {
    System.out.println(num);
}
```

### Collections Framework
```java
import java.util.*;

// List (ArrayList)
List<String> list = new ArrayList<>();
list.add("Apple");
list.add("Banana");
list.add("Cherry");
list.remove("Banana");
System.out.println("Size: " + list.size());

// Set (HashSet)
Set<Integer> set = new HashSet<>();
set.add(1);
set.add(2);
set.add(1);  // Duplicate, won't be added
System.out.println("Set size: " + set.size());  // Output: 2

// Map (HashMap)
Map<String, Integer> map = new HashMap<>();
map.put("John", 25);
map.put("Jane", 30);
map.put("Bob", 35);

for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + ": " + entry.getValue());
}

// Queue (LinkedList)
Queue<String> queue = new LinkedList<>();
queue.offer("First");
queue.offer("Second");
String first = queue.poll();  // Removes and returns first element

// Stack
Stack<Integer> stack = new Stack<>();
stack.push(10);
stack.push(20);
int top = stack.pop();  // Removes and returns top element
```

---

## Exception Handling

### Try-Catch-Finally
```java
public class ExceptionExample {
    public static void main(String[] args) {
        try {
            int result = divide(10, 0);
            System.out.println("Result: " + result);
        } catch (ArithmeticException e) {
            System.out.println("Error: " + e.getMessage());
        } catch (Exception e) {
            System.out.println("General error: " + e.getMessage());
        } finally {
            System.out.println("This always executes");
        }
    }
    
    public static int divide(int a, int b) throws ArithmeticException {
        if (b == 0) {
            throw new ArithmeticException("Division by zero");
        }
        return a / b;
    }
}
```

### Custom Exceptions
```java
// Custom exception class
public class InvalidAgeException extends Exception {
    public InvalidAgeException(String message) {
        super(message);
    }
}

public class Person {
    private int age;
    
    public void setAge(int age) throws InvalidAgeException {
        if (age < 0 || age > 150) {
            throw new InvalidAgeException("Age must be between 0 and 150");
        }
        this.age = age;
    }
}

// Usage
try {
    Person person = new Person();
    person.setAge(-5);
} catch (InvalidAgeException e) {
    System.out.println("Invalid age: " + e.getMessage());
}
```

---

## Multithreading

### Creating Threads
```java
// Method 1: Extending Thread class
public class MyThread extends Thread {
    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            System.out.println("Thread: " + Thread.currentThread().getName() + ", Count: " + i);
            try {
                Thread.sleep(1000);  // Sleep for 1 second
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

// Method 2: Implementing Runnable interface
public class MyRunnable implements Runnable {
    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            System.out.println("Runnable: " + Thread.currentThread().getName() + ", Count: " + i);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

// Usage
public class ThreadExample {
    public static void main(String[] args) {
        // Using Thread class
        MyThread thread1 = new MyThread();
        thread1.start();
        
        // Using Runnable interface
        Thread thread2 = new Thread(new MyRunnable());
        thread2.start();
        
        // Using lambda expression (Java 8+)
        Thread thread3 = new Thread(() -> {
            System.out.println("Lambda thread running");
        });
        thread3.start();
    }
}
```

### Synchronization
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

// Producer-Consumer example
public class ProducerConsumer {
    private final Object lock = new Object();
    private final Queue<Integer> queue = new LinkedList<>();
    private final int MAX_SIZE = 5;
    
    public void produce() throws InterruptedException {
        synchronized (lock) {
            while (queue.size() == MAX_SIZE) {
                lock.wait();  // Wait if queue is full
            }
            queue.offer(1);
            System.out.println("Produced item");
            lock.notifyAll();  // Notify waiting consumers
        }
    }
    
    public void consume() throws InterruptedException {
        synchronized (lock) {
            while (queue.isEmpty()) {
                lock.wait();  // Wait if queue is empty
            }
            queue.poll();
            System.out.println("Consumed item");
            lock.notifyAll();  // Notify waiting producers
        }
    }
}
```

---

## File I/O

### Reading and Writing Files
```java
import java.io.*;
import java.nio.file.*;
import java.util.List;

public class FileIOExample {
    public static void main(String[] args) {
        // Writing to file using FileWriter
        try (FileWriter writer = new FileWriter("output.txt")) {
            writer.write("Hello, World!\n");
            writer.write("Java File I/O Example");
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        // Reading from file using FileReader
        try (FileReader reader = new FileReader("output.txt");
             BufferedReader bufferedReader = new BufferedReader(reader)) {
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                System.out.println(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        // Using NIO (Java 7+)
        try {
            // Write to file
            List<String> lines = List.of("Line 1", "Line 2", "Line 3");
            Files.write(Paths.get("nio-output.txt"), lines);
            
            // Read from file
            List<String> readLines = Files.readAllLines(Paths.get("nio-output.txt"));
            readLines.forEach(System.out::println);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

### Serialization
```java
import java.io.*;

// Serializable class
public class Student implements Serializable {
    private static final long serialVersionUID = 1L;
    private String name;
    private int age;
    private transient String password;  // transient fields are not serialized
    
    public Student(String name, int age, String password) {
        this.name = name;
        this.age = age;
        this.password = password;
    }
    
    // Getters and setters
    public String getName() { return name; }
    public int getAge() { return age; }
}

// Serialization example
public class SerializationExample {
    public static void main(String[] args) {
        Student student = new Student("John", 20, "secret123");
        
        // Serialize object
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("student.ser"))) {
            oos.writeObject(student);
            System.out.println("Object serialized");
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        // Deserialize object
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream("student.ser"))) {
            Student deserializedStudent = (Student) ois.readObject();
            System.out.println("Name: " + deserializedStudent.getName());
            System.out.println("Age: " + deserializedStudent.getAge());
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
}
```

---

## Generics

### Generic Classes and Methods
```java
// Generic class
public class Box<T> {
    private T content;
    
    public void setContent(T content) {
        this.content = content;
    }
    
    public T getContent() {
        return content;
    }
}

// Generic method
public class Utility {
    public static <T> void swap(T[] array, int i, int j) {
        T temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
    
    public static <T extends Comparable<T>> T findMax(T[] array) {
        T max = array[0];
        for (T element : array) {
            if (element.compareTo(max) > 0) {
                max = element;
            }
        }
        return max;
    }
}

// Usage
public class GenericExample {
    public static void main(String[] args) {
        // Generic class usage
        Box<String> stringBox = new Box<>();
        stringBox.setContent("Hello");
        String content = stringBox.getContent();
        
        Box<Integer> intBox = new Box<>();
        intBox.setContent(42);
        Integer number = intBox.getContent();
        
        // Generic method usage
        String[] names = {"Alice", "Bob", "Charlie"};
        Utility.swap(names, 0, 2);
        String maxName = Utility.findMax(names);
    }
}
```

### Wildcards
```java
import java.util.*;

public class WildcardExample {
    // Upper bounded wildcard (? extends T)
    public static double sumOfNumbers(List<? extends Number> numbers) {
        double sum = 0.0;
        for (Number num : numbers) {
            sum += num.doubleValue();
        }
        return sum;
    }
    
    // Lower bounded wildcard (? super T)
    public static void addNumbers(List<? super Integer> numbers) {
        numbers.add(1);
        numbers.add(2);
        numbers.add(3);
    }
    
    // Unbounded wildcard (?)
    public static void printList(List<?> list) {
        for (Object item : list) {
            System.out.println(item);
        }
    }
    
    public static void main(String[] args) {
        List<Integer> integers = Arrays.asList(1, 2, 3, 4, 5);
        List<Double> doubles = Arrays.asList(1.1, 2.2, 3.3);
        
        System.out.println("Sum of integers: " + sumOfNumbers(integers));
        System.out.println("Sum of doubles: " + sumOfNumbers(doubles));
        
        List<Number> numbers = new ArrayList<>();
        addNumbers(numbers);
        printList(numbers);
    }
}
```

---

## Lambda Expressions

### Basic Lambda Syntax
```java
import java.util.*;
import java.util.function.*;

public class LambdaExample {
    public static void main(String[] args) {
        // Traditional approach with anonymous class
        Runnable runnable1 = new Runnable() {
            @Override
            public void run() {
                System.out.println("Running with anonymous class");
            }
        };
        
        // Lambda expression
        Runnable runnable2 = () -> System.out.println("Running with lambda");
        
        // Lambda with parameters
        Comparator<String> comparator = (s1, s2) -> s1.compareTo(s2);
        
        // Lambda with multiple statements
        Consumer<String> printer = (String s) -> {
            System.out.println("Processing: " + s);
            System.out.println("Length: " + s.length());
        };
        
        // Using lambdas with collections
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David");
        
        // forEach with lambda
        names.forEach(name -> System.out.println("Hello, " + name));
        
        // Sorting with lambda
        names.sort((a, b) -> a.length() - b.length());
        
        // Filtering with lambda
        names.stream()
             .filter(name -> name.startsWith("A"))
             .forEach(System.out::println);
    }
}
```

### Functional Interfaces
```java
import java.util.function.*;

public class FunctionalInterfaceExample {
    public static void main(String[] args) {
        // Predicate<T> - takes T, returns boolean
        Predicate<Integer> isEven = n -> n % 2 == 0;
        System.out.println("4 is even: " + isEven.test(4));
        
        // Function<T, R> - takes T, returns R
        Function<String, Integer> stringLength = s -> s.length();
        System.out.println("Length of 'Hello': " + stringLength.apply("Hello"));
        
        // Consumer<T> - takes T, returns void
        Consumer<String> printer = s -> System.out.println("Value: " + s);
        printer.accept("Test");
        
        // Supplier<T> - takes nothing, returns T
        Supplier<Double> randomSupplier = () -> Math.random();
        System.out.println("Random number: " + randomSupplier.get());
        
        // BiFunction<T, U, R> - takes T and U, returns R
        BiFunction<Integer, Integer, Integer> adder = (a, b) -> a + b;
        System.out.println("5 + 3 = " + adder.apply(5, 3));
        
        // Custom functional interface
        MathOperation multiply = (a, b) -> a * b;
        System.out.println("4 * 5 = " + multiply.operate(4, 5));
    }
}

@FunctionalInterface
interface MathOperation {
    int operate(int a, int b);
}
```

---

## Stream API

### Stream Operations
```java
import java.util.*;
import java.util.stream.*;

public class StreamExample {
    public static void main(String[] args) {
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
        
        // Filter and collect
        List<Integer> evenNumbers = numbers.stream()
                                          .filter(n -> n % 2 == 0)
                                          .collect(Collectors.toList());
        System.out.println("Even numbers: " + evenNumbers);
        
        // Map and reduce
        int sum = numbers.stream()
                        .map(n -> n * n)  // Square each number
                        .reduce(0, Integer::sum);  // Sum all squares
        System.out.println("Sum of squares: " + sum);
        
        // Find operations
        Optional<Integer> firstEven = numbers.stream()
                                           .filter(n -> n % 2 == 0)
                                           .findFirst();
        firstEven.ifPresent(n -> System.out.println("First even: " + n));
        
        // Sorting and limiting
        List<Integer> top3Odds = numbers.stream()
                                       .filter(n -> n % 2 == 1)
                                       .sorted(Comparator.reverseOrder())
                                       .limit(3)
                                       .collect(Collectors.toList());
        System.out.println("Top 3 odd numbers: " + top3Odds);
        
        // Grouping
        List<String> words = Arrays.asList("apple", "banana", "cherry", "apricot", "blueberry");
        Map<Character, List<String>> groupedByFirstLetter = words.stream()
                .collect(Collectors.groupingBy(word -> word.charAt(0)));
        System.out.println("Grouped by first letter: " + groupedByFirstLetter);
        
        // Parallel streams
        long count = numbers.parallelStream()
                           .filter(n -> n > 5)
                           .count();
        System.out.println("Numbers greater than 5: " + count);
    }
}
```

### Advanced Stream Operations
```java
import java.util.*;
import java.util.stream.*;

public class AdvancedStreamExample {
    public static void main(String[] args) {
        List<Person> people = Arrays.asList(
            new Person("Alice", 25, "Engineer"),
            new Person("Bob", 30, "Manager"),
            new Person("Charlie", 35, "Engineer"),
            new Person("Diana", 28, "Designer"),
            new Person("Eve", 32, "Manager")
        );
        
        // Complex filtering and mapping
        List<String> engineerNames = people.stream()
                .filter(p -> p.getProfession().equals("Engineer"))
                .map(Person::getName)
                .collect(Collectors.toList());
        System.out.println("Engineers: " + engineerNames);
        
        // Grouping by profession
        Map<String, List<Person>> byProfession = people.stream()
                .collect(Collectors.groupingBy(Person::getProfession));
        
        // Average age by profession
        Map<String, Double> avgAgeByProfession = people.stream()
                .collect(Collectors.groupingBy(
                    Person::getProfession,
                    Collectors.averagingInt(Person::getAge)
                ));
        System.out.println("Average age by profession: " + avgAgeByProfession);
        
        // FlatMap example
        List<List<String>> listOfLists = Arrays.asList(
            Arrays.asList("a", "b"),
            Arrays.asList("c", "d"),
            Arrays.asList("e", "f")
        );
        
        List<String> flatList = listOfLists.stream()
                .flatMap(List::stream)
                .collect(Collectors.toList());
        System.out.println("Flattened list: " + flatList);
        
        // Custom collector
        String names = people.stream()
                .map(Person::getName)
                .collect(Collectors.joining(", ", "[", "]"));
        System.out.println("All names: " + names);
    }
}

class Person {
    private String name;
    private int age;
    private String profession;
    
    public Person(String name, int age, String profession) {
        this.name = name;
        this.age = age;
        this.profession = profession;
    }
    
    // Getters
    public String getName() { return name; }
    public int getAge() { return age; }
    public String getProfession() { return profession; }
}
```

---

## Design Patterns

### Singleton Pattern
```java
// Thread-safe Singleton using enum
public enum SingletonEnum {
    INSTANCE;
    
    public void doSomething() {
        System.out.println("Doing something...");
    }
}

// Traditional Singleton with lazy initialization
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

### Factory Pattern
```java
// Product interface
interface Shape {
    void draw();
}

// Concrete products
class Circle implements Shape {
    @Override
    public void draw() {
        System.out.println("Drawing Circle");
    }
}

class Rectangle implements Shape {
    @Override
    public void draw() {
        System.out.println("Drawing Rectangle");
    }
}

// Factory class
class ShapeFactory {
    public static Shape createShape(String shapeType) {
        switch (shapeType.toLowerCase()) {
            case "circle":
                return new Circle();
            case "rectangle":
                return new Rectangle();
            default:
                throw new IllegalArgumentException("Unknown shape: " + shapeType);
        }
    }
}

// Usage
public class FactoryPatternExample {
    public static void main(String[] args) {
        Shape circle = ShapeFactory.createShape("circle");
        Shape rectangle = ShapeFactory.createShape("rectangle");
        
        circle.draw();
        rectangle.draw();
    }
}
```

### Observer Pattern
```java
import java.util.*;

// Observer interface
interface Observer {
    void update(String message);
}

// Subject interface
interface Subject {
    void addObserver(Observer observer);
    void removeObserver(Observer observer);
    void notifyObservers(String message);
}

// Concrete subject
class NewsAgency implements Subject {
    private List<Observer> observers = new ArrayList<>();
    private String news;
    
    @Override
    public void addObserver(Observer observer) {
        observers.add(observer);
    }
    
    @Override
    public void removeObserver(Observer observer) {
        observers.remove(observer);
    }
    
    @Override
    public void notifyObservers(String message) {
        for (Observer observer : observers) {
            observer.update(message);
        }
    }
    
    public void setNews(String news) {
        this.news = news;
        notifyObservers(news);
    }
}

// Concrete observer
class NewsChannel implements Observer {
    private String name;
    
    public NewsChannel(String name) {
        this.name = name;
    }
    
    @Override
    public void update(String message) {
        System.out.println(name + " received news: " + message);
    }
}

// Usage
public class ObserverPatternExample {
    public static void main(String[] args) {
        NewsAgency agency = new NewsAgency();
        
        NewsChannel cnn = new NewsChannel("CNN");
        NewsChannel bbc = new NewsChannel("BBC");
        
        agency.addObserver(cnn);
        agency.addObserver(bbc);
        
        agency.setNews("Breaking: New Java version released!");
    }
}
```

---

## Advanced Topics

### Reflection
```java
import java.lang.reflect.*;

public class ReflectionExample {
    private String name = "John";
    private int age = 25;
    
    public ReflectionExample() {}
    
    public ReflectionExample(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    public void displayInfo() {
        System.out.println("Name: " + name + ", Age: " + age);
    }
    
    private void secretMethod() {
        System.out.println("This is a private method");
    }
    
    public static void main(String[] args) throws Exception {
        // Get class information
        Class<?> clazz = ReflectionExample.class;
        System.out.println("Class name: " + clazz.getName());
        
        // Create instance using reflection
        Constructor<?> constructor = clazz.getConstructor(String.class, int.class);
        Object instance = constructor.newInstance("Alice", 30);
        
        // Get and invoke methods
        Method displayMethod = clazz.getMethod("displayInfo");
        displayMethod.invoke(instance);
        
        // Access private method
        Method secretMethod = clazz.getDeclaredMethod("secretMethod");
        secretMethod.setAccessible(true);
        secretMethod.invoke(instance);
        
        // Access and modify fields
        Field nameField = clazz.getDeclaredField("name");
        nameField.setAccessible(true);
        nameField.set(instance, "Bob");
        
        displayMethod.invoke(instance);
    }
}
```

### Annotations
```java
import java.lang.annotation.*;
import java.lang.reflect.Method;

// Custom annotation
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@interface MyAnnotation {
    String value() default "default";
    int priority() default 1;
}

public class AnnotationExample {
    @MyAnnotation(value = "important", priority = 5)
    public void importantMethod() {
        System.out.println("This is an important method");
    }
    
    @MyAnnotation
    public void normalMethod() {
        System.out.println("This is a normal method");
    }
    
    public static void main(String[] args) throws Exception {
        Class<?> clazz = AnnotationExample.class;
        AnnotationExample instance = new AnnotationExample();
        
        for (Method method : clazz.getDeclaredMethods()) {
            if (method.isAnnotationPresent(MyAnnotation.class)) {
                MyAnnotation annotation = method.getAnnotation(MyAnnotation.class);
                System.out.println("Method: " + method.getName());
                System.out.println("Value: " + annotation.value());
                System.out.println("Priority: " + annotation.priority());
                method.invoke(instance);
                System.out.println();
            }
        }
    }
}
```

### Enum Advanced Usage
```java
public enum Planet {
    MERCURY(3.303e+23, 2.4397e6),
    VENUS(4.869e+24, 6.0518e6),
    EARTH(5.976e+24, 6.37814e6),
    MARS(6.421e+23, 3.3972e6);
    
    private final double mass;   // in kilograms
    private final double radius; // in meters
    
    Planet(double mass, double radius) {
        this.mass = mass;
        this.radius = radius;
    }
    
    public double mass() { return mass; }
    public double radius() { return radius; }
    
    // Universal gravitational constant
    public static final double G = 6.67300E-11;
    
    public double surfaceGravity() {
        return G * mass / (radius * radius);
    }
    
    public double surfaceWeight(double otherMass) {
        return otherMass * surfaceGravity();
    }
    
    public static void main(String[] args) {
        double earthWeight = 75; // kg
        double mass = earthWeight / EARTH.surfaceGravity();
        
        for (Planet p : Planet.values()) {
            System.out.printf("Your weight on %s is %f%n",
                            p, p.surfaceWeight(mass));
        }
    }
}
```

---

This comprehensive guide covers Java concepts from basics to advanced topics. Each section includes practical code examples and explanations to help you understand and implement these concepts in real-world scenarios.