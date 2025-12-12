FROM openjdk:17-slim

LABEL maintainer="LifeFlow Team"
LABEL description="Request & Emergency Service for LifeFlow Blood Donation System"

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy JAR file
COPY target/lifeflow-request-service-1.0.0.jar app.jar

# Expose port
EXPOSE 3004

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3004/actuator/health || exit 1

# JVM options
ENV JAVA_OPTS="-Xmx768m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# Run application
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]
