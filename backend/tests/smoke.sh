#!/usr/bin/env bash
# Run only on the disposable CI runner, with its dedicated Compose project.
set -euo pipefail
repo=$(cd "$(dirname "$0")/../.." && pwd)
stage=$(mktemp -d)
project="smoke-${GITHUB_RUN_ID:?}-${GITHUB_RUN_ATTEMPT:?}"
export PANEL_NETWORK="$project-panel"
export CI_DB_PASSWORD="$(python3 -c 'import secrets; print(secrets.token_hex(12) + "&x")')"
export CI_CACHE_PASSWORD="$(python3 -c 'import secrets; print(secrets.token_hex(18) + "%!")')"
export CI_GAME_REDIS_PASSWORD="$(python3 -c 'import secrets; print(secrets.token_hex(20) + " %&")')"
export CI_MONGO_PASSWORD="$(python3 -c 'import secrets; print(secrets.token_hex(12) + "@")')"
infra=(docker compose -p "$project-infra" -f "$repo/backend/tests/ci-services.yml")
dc=(docker compose -p "$project" -f docker-compose.yml -f local.yml --profile gold)
cleanup() {
  "${dc[@]}" down -v --remove-orphans >/dev/null
  "${infra[@]}" down -v --remove-orphans >/dev/null
  docker network rm "$PANEL_NETWORK" >/dev/null
  rm -rf "$stage"
}
cp -R "$repo/config" "$repo/tools" "$repo/panel.ini.example" "$repo/docker-compose.yml" "$stage/"
cd "$stage"
python3 - <<'PYCONFIG'
import configparser, os
s = configparser.ConfigParser(interpolation=None)
s.read("panel.ini.example")
s["deployment"].update(network=os.environ["PANEL_NETWORK"], advertise_ip="127.0.0.1",
                       image_prefix=os.environ["PREFIX"], tag=os.environ["TAG"])
s["mysql"].update(database="joker_ci", user="joker_ci", password=os.environ["CI_DB_PASSWORD"])
s["redis"].update(user="joker_game", password=os.environ["CI_GAME_REDIS_PASSWORD"])
s["mongodb"].update(user="mongo_ci", password=os.environ["CI_MONGO_PASSWORD"])
with open("panel.ini", "w") as f: s.write(f)
PYCONFIG
# Verify that the published native image can initialize 1Panel settings without network access.
PANEL_INI="$(cat panel.ini)" docker run --rm --network none --user 0:0 --tmpfs /settings \
  -e PANEL_INI --entrypoint sh "$PREFIX-native:$TAG" -ec '
    python3 /opt/joker/panel/prepare.py
    test -s /settings/runtime/api.properties && test -s /settings/runtime/hall-server.xml
  '
python3 tools/configure.py
cp runtime/gold-example.xml runtime/gold.xml
cat > local.yml <<'YAML'
services:
  api:
    ports: !reset []
YAML
# 在这一个临时编排中切换牛牛镜像时，保留大厅共享的 API 网络空间。
if [[ ${CHECK_JAVA_VARIANT:-0} == 1 ]]; then
  cat >> local.yml <<'YAML'
    environment:
      JOKER_DOUNIU_RUNTIME: game-java
YAML
fi
"${dc[@]}" config --quiet
docker network create --internal "$PANEL_NETWORK" >/dev/null
trap cleanup EXIT
"${infra[@]}" up -d --wait --wait-timeout 180
"${infra[@]}" exec -T redis redis-cli ACL SETUSER joker_game on ">$CI_GAME_REDIS_PASSWORD" '~*' '&*' '+@all' >/dev/null
"${dc[@]}" up -d --wait --wait-timeout 300 api hall-4700 user data alloc gold
# Hall must have authenticated directly before the prebuilt Douniu game starts.
"${infra[@]}" exec -T redis redis-cli --raw HGET HALLSERVER HALLSERVER1 |
  python3 -c 'import json,sys; assert json.load(sys.stdin)["PORT"] == 4700'
"${dc[@]}" up -d --wait --wait-timeout 300
# Exercise the Douniu binary's loopback endpoint with the same named upstream ACL.
"${dc[@]}" exec -T douniu python3 - <<'PYREDIS'
import socket
with socket.create_connection(("127.0.0.1", 6379), 5) as conn:
    conn.sendall(b"*1\r\n$4\r\nPING\r\n")
    assert conn.makefile("rb").readline() == b"+PONG\r\n"
PYREDIS
# Call the same Mongo client the API uses, inside the deployed JAR's network and configuration.
cat > PanelMongoCheck.java <<'JAVA'
import com.j.joker.utils.MongoUtil;

