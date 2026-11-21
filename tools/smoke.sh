#!/usr/bin/env bash
# Run only on the disposable CI runner, with its dedicated Compose project.
set -euo pipefail
export COMPOSE_PROJECT_NAME="smoke-${GITHUB_RUN_ID:?}-${GITHUB_RUN_ATTEMPT:?}"
ci_override=$(mktemp)
trap 'docker compose -f docker-compose.yml -f "$ci_override" down -v --remove-orphans >/dev/null; rm -f "$ci_override"' EXIT
cat > "$ci_override" <<'YAML'
networks:
  default:
    internal: true
services:
  cache:
    ports: !reset []
YAML
dc=(docker compose -f docker-compose.yml -f "$ci_override")
"${dc[@]}" up -d --wait --wait-timeout 300
# A synthetic record is written only to this job's new, disposable database.
"${dc[@]}" exec -T mysql sh -ec 'MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -h127.0.0.1 -u"$MYSQL_USER" "$MYSQL_DATABASE"' <<'SQL'
INSERT INTO t_version (type,status,version) VALUES ('2','2','ci-smoke');
SQL
"${dc[@]}" exec -T api curl -fsS 'http://127.0.0.1:8080/hbiInterface/version/queryVersion?type=2&interfaceType=J' | python3 -c 'import json,sys; r=json.load(sys.stdin); assert r["returnCode"]=="0" and r["data"]["version"]=="ci-smoke"'
tables=$("${dc[@]}" exec -T mysql sh -ec 'MYSQL_PWD="$MYSQL_PASSWORD" mysql -N -h127.0.0.1 -u"$MYSQL_USER" "$MYSQL_DATABASE" -e "SHOW TABLES"' | wc -l)
[[ $tables -ge 86 ]]

# Report legacy schema gaps without treating the known baseline as complete.
missing=$("${dc[@]}" exec -T mysql sh -ec 'MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -h127.0.0.1 -N -u"$MYSQL_USER" "$MYSQL_DATABASE"' < tools/check-schema.sql | wc -l)
echo "Verified application version read; base tables: $tables; missing mapped tables: $missing."
