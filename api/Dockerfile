FROM eclipse-temurin:23-jre-noble
WORKDIR /srv/joker
COPY target/joker-api.jar ./joker-api.jar
RUN mkdir -p /srv/uploads && chown 10001:10001 /srv/uploads
USER 10001:10001
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/srv/joker/joker-api.jar"]
