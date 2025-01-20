# Use a Debian-based OpenJDK image
FROM openjdk:17-slim as build

# Install Maven using apt-get
RUN apt-get update && apt-get install -y maven

# Set working directory inside the container
WORKDIR /app

# Copy pom.xml and install dependencies
COPY pom.xml ./
RUN mvn dependency:go-offline

# Copy the source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Use OpenJDK for the runtime environment (lighter image)
FROM openjdk:17-slim

# Set working directory inside the container
WORKDIR /app

# Extract the version from pom.xml
ARG VERSION
ENV POM_VERSION=$VERSION

# Define build argument for version and use it directly to set JAR file name
# ARG VERSION
ARG JAR_FILE=target/deadlocktest{$POM_VERSION}.jar

# Copy the built JAR file from the build stage
# COPY --from=build /app/$JAR_FILE /app/deadlocktest.jar
# Copy the built JAR file from the build stage with version
COPY --from=build /app/$JAR_FILE /app/deadlocktest.jar

# Expose the port the application will run on
EXPOSE 8081

# Run the application
ENTRYPOINT ["java", "-jar", "deadlocktest.jar"]