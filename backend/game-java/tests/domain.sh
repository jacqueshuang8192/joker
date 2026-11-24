#!/usr/bin/env bash
# 独立编译领域模型和大厅用例，防止规则层引入 Spring、网络或数据库适配器。
set -euo pipefail
cd "$(dirname "$0")/../../.."
classes=$(mktemp -d)
trap 'rm -rf "$classes"' EXIT
game=backend/game-java/src/main/java/com/j/joker/game
api=backend/api/src/main/java/com/j/joker/rooms
# 先编译领域，再编译只允许依赖领域的大厅用例。反向引用会直接导致编译失败。
compile=(javac --release 23 --limit-modules java.base -cp "$classes" -sourcepath "$classes" -d "$classes")
"${compile[@]}" "$game/niuniu/util/Json.java" "$game"/niuniu/domain/{card,rules,table}/*.java
"${compile[@]}" "$game"/rooms/domain/*.java "$api"/domain/*.java
"${compile[@]}" "$game"/rooms/application/*.java
"${compile[@]}" backend/game-java/tests/{RoomAllocationCheck,SettlementCheck}.java
java -cp "$classes" RoomAllocationCheck
java -cp "$classes" SettlementCheck
