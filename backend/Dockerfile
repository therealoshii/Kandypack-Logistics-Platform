# Build the Maven package
# Using Maven 3.9 image with JDK 17 to compile the Java files
# Package them to a .jar file 
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Run the Spring Boot application
# Copies .far from stage 1, exposes port 8080 and runs the app
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