public class PanelMongoCheck {
    public static void main(String[] args) {
        try (var client = MongoUtil.MongoInstance()) {
            MongoUtil.getCollection().count();
        }
    }
}
JAVA
unzip -q "$repo/backend/api/target/joker-api.jar" 'BOOT-INF/lib/mongodb-driver-*.jar' 'BOOT-INF/lib/bson-*.jar'
javac --release 23 -cp "$repo/backend/api/target/classes:BOOT-INF/lib/*" PanelMongoCheck.java
"${dc[@]}" exec -T api mkdir -p /tmp/panel-probe
"${dc[@]}" cp PanelMongoCheck.class api:/tmp/panel-probe/
"${dc[@]}" exec -T api java -Dloader.path=/tmp/panel-probe -Dloader.main=PanelMongoCheck \
  -cp /srv/joker/joker-api.jar org.springframework.boot.loader.launch.PropertiesLauncher
"${dc[@]}" cp "$repo/backend/api/target/test-classes/com" api:/tmp/panel-probe/
"${dc[@]}" exec -T api java -Dloader.path=/tmp/panel-probe -Dloader.main=com.j.joker.FlexDatabaseCheck \
  -cp /srv/joker/joker-api.jar org.springframework.boot.loader.launch.PropertiesLauncher
"${dc[@]}" exec -T user python3 - <<'PYMC'
import configparser, socket
ini = configparser.ConfigParser()
ini.read("/srv/user/conf/config.ini")
host, port = ini["MEMCACHED"]["SERVER_MC"].split(":")
with socket.create_connection((host, int(port)), 4) as conn:
    conn.sendall(b"set panel-smoke 0 30 2\r\nok\r\nget panel-smoke\r\n")
    stream = conn.makefile("rb")
    assert [stream.readline() for _ in range(4)] == [
        b"STORED\r\n", b"VALUE panel-smoke 0 2\r\n", b"ok\r\n", b"END\r\n"]
PYMC
mysql_query() {
  "${infra[@]}" exec -T mysql sh -ec 'MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -h127.0.0.1 -N -u"$MYSQL_USER" "$MYSQL_DATABASE"'
}

# 在一次性业务库重放 V8，覆盖历史账号缺行以及分表余额已变化的升级场景。
mysql_query <<'SQL'
INSERT INTO bullfight_gameinfo (mid, sid, money, chip) VALUES (740001,1,80,10),(740002,1,90,20);
INSERT INTO bullfight_gameinfo2 (mid, sid, money, chip) VALUES (740002,1,60,35);
SQL
for pass in 1 2; do
  mysql_query < "$repo/backend/api/src/main/resources/db/migration/V8__initialize_missing_player_shards.sql"
  [[ $(mysql_query <<<"SELECT COUNT(*) FROM bullfight_gameinfo1 WHERE mid=740001 AND money=80 AND chip=10") == 1 ]]
  [[ $(mysql_query <<<"SELECT COUNT(*) FROM bullfight_gameinfo2 WHERE mid=740002 AND money=60 AND chip=35") == 1 ]]
done
echo "Verified repeatable player shard backfill and preservation of existing balances."

# A synthetic record is written only to this job's new, disposable database.
mysql_query <<'SQL'
INSERT INTO t_activity(activity_id,owner_id) VALUES (851,851);
INSERT INTO t_free_game_round(activity_id,round_index,content) VALUES (851,1,'ci-round');
INSERT INTO t_version (type,status,version) VALUES ('2','2','ci-smoke');

SQL
"${dc[@]}" exec -T api java -Dloader.path=/tmp/panel-probe -Dloader.main=com.j.joker.NativeRoomCheck \
  -cp /srv/joker/joker-api.jar org.springframework.boot.loader.launch.PropertiesLauncher
# A second invocation must preserve both the test record and the migration history.
"${dc[@]}" up -d --force-recreate --wait --wait-timeout 300
applied=$(mysql_query <<<"SELECT COUNT(*) FROM flyway_schema_history WHERE version IN ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18') AND type='SQL' AND success=1")
[[ $applied == 18 ]]
[[ $(mysql_query <<<"SELECT COUNT(*) FROM t_game g JOIN t_group_game gg ON gg.game_id=g.game_Id JOIN t_game_config c ON c.level=g.level JOIN t_game_type t ON t.game_id=g.game_Id WHERE g.code='niuniu' AND gg.port=11603 AND JSON_EXTRACT(c.content,'$.level')=302") == 1 ]]
[[ $(mysql_query <<<"SELECT COUNT(*) FROM t_game_server") == 0 ]]
"${dc[@]}" exec -T api wget -qO- 'http://127.0.0.1:8080/hbiInterface/version/queryVersion?type=2&interfaceType=J' | python3 -c 'import json,sys; r=json.load(sys.stdin); assert r["returnCode"]=="0" and r["data"]["version"]=="ci-smoke"'
# Synthetic authenticated owner for the rounds fixture.
expires=$(( ($(date +%s) + 180) * 1000 ))
"${infra[@]}" exec -T redis redis-cli HSET TOKEN_851 token ci-rounds timestamp "$expires" >/dev/null
"${dc[@]}" exec -T user python3 - http://127.0.0.1:8080/hbiInterface < "$repo/backend/tests/check-username.py"
# Exercise Jasper and JSP EL from the packaged jar, without contacting a payment provider.
for page in mazhifu biqiPayOrder shanyun payOrder rongZhouPayOrder qilin rongZhouPayOrder2; do
  "${dc[@]}" exec -T api wget -qO- "http://127.0.0.1:8080/hbiInterface/views/$page.jsp" |
    python3 -c 'import sys; html=sys.stdin.read(); assert "<form" in html.lower() and "<%" not in html and "${" not in html'
