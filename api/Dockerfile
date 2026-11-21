FROM tomcat:9-jdk8-temurin
COPY target/hbiInterface.war /tmp/app.war
RUN mkdir -p webapps/hbiInterface && cd webapps/hbiInterface && jar xf /tmp/app.war && rm /tmp/app.war && \
    test -e WEB-INF/classes/com/hbi/controller/player/PlayerController.class && test ! -e WEB-INF/classes/config.properties && \
    mkdir -p /srv/uploads && chown -R 10001:10001 /srv/uploads /usr/local/tomcat
USER 10001:10001
CMD ["catalina.sh", "run"]
