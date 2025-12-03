# Spring Boot Introduction

## What is Spring Boot?

Spring Boot is a framework that makes it easy to create stand-alone, production-grade Spring-based applications. It takes an opinionated view of the Spring platform and third-party libraries to get you started with minimum configuration.

## Key Features

1. **Auto Configuration** - Automatically configures your application based on dependencies
2. **Embedded Servers** - No need to deploy WAR files, runs with embedded Tomcat/Jetty
3. **Starter Dependencies** - Pre-configured dependency sets
4. **Production Ready** - Built-in monitoring, health checks, metrics
5. **No Code Generation** - No XML configuration required

## Why Spring Boot?

- **Rapid Development** - Get started quickly with minimal setup
- **Convention over Configuration** - Sensible defaults reduce boilerplate
- **Microservices Ready** - Perfect for building microservices
- **Production Ready** - Built-in features for monitoring and management

## Spring Boot vs Spring Framework

| Spring Framework | Spring Boot |
|------------------|-------------|
| Requires manual configuration | Auto-configuration |
| Need external server | Embedded server |
| More boilerplate code | Minimal code |
| XML/Java configuration | Annotation-based |

## Prerequisites

- Java 8 or higher
- Maven or Gradle
- IDE (IntelliJ IDEA, Eclipse, VS Code)

## First Spring Boot Application

```java
@SpringBootApplication
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}
```

### @SpringBootApplication Annotation

This is a convenience annotation that combines:
- `@Configuration` - Marks class as configuration class
- `@EnableAutoConfiguration` - Enables auto-configuration
- `@ComponentScan` - Enables component scanning

## Project Structure

```
src/
├── main/
│   ├── java/
│   │   └── com/example/demo/
│   │       └── DemoApplication.java
│   └── resources/
│       ├── application.properties
│       └── static/
│       └── templates/
└── test/
    └── java/
```

## Next Steps

1. Learn about Spring Boot Starters
2. Understand Auto Configuration
3. Explore different project structures
4. Practice with simple REST APIs