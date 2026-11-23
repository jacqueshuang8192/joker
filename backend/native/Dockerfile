FROM almalinux:8 AS build
RUN dnf -qy --enablerepo=powertools --setopt=install_weak_deps=False install gcc-c++ make zlib-devel libmemcached-devel mariadb-connector-c-devel && dnf clean all
# ACE 6.3.0 headers for the archived x86-64 library. Verify the upstream archive before extraction.
ADD https://codeload.github.com/DOCGroup/ACE_TAO/tar.gz/4d4eee0c19b81f9b1f755acbceea41580a8138a9 /tmp/ace.tgz
RUN echo "c85a0ef7f9dfcc192fea7c02d98994739e8f240ca471ee2184a6fcac100bf3b4  /tmp/ace.tgz" | sha256sum -c - && mkdir -p /sdk && \
    tar xzf /tmp/ace.tgz --strip-components=2 -C /sdk ACE_TAO-4d4eee0c19b81f9b1f755acbceea41580a8138a9/ACE/ace && \
    echo '#include "ace/config-linux.h"' > /sdk/ace/config.h && rm /tmp/ace.tgz
COPY backend/native/prebuilt/douniu/bin/libACE.so.6.4.8 /sdk/libACE.so.6.3.0
WORKDIR /work
COPY backend/native/services/hall/ /work/CCHallServer/
COPY backend/native/services/user/ /work/CCUserServer/
COPY backend/native/services/data/ /work/CCMDataServerNew/
COPY backend/native/services/gold/ /work/CCGoldUpdateServer/
COPY backend/native/services/alloc/ /work/NewAllocServer/
COPY backend/native/vendor/hiredis/ /work/hiredis/
COPY backend/native/shared/panel_redis.h backend/native/vendor/hiredis/hiredis.h /usr/local/include/
COPY backend/native/build.sh /usr/local/bin/build-services
RUN bash /usr/local/bin/build-services

FROM almalinux:8
RUN dnf -y --setopt=install_weak_deps=False install compat-openssl10 libmemcached-libs libstdc++ mariadb-connector-c python3.12 procps-ng && dnf clean all && \
    ln -s /usr/bin/python3.12 /usr/local/bin/python3
WORKDIR /srv
COPY backend/native/prebuilt/ /srv/
COPY --from=build /out/ /srv/
COPY backend/native/container/run.py /usr/local/bin/game-run
RUN set -eu; for exe in hall/bin/CCHallServer user/bin/UserServerSHM data/bin/CCMemDataServer alloc/bin/AllocRoomServer douniu/bin/DouNiuServerGroup_new gold/bin/CCGoldUpdateServer; do \
      dir=$(dirname "$exe"); chmod 755 "$exe"; mkdir -p "$dir/log" "$dir/../log" "$dir/../conf"; \
    done; ln -s libACE.so.6.4.8 douniu/bin/libACE.so.6.4.0; ln -s ../../douniu/bin/libACE.so.6.4.8 alloc/bin/libACE.so.6.3.0; \
    for exe in hall/bin/CCHallServer user/bin/UserServerSHM data/bin/CCMemDataServer alloc/bin/AllocRoomServer douniu/bin/DouNiuServerGroup_new gold/bin/CCGoldUpdateServer; do \
      libs=$(LD_LIBRARY_PATH="/srv/$(dirname "$exe")" ldd "$exe"); echo "$libs"; case "$libs" in *"not found"*) exit 1;; esac; \
    done; chown -R 10001:10001 /srv
COPY backend/native/container/douniu_redis.py /usr/local/bin/douniu_redis.py
COPY backend/native/container/health.py /usr/local/bin/check-port
# 1Panel 初始化只从镜像读取模板，凭据在部署时由面板传入。
COPY tools/prepare.py tools/configure.py /opt/joker/panel/
COPY config/*.in /opt/joker/panel/config/
HEALTHCHECK --interval=10s --timeout=3s --start-period=15s --retries=6 CMD ["python3", "/usr/local/bin/check-port"]
USER 10001:10001
ENTRYPOINT ["python3", "/usr/local/bin/game-run"]
