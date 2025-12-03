# Spring Boot Project Setup

## Creating a Spring Boot Project

### Method 1: Spring Initializr (Recommended)
Visit https://start.spring.io/
- Choose Maven/Gradle
- Select Java version
- Add dependencies
- Generate and download

### Method 2: IDE Integration
Most IDEs have Spring Boot project templates built-in.

### Method 3: Manual Setup

## Maven Configuration (pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>
    
    <groupId>com.example</groupId>
    <artifactId>demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>demo</name>
    <description>Demo project for Spring Boot</description>
    
    <properties>
        <java.version>17</java.version>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

## Gradle Configuration (build.gradle)

```gradle
plugins {
    id 'org.springframework.boot' version '3.2.0'
    id 'io.spring.dependency-management' version '1.1.4'
    id 'java'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '17'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

tasks.named('test') {
    useJUnitPlatform()
}
```

## Application Properties

### application.properties
```properties
# Server Configuration
server.port=8080
server.servlet.context-path=/api

# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/mydb
spring.datasource.username=root
spring.datasource.password=password

# Logging Configuration
logging.level.com.example=DEBUG
logging.file.name=app.log
```

### application.yml (Alternative)
```yaml
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    username: root
    password: password

logging:
  level:
    com.example: DEBUG
  file:
    name: app.log
```

## Profile-based Configuration

### application-dev.properties
```properties
server.port=8081
spring.datasource.url=jdbc:h2:mem:testdb
logging.level.root=DEBUG
```

### application-prod.properties
```properties
server.port=80
spring.datasource.url=jdbc:mysql://prod-server:3306/proddb
logging.level.root=WARN
```

## Running the Application

### Command Line
```bash
# Maven
mvn spring-boot:run

# Gradle
gradle bootRun

# Java JAR
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

### IDE
Right-click on main class and select "Run"

## Environment Variables

```bash
# Set active profile
export SPRING_PROFILES_ACTIVE=dev

# Override properties
export SERVER_PORT=9090
```

## Common Project Structure

```
src/
├── main/
│   ├── java/
│   │   └── com/example/demo/
│   │       ├── DemoApplication.java
│   │       ├── controller/
│   │       ├── service/
│   │       ├── repository/
│   │       ├── model/
│   │       └── config/
│   └── resources/
│       ├── application.properties
│       ├── application-dev.properties
│       ├── application-prod.properties
│       ├── static/
│       └── templates/
└── test/
    └── java/
        └── com/example/demo/
```

## Best Practices

1. **Use Profiles** - Separate configurations for different environments
2. **External Configuration** - Use environment variables for sensitive data
3. **Proper Packaging** - Organize code into logical packages
4. **Version Management** - Use Spring Boot parent for dependency management
5. **Testing Setup** - Include test dependencies from the start