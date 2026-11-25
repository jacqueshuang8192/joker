#!/usr/bin/env bash
# 在独立网络和空库运行实际 1Panel 编排。所有测试数据仅属于本次运行。
set -euo pipefail
repo=$(cd "$(dirname "$0")/../.." && pwd)
stage=$(mktemp -d)
project="pure-${GITHUB_RUN_ID:-local}-$$"
export PANEL_NETWORK="$project-panel" IMAGE_PREFIX=${PREFIX:?} IMAGE_TAG=${TAG:?}
export ADVERTISE_IP=127.0.0.1 MYSQL_USER=joker_ci MYSQL_DATABASE=joker_ci MONGO_USER=mongo_ci
randpass() { python3 -c 'import secrets; print(secrets.token_hex(16))'; }
export CI_DB_PASSWORD=$(randpass) CI_CACHE_PASSWORD=$(randpass) CI_MONGO_PASSWORD=$(randpass)
export MYSQL_PASSWORD=$CI_DB_PASSWORD REDIS_PASSWORD=$CI_CACHE_PASSWORD MONGO_PASSWORD=$CI_MONGO_PASSWORD
infra=(docker compose -p "$project-infra" -f "$repo/backend/tests/ci-services.yml")
dc=(docker compose -p "$project" -f "$repo/deploy/1panel/pure-java.yml" -f "$stage/local.yml" --profile gold)
printf 'services:\n  api:\n    ports: !reset []\n' > "$stage/local.yml"
gateway=
cleanup() {
  code=$?
  if [[ $code != 0 ]]; then "${dc[@]}" logs --tail 30 rooms data | tail -75 >&2 || true; fi
  if [[ -n $gateway ]]; then docker rm -f "$gateway" >/dev/null; fi
  "${dc[@]}" down -v --remove-orphans >/dev/null
  "${infra[@]}" down -v --remove-orphans >/dev/null
  docker network rm "$PANEL_NETWORK" >/dev/null
  rm -rf "$stage"
}
"${dc[@]}" config --quiet
mkdir "$stage/tests"
javac --release 23 -cp "$repo/backend/game-java/target/classes" -d "$stage/tests" "$repo/backend/game-java/tests/"{PureRoomsCheck,HallRoomCheck,DouniuCheck,VariantsWireCheck,LegacyFlowsCheck,FriendTableCheck,HundredTableCheck,GatewayCheck,UsernameRecoveryCheck}.java
docker network create --internal "$PANEL_NETWORK" >/dev/null
trap cleanup EXIT
"${infra[@]}" up -d --wait --wait-timeout 180
"${dc[@]}" up -d --wait --wait-timeout 300 api
dbquery() {
  "${infra[@]}" exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -NB -u "$MYSQL_USER" "$MYSQL_DATABASE"'
}
missing=$(dbquery < "$repo/tools/check-schema.sql")
if [[ -n $missing ]]; then echo "Missing database objects: $missing" >&2; exit 1; fi
[[ $(dbquery <<<"SELECT COUNT(*) FROM flyway_schema_history WHERE type='SQL' AND success=1") == 18 ]]
[[ $(dbquery <<<"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name <> 'flyway_schema_history'") == 180 ]]
echo 'Verified 18 Flyway migrations and 180 application tables on a fresh database.'
panel_ip() { docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"; }
api_ip=$(panel_ip "$("${dc[@]}" ps -q api)")
gateway=$(docker run -d --platform linux/amd64 --network "$PANEL_NETWORK" --network-alias ci-gateway \
  -e GAME_ROLE=gateway -e HALL_HOST=api -e HALL_PROXY_PROTOCOL=true -e TRUSTED_HTTP_PROXY_IPS="$api_ip" \
  "${IMAGE_PREFIX}-game-java:${IMAGE_TAG}")
export TRUSTED_HALL_GATEWAY_IPS=$(panel_ip "$gateway")
"${dc[@]}" up -d --wait --wait-timeout 300
"${dc[@]}" cp "$repo/backend/game-java/target/classes" api:/tmp/room-classes
"${dc[@]}" cp "$stage/tests/." api:/tmp/room-classes/
testjava() {
  main=$1; shift
  "${dc[@]}" exec -T api java -Dloader.path=/tmp/room-classes -Dloader.main="$main" \
     -cp /srv/joker/joker-api.jar org.springframework.boot.loader.launch.PropertiesLauncher "$@"
}
testjava UsernameRecoveryCheck
testjava HundredTableCheck --seed
docker kill "$("${dc[@]}" ps -q data)" >/dev/null
"${dc[@]}" up -d --wait --wait-timeout 120 data
testjava HundredTableCheck --resume
testjava HundredTableCheck --wire
testjava FriendTableCheck --seed
"${dc[@]}" restart api
"${dc[@]}" up -d --wait --wait-timeout 180
testjava FriendTableCheck --finish
rooms=$("${dc[@]}" ps -q rooms)
started=$(docker inspect -f '{{.State.StartedAt}}' "$rooms")
for scenario in --password --club --ordinary; do testjava HallRoomCheck "$scenario"; done
testjava LegacyFlowsCheck
testjava VariantsWireCheck
testjava PureRoomsCheck & probe=$!
for ((i=0; i<180; i++)); do
  if "${dc[@]}" exec -T api test -f /tmp/pure-rooms-restart; then break; fi
  if ! kill -0 "$probe" 2>/dev/null; then wait "$probe"; exit 1; fi
  sleep 1
done
"${dc[@]}" exec -T api test -f /tmp/pure-rooms-restart
[[ $(docker inspect -f '{{.State.Running}} {{.State.StartedAt}}' "$rooms") == "true $started" ]]
# 使用 SIGKILL 跳过关闭钩子，再从原 Redis 及 MySQL 恢复。
docker kill "$rooms" >/dev/null
"${dc[@]}" up -d --wait --wait-timeout 120 rooms
[[ $(docker inspect -f '{{.State.StartedAt}}' "$rooms") != "$started" ]]
"${dc[@]}" exec -T api touch /tmp/pure-rooms-resume
wait "$probe"

# 重建 SQL 已提交、Redis 尚未补记的窗口，只修改一次性编排中新建的两个测试账号。
testjava LegacyFlowsCheck --seed
read -r sender recipient buyer < <("${dc[@]}" exec -T api cat /tmp/joker-recovery-users)
[[ $sender =~ ^[0-9]+$ && $recipient =~ ^[0-9]+$ && $buyer =~ ^[0-9]+$ ]]
docker kill "$("${dc[@]}" ps -q data)" >/dev/null
testjava LegacyFlowsCheck --pending
"${infra[@]}" exec -T redis redis-cli HSET "MEMDATA_$sender" MONEY 0 CHIPS 0 >/dev/null
"${infra[@]}" exec -T redis redis-cli HSET "MEMDATA_$recipient" MONEY 0 >/dev/null
"${infra[@]}" exec -T redis redis-cli HSET "MEMDATA_$buyer" MONEY 0 CHIPS 0 >/dev/null
"${dc[@]}" up -d --wait --wait-timeout 120 data
testjava LegacyFlowsCheck --recovered
