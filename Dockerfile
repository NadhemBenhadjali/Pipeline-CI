FROM openjdk:17
WORKDIR /app

# copy the executable Spring Boot WAR
COPY target/*.war app.war

EXPOSE 8087
ENTRYPOINT ["java","-jar","/app/app.war"]
