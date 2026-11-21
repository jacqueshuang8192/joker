#!/usr/bin/env bash
# Run only on the disposable CI runner, with its dedicated Compose project.
set -euo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
stage=$(mktemp -d)
project="smoke-${GITHUB_RUN_ID:?}-${GITHUB_RUN_ATTEMPT:?}"
export PANEL_NETWORK="$project-panel"
export CI_DB_PASSWORD="$(python3 -c 'import secrets; print(secrets.token_hex(12) + "&x")')"
export CI_CACHE_PASSWORD="$(python3 -c 'import secrets; print(secrets.token_hex(18) + "%!")')"
export CI_MONGO_PASSWORD="$(python3 -c 'import secrets; print(secrets.token_hex(12) + "@")')"
infra=(docker compose -p "$project-infra" -f "$repo/tools/ci-services.yml")
dc=(docker compose -p "$project" -f docker-compose.yml -f local.yml --profile gold)
cleanup() {
  "${dc[@]}" down -v --remove-orphans >/dev/null
  "${infra[@]}" down -v --remove-orphans >/dev/null
  docker network rm "$PANEL_NETWORK" >/dev/null
  rm -rf "$stage"
}
cp -R "$repo/config" "$repo/database" "$repo/tools" "$repo/panel.ini.example" "$repo/docker-compose.yml" "$repo/game-services.yml" "$stage/"
cd "$stage"
python3 - <<'PYCONFIG'
import configparser, os
s = configparser.ConfigParser(interpolation=None)
s.read("panel.ini.example")
s["deployment"].update(network=os.environ["PANEL_NETWORK"], advertise_ip="127.0.0.1",
                       image_prefix=os.environ["PREFIX"], tag=os.environ["TAG"])
s["mysql"].update(database="joker_ci", user="joker_ci", password=os.environ["CI_DB_PASSWORD"])
s["redis"]["password"] = os.environ["CI_CACHE_PASSWORD"]
s["mongodb"].update(user="mongo_ci", password=os.environ["CI_MONGO_PASSWORD"])
with open("panel.ini", "w") as f: s.write(f)
PYCONFIG
python3 tools/configure.py
cp runtime/gold-example.xml runtime/gold.xml
cat > local.yml <<'YAML'
services:
  redis-link:
    ports: !reset []
YAML
"${dc[@]}" config --quiet
docker network create --internal "$PANEL_NETWORK" >/dev/null
trap cleanup EXIT
"${infra[@]}" up -d --wait --wait-timeout 180
"${dc[@]}" up -d --wait --wait-timeout 300
# Call the same Mongo client the API uses, inside the deployed JAR's network and configuration.
cat > PanelMongoCheck.java <<'JAVA'
import com.hbi.utils.MongoUtil;

public class PanelMongoCheck {
    public static void main(String[] args) {
        try (var client = MongoUtil.MongoInstance()) {
            MongoUtil.getCollection().count();
        }
    }
}
JAVA
unzip -p "$repo/api/target/joker-api.jar" 'BOOT-INF/lib/mongo-java-driver-*.jar' > mongo-driver.jar
javac --release 23 -cp "$repo/api/target/classes:mongo-driver.jar" PanelMongoCheck.java
"${dc[@]}" exec -T api mkdir -p /tmp/panel-probe
"${dc[@]}" cp PanelMongoCheck.class api:/tmp/panel-probe/
"${dc[@]}" exec -T api java -Dloader.path=/tmp/panel-probe -Dloader.main=PanelMongoCheck \
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

# A synthetic record is written only to this job's new, disposable database.
mysql_query <<'SQL'
INSERT INTO t_version (type,status,version) VALUES ('2','2','ci-smoke');
SQL
# A second invocation must preserve both the test record and the migration history.
"${dc[@]}" run --rm --no-deps -T flyway
applied=$(mysql_query <<<"SELECT COUNT(*) FROM flyway_schema_history WHERE version IN ('1','2') AND type='SQL' AND success=1")
[[ $applied == 2 ]]
"${dc[@]}" exec -T api wget -qO- 'http://127.0.0.1:8080/hbiInterface/version/queryVersion?type=2&interfaceType=J' | python3 -c 'import json,sys; r=json.load(sys.stdin); assert r["returnCode"]=="0" and r["data"]["version"]=="ci-smoke"'
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
[[ $tables -ge 148 ]]

missing=$(mysql_query < tools/check-schema.sql)
if [[ -n $missing ]]; then
  printf 'Missing game tables:\n%s\n' "$missing" >&2
  exit 1
fi
echo "Verified external MySQL, Redis, MongoDB and Memcached, migrations, JSPs and application version read; business tables: $tables."
