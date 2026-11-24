
# Stage 1: Build application
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copy Maven configuration first for dependency caching
COPY pom.xml .

# Download dependencies
RUN mvn -B dependency:go-offline

# Copy source code
COPY src ./src

# Build application
RUN mvn -B -DskipTests package

# Stage 2: Lightweight runtime
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -S app && adduser -S app -G app

# Copy only the executable JAR
COPY --from=builder /app/target/*.jar app.jar

# Set application ownership
RUN chown app:app app.jar

USER app

# Application port
EXPOSE 2330

# Memory-efficient JVM settings
ENV JAVA_OPTS="-XX:+UseSerialGC -XX:MaxRAMPercentage=60.0 -XX:InitialRAMPercentage=20.0 -XX:ActiveProcessorCount=2"

# Start application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

