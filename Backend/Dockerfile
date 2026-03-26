# Étape 1 : Build de l’application
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Copie tout le projet
COPY . .
# Corrige les fins de ligne et les droits d'exécution de gradlew
RUN apt-get update && apt-get install -y dos2unix \
	&& dos2unix gradlew \
	&& chmod +x gradlew
RUN ./gradlew bootJar

# Étape 2 : Image finale pour exécution
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
