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
mysql_query() {
  "${dc[@]}" exec -T mysql sh -ec 'MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -h127.0.0.1 -N -u"$MYSQL_USER" "$MYSQL_DATABASE"'
}

# A synthetic record is written only to this job's new, disposable database.
mysql_query <<'SQL'
INSERT INTO t_version (type,status,version) VALUES ('2','2','ci-smoke');
SQL
# A second invocation must preserve both the test record and the migration history.
"${dc[@]}" run --rm --no-deps -T flyway migrate
applied=$(mysql_query <<<"SELECT COUNT(*) FROM flyway_schema_history WHERE version IN ('1','2') AND type='SQL' AND success=1")
[[ $applied == 2 ]]
"${dc[@]}" exec -T api curl -fsS 'http://127.0.0.1:8080/hbiInterface/version/queryVersion?type=2&interfaceType=J' | python3 -c 'import json,sys; r=json.load(sys.stdin); assert r["returnCode"]=="0" and r["data"]["version"]=="ci-smoke"'
tables=$(mysql_query <<<"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name <> 'flyway_schema_history'")
[[ $tables -ge 148 ]]

missing=$(mysql_query < tools/check-schema.sql)
if [[ -n $missing ]]; then
  printf 'Missing game tables:\n%s\n' "$missing" >&2
  exit 1
fi
echo "Verified Flyway migrations, mapped tables and application version read; business tables: $tables."
