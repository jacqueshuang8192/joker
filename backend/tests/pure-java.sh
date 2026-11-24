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
cleanup() {
  code=$?
  if [[ $code != 0 ]]; then "${dc[@]}" logs --tail 30 rooms data | tail -75 >&2 || true; fi
  "${dc[@]}" down -v --remove-orphans >/dev/null
  "${infra[@]}" down -v --remove-orphans >/dev/null
  docker network rm "$PANEL_NETWORK" >/dev/null
  rm -rf "$stage"
}
"${dc[@]}" config --quiet
mkdir "$stage/tests"
javac --release 23 -cp "$repo/backend/game-java/target/classes" -d "$stage/tests" "$repo/backend/game-java/tests/"{PureRoomsCheck,HallRoomCheck,DouniuCheck}.java
docker network create --internal "$PANEL_NETWORK" >/dev/null
trap cleanup EXIT
"${infra[@]}" up -d --wait --wait-timeout 180
"${dc[@]}" up -d --wait --wait-timeout 300
"${dc[@]}" cp "$repo/backend/game-java/target/classes" api:/tmp/room-classes
"${dc[@]}" cp "$stage/tests/." api:/tmp/room-classes/
testjava() {
  main=$1; shift
  "${dc[@]}" exec -T api java -Dloader.path=/tmp/room-classes -Dloader.main="$main" \
     -cp /srv/joker/joker-api.jar org.springframework.boot.loader.launch.PropertiesLauncher "$@"
}
rooms=$("${dc[@]}" ps -q rooms)
started=$(docker inspect -f '{{.State.StartedAt}}' "$rooms")
for scenario in --password --club --ordinary; do testjava HallRoomCheck "$scenario"; done
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