done
# Read the generated OpenAPI description with a short-lived fixture session in this isolated Redis.
expires=$(( ($(date +%s) + 180) * 1000 ))
"${infra[@]}" exec -T redis redis-cli HSET TOKEN_ci-docs token ci-docs timestamp "$expires" >/dev/null
"${infra[@]}" exec -T redis redis-cli EXPIRE TOKEN_ci-docs 180 >/dev/null
"${dc[@]}" exec -T api wget -qO- 'http://127.0.0.1:8080/hbiInterface/api-docs?XYUid=ci-docs&XYToken=ci-docs' |
  python3 -c 'import json,sys; spec=json.load(sys.stdin); assert "get" in spec["paths"]["/version/queryVersion"]'
tables=$(mysql_query <<<"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name <> 'flyway_schema_history'")
[[ $tables -ge 163 ]]

missing=$(mysql_query < tools/check-schema.sql)
if [[ -n $missing ]]; then
  printf 'Missing game tables or columns:\n%s\n' "$missing" >&2
  exit 1
fi
echo "Verified external MySQL, Redis, MongoDB and Memcached, migrations, JSPs and application version read; business tables: $tables."

# 在同一批临时服务上切换 data 和 gold，再用原大厅真实心跳验证游戏网关。
if [[ ${CHECK_JAVA_VARIANT:-0} == 1 ]]; then
  gateway="$project-gateway"
  trap 'docker rm -f "$gateway" >/dev/null 2>&1 || true; cleanup' EXIT
  DATA_GOLD_RUNTIME=game-java "${dc[@]}" up -d --wait --wait-timeout 150 data gold
  docker run -d --platform linux/amd64 --name "$gateway" --network "$PANEL_NETWORK" --network-alias joker-gateway \
    "$PREFIX-game-java:$TAG" >/dev/null
  for ((i=0; i<45; i++)); do
    if "${dc[@]}" exec -T api wget -qO /dev/null http://joker-gateway:8090/health; then break; fi
    sleep 1
  done
  "${dc[@]}" exec -T user python3 - < "$repo/backend/game-java/tests/hall_gateway.py"
  # 同一编排保留 alloc，切换房间镜像后须收到真实注册回执才能通过健康检查。
  DATA_GOLD_RUNTIME=game-java DOUNIU_RUNTIME=game-java "${dc[@]}" up -d --wait --wait-timeout 150 douniu
  "${dc[@]}" exec -T douniu test -s /tmp/joker-douniu-alloc.ready
  "${dc[@]}" exec -T api mkdir -p /tmp/panel-probe
  "${dc[@]}" cp "$repo/backend/api/target/test-classes/com" api:/tmp/panel-probe/
  "${dc[@]}" exec -T api java -Dloader.path=/tmp/panel-probe -Dloader.main=com.j.joker.NativeRoomCheck \
    -cp /srv/joker/joker-api.jar org.springframework.boot.loader.launch.PropertiesLauncher create 11603 861
  # 联盟房与普通房分别走真实大厅；最后一桌退桌时分房进程必须继续运行。
  mkdir hall-room-check
  javac --release 23 -cp "$repo/backend/game-java/target/classes" -d hall-room-check \
    "$repo/backend/game-java/tests/DouniuCheck.java" "$repo/backend/game-java/tests/HallRoomCheck.java"
  "${dc[@]}" cp "$repo/backend/game-java/target/classes" api:/tmp/room-classes
  "${dc[@]}" cp hall-room-check/. api:/tmp/room-classes/
  alloc_container=$("${dc[@]}" ps -q alloc)
  before_close=$(docker inspect -f '{{.State.StartedAt}}' "$alloc_container")
  for scenario in --password --club --ordinary; do
    "${dc[@]}" exec -T api java -Dloader.path=/tmp/room-classes -Dloader.main=HallRoomCheck \
      -cp /srv/joker/joker-api.jar org.springframework.boot.loader.launch.PropertiesLauncher "$scenario"
  done
  if [[ $(docker inspect -f '{{.State.Running}} {{.State.StartedAt}}' "$alloc_container") != "true $before_close" ]]; then
    echo "真实大厅对局退桌时 alloc 异常退出，不能连续分房。" >&2
    exit 1
  fi
fi
