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
"${compile[@]}" backend/table-rules/src/main/java/com/j/joker/game/*/domain/*.java "$game"/{hundred,rooms}/domain/*.java "$api"/domain/*.java
"${compile[@]}" "$game"/replay/*.java "$game"/{rooms,hundred,landlord,mahjong,runfast}/application/*.java
"${compile[@]}" backend/game-java/tests/{RoomAllocationCheck,SettlementCheck,VariantsCheck,HundredPlayerCheck,LandlordCheck,HongzhongCheck,RunFastCheck,FriendRulesCheck,IndependentRulesCheck,HundredOrdersCheck}.java
java -cp "$classes" RoomAllocationCheck
java -cp "$classes" SettlementCheck
java -cp "$classes" VariantsCheck
java -cp "$classes" HundredPlayerCheck
java -cp "$classes" HundredOrdersCheck
java -cp "$classes" com.j.joker.game.hundred.application.VerifyRound 101 backend/game-java/tests/fixtures/hundred-orders.jsonl --orders
java -cp "$classes" com.j.joker.game.hundred.application.VerifyRound 9103 backend/game-java/tests/fixtures/baccarat-orders.jsonl --orders
java -cp "$classes" LandlordCheck
java -cp "$classes" HongzhongCheck
java -cp "$classes" RunFastCheck
java -cp "$classes" IndependentRulesCheck
java -cp "$classes" FriendRulesCheck
java -cp "$classes" com.j.joker.game.runfast.application.VerifyRunFast backend/game-java/tests/fixtures/runfast-bombs.jsonl
java -cp "$classes" com.j.joker.game.landlord.application.ReplayLandlord backend/game-java/tests/fixtures/landlord-house.jsonl
