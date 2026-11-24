FROM eclipse-temurin:23-jre-noble
COPY config/api.properties.in config/data.xml.in config/gold-example.xml.in /opt/joker/panel/config/
WORKDIR /srv/joker
COPY backend/game-java/target/joker-game-java.jar .
USER 10001:10001
ENV DOUNIU_READY_FILE=/tmp/joker-douniu-alloc.ready
# 联网牛牛收到 alloc 注册回执后才通过健康检查。
HEALTHCHECK --interval=15s --timeout=3s --start-period=20s --retries=4 CMD bash -ec 'case "${GAME_ROLE:-gateway}" in gateway) p=8090;; rooms) for p in 11603 7500 4701 4700; do (exec 3<>/dev/tcp/127.0.0.1/$p) || exit 1; done; p=${DOUNIU_PORT:-13600};; data) p=6001;; gold) p=6005;; douniu) p=${DOUNIU_PORT:-13600}; if [[ ${DOUNIU_DATA_ENABLED:-1} != 0 ]]; then test -s "$DOUNIU_READY_FILE" || exit 1; fi;; *) exit 1;; esac; exec 3<>/dev/tcp/127.0.0.1/${GAME_PORT:-$p}'
ENTRYPOINT ["java", "-jar", "joker-game-java.jar"]
