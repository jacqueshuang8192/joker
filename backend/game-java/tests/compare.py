"""Run matching data and gold requests against the native and JVM images on disposable databases."""
import argparse
from contextlib import ExitStack, closing
import hashlib
import os
import uuid
import json
from pathlib import Path
import secrets
import socket
import struct
import subprocess
import sys
import tempfile
import time
import xml.etree.ElementTree as ET


def docker(*args, input=None):
    return subprocess.run(["docker", *args], input=input, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True).stdout.strip()


def wait_for(check, seconds=100):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        try:
            if check():
                return
        except (OSError, subprocess.CalledProcessError):
            pass
        time.sleep(0.5)
    raise RuntimeError("Timed out waiting for " + str(check))


def ints(*values):
    return struct.pack("!" + "i" * len(values), *values)


def text(value):
    data = value.encode() + b"\0"
    return ints(len(data)) + data


def frame(cmd, payload):
    return struct.pack("!I2sHIHHBB", 14 + len(payload), b"BY", 0, cmd, 0, 0, 0, 0) + payload


def run_suite(native, java, tmp, scope):
    network = "joker-compare-" + secrets.token_hex(5)
    password = secrets.token_hex(16)
    docker("network", "create", network)
    scope.callback(docker, "network", "rm", network)

    def run(name, *args):
        # macOS 的 Docker 在虚拟机内分配随机端口，可能与宿主 MySQL 等服务重号。
        # 由宿主选取空闲的回环端口。Linux 继续让 Docker 原子分配发布端口。
        if sys.platform == "darwin":
            args = list(args)
            for index, arg in enumerate(args):
                if index and args[index-1] == "-p" and arg.startswith("127.0.0.1::"):
                    with socket.socket() as probe:
                        probe.bind(("127.0.0.1", 0))
                        args[index] = f"127.0.0.1:{probe.getsockname()[1]}:{arg.rsplit(':',1)[1]}"
        cid = docker("run", "-d", "--platform", "linux/amd64", "--network", network, "--network-alias", name, *args)
        scope.callback(docker, "rm", "-fv", cid)
        return cid

    db = run("mysql", "-e", "MYSQL_DATABASE=game", "-e", "MYSQL_USER=game", "-e",
             "MYSQL_PASSWORD=" + password, "-e", "MYSQL_RANDOM_ROOT_PASSWORD=yes", "mysql:5.7.44")
    cache = run("redis", "redis:7-alpine", "redis-server", "--requirepass", password)

    def sql(query):
        return docker("exec", "-i", db, "sh", "-c", 'MYSQL_PWD="$MYSQL_PASSWORD" exec mysql -h127.0.0.1 -ugame game -BN', input=query)

    def redis(*args):
        return docker("exec", "-e", "REDISCLI_AUTH=" + password, cache, "redis-cli", "--raw", *args)

    wait_for(lambda: sql("SELECT 1") == "1")
    sql("""CREATE TABLE bullfight_gameinfo1(mid INT PRIMARY KEY,money BIGINT,exp INT,score INT,wintimes INT,losetimes INT,chip INT);
           CREATE TABLE t_activity_user(userid INT,activity_id INT, present_chip INT, bring_chip INT);""")
    root = Path(__file__).resolve().parents[3]
    (tmp / "redis.json").write_text(json.dumps(dict(host="redis", port=6379, user="", password=password)))
    sql((root / "backend/api/src/main/resources/db/migration/V5__douniu_round_settlement.sql").read_text())
    migrations = root / "backend/api/src/main/resources/db/migration"
    for version, table in [("V1", "t_gift_room_card"), ("V1", "t_free_game_round"), ("V1", "t_activity"), ("V2", "t_free_game_singleresult")]:
        schema = next(migrations.glob(version + "__*.sql")).read_text()
        start = schema.index("CREATE TABLE IF NOT EXISTS `" + table + "`")
        sql(schema[start:schema.index(";", start) + 1])
    sql((migrations / "V7__douniu_round_history.sql").read_text())
    sql((migrations / "V10__douniu_variants.sql").read_text())
    sql((migrations / "V11__table_charges_and_gifts.sql").read_text())
    sql((migrations / "V12__player_cache_sync.sql").read_text())
    for role in ["gold", "data"]:
        template = root / "config" / ("gold-example.xml.in" if role == "gold" else "data.xml.in")
        xml = ET.fromstring(template.read_bytes())
        xml.find(".//DB").attrib.update(ip="mysql", port="3306", user="game", pwd=password, dbName="game")
        if role == "gold":
            xml.find("GAME").set("UpdateInteval", "1")
        (tmp / (role + ".xml")).write_bytes(ET.tostring(xml, encoding="utf-8"))
    # Mounted files must be readable by the unprivileged image users, including on Linux.
    for file in tmp.iterdir():
        file.chmod(0o644)

    def check_rounds(image, data_id, endpoint):
        # 启动与 1Panel 相同的原生 alloc，使用真实 API 客户端发起建桌与退桌。
        def address(cid):
            return json.loads(docker("inspect", cid))[0]["NetworkSettings"]["Networks"][network]["IPAddress"]

        mem = run("memcached", "memcached:1.6.39-alpine")
        mem_ip = address(mem)
        def config(name, replacements):
            content = (root / "config" / (name + ".in")).read_text()
            for key, value in replacements.items():
                content = content.replace(key, value)
            file = tmp / name
            file.write_text(content)
            file.chmod(0o644)
            return str(file)

        mc = {"@MEMCACHED_HOST@": mem_ip, "@MEMCACHED_PORT@": "11211"}
        common = ["-e", "JOKER_REDIS_CONFIG=/srv/redis.json", "-v", str(tmp / "redis.json") + ":/srv/redis.json:ro"]
        user = run("user", *common, "-v", config("user.ini", mc) + ":/srv/user/conf/config.ini:ro",
                   native, "user", "-h", "0.0.0.0", "-p", "7500", "-s", "1", "-m", "500000")
        user_ip = address(user)
        xml = config("alloc.xml", {"@DB_HOST@": address(db), "@DB_PORT@": "3306", "@DB_USER@": "game",
                     "@DB_PASSWORD@": password, "@DB_NAME@": "game"})
        alloc = run("alloc", *common, "-v", xml + ":/srv/alloc/bin/server.xml:ro", "-v",
                    config("alloc.ini", {**mc, "127.0.0.1:7500": user_ip + ":7500"}) + ":/srv/alloc/bin/config.ini:ro",
                    "-v", config("game.ini", {"127.0.0.1:6001": address(data_id) + ":6001",
                    "HOST=127.0.0.1": "HOST=" + user_ip}) + ":/srv/alloc/bin/GameServer.ini:ro",
                    "-p", "127.0.0.1::11603", native, "alloc", "-p", "11603", "-l", "302", "-s", "63", "-u", "4", "-m", "400", "-d")
        alloc_port = docker("port", alloc, "11603/tcp").split(":")[-1]
        api = root / "backend/api/target"
        def room_request(action, *params):
            if action == "create":
                sql(f"INSERT INTO t_activity(activity_id,game_id,level) VALUES ({int(params[0])},302,302)")
            out = subprocess.check_output(["java", "-Dloader.main=com.j.joker.NativeRoomCheck",
                  "-Dloader.path=" + str(api / "test-classes"), "-cp", str(api / "joker-api.jar"),
                  "org.springframework.boot.loader.launch.PropertiesLauncher", action, alloc_port, *map(str, params)], text=True)
            return int(out.strip().splitlines()[-1].split("=")[1])

        uids = (424241, 424251)
        keys = []
        for uid in uids:
            sql(f"INSERT INTO bullfight_gameinfo1 VALUES ({uid},500,0,0,0,0,1000)")
            token = secrets.token_hex(24)
            redis("HSET", f"TOKEN_{uid}", "token", token, "timestamp", str(int(time.time() + 240) * 1000))
            keys.append(hashlib.sha256(f"joker/douniu/{uid}/{token}".encode()).hexdigest())
        relay = run("round-data", "--no-healthcheck", "-v", str(root / "backend/game-java/tests/round_reply_fixture.py") + ":/fixture.py:ro",
                    "--entrypoint", "python3", native, "/fixture.py")
        room = run("room-check", "-e", "GAME_ROLE=douniu", "-e", "DATA_HOST=round-data",
                   "-e", "ALLOC_HOST=alloc", "-e", "ADVERTISE_IP=127.0.0.1", "-v", str(tmp / "redis.json") + ":/srv/redis.json:ro", "-p", "127.0.0.1::13600", image)
        port = docker("port", room, "13600/tcp").split(":")[-1]

        def heartbeat():
            with socket.create_connection(("127.0.0.1", int(port)), 2) as sock:
                sock.sendall(frame(0x110, b""))
                return len(sock.recv(18)) == 18
        wait_for(heartbeat)
        def registered():
            # alloc 在收到地址上报后把客户端端点写入 Memcached。
            port_in_cache = docker("exec", alloc, "python3", "-c",
                "import socket; s=socket.create_connection((" + repr(mem_ip) + ",11211),2); "
                "s.sendall(b'get 1802\\r\\n'); f=s.makefile('rb'); head=f.readline(); "
                "print(f.readline().decode().strip() if head.startswith(b'VALUE') else '')")
            return port_in_cache == "302,127.0.0.1,13600"
        wait_for(registered)
        tid = room_request("create", 51)
        idle = room_request("create", 52)
        assert tid != idle and tid >> 16 == 1802
        assert room_request("close", 52, idle) == 0
        wait_for(lambda: room_request("close", 52, idle) == -1)
        # 有效会话和残留的入房记录都不能重新创建已解散的桌。
        module = root / "backend/game-java"
        client_check = ["java", "-cp", str(module / "target/classes"), str(module / "tests/DouniuCheck.java")]
        redis("HSET", "USER_GAME_STATUS", str(uids[0]), f"302_{idle}_52")
        subprocess.run([*client_check, "--closed", port, str(idle)], env={**os.environ, "FIRST_ROOM_KEY": keys[0]},
                       check=True, timeout=30)

        def play(table, activity, dissolve, history=False):
            for uid in uids:
                redis("HSET", "USER_GAME_STATUS", str(uid), f"302_{table}_{activity}")
            env = {**os.environ, "FIRST_ROOM_KEY": keys[0], "SECOND_ROOM_KEY": keys[1],
                   "CHECK_HISTORY": "1" if history else "0", "ROOM_ACTIVITY": str(activity), "PAUSE_BEFORE_BET": "1" if dissolve else "0"}
            with subprocess.Popen([*client_check, "--port", port, str(table)], env=env, text=True, stdin=subprocess.PIPE,
                                  stdout=subprocess.PIPE) as client:
                try:
                    if dissolve:
                        assert client.stdout.readline().strip() == "WAITING_FOR_DISSOLVE"
                        assert room_request("close", activity, table) == 0
                        # 已经入房的第二名玩家被另一个活动重新分配，旧桌关桌时应保留新记录。
                        redis("HSET", "USER_GAME_STATUS", str(uids[1]), "302_999_999")
                    out, _ = client.communicate("continue\n", timeout=30)
                    assert client.returncode == 0, out
                finally:
                    if client.poll() is None: client.kill()
            return list(map(int, out.split("DouniuCheck OK ")[1].split()))

        closing_chips = play(tid, 51, True)
        wait_for(lambda: room_request("close", 51, tid) == -1)
        wait_for(lambda: redis("HEXISTS", "USER_GAME_STATUS", str(uids[0])) == "0")
        assert redis("HGET", "USER_GAME_STATUS", str(uids[1])) == "302_999_999"
        print("Verified native alloc registration, empty-room removal and mid-round dissolution after settlement.")
        assert sum(closing_chips) == 2000
        for uid, chips in zip(uids, closing_chips):
            assert redis("HGET", f"MEMDATA_{uid}", "CHIPS") == str(chips)
            assert sql(f"SELECT money,chip FROM bullfight_gameinfo1 WHERE mid={uid}") == f"500\t{chips}"
        round_id, manifest = sql("SELECT round_id, balances FROM joker_douniu_settlement WHERE projected=1").split("\t")
        original = [tuple(map(int, entry.split(":"))) for entry in manifest.split(",")]

        def submit(identifier, entries):
            payload = text(identifier) + ints(len(entries)) + b"".join(ints(*e) for e in entries)
            with socket.create_connection(endpoint, 5) as sock, sock.makefile("rb") as reader:
                sock.sendall(frame(0x1010, payload))
                header = reader.read(18)
                assert struct.unpack_from("!i", header, 8)[0] == 0x2010
                return struct.unpack("!i", reader.read(4))[0]
        assert submit(round_id, original) == 0
        assert submit(str(uuid.uuid4()), original) == 2
        assert submit(round_id, [(uid, after, before) for uid, before, after in original]) == 1
        assert sql("SELECT COUNT(*) FROM joker_douniu_settlement") == "1"
        # Participant two changed since the snapshot: the first SQL write must roll back.
        sql(f"UPDATE bullfight_gameinfo1 SET chip=chip+5 WHERE mid={uids[1]}")
        entries = [(uids[0], closing_chips[0], closing_chips[0] - 1),
                   (uids[1], closing_chips[1], closing_chips[1] + 1)]
        assert submit(str(uuid.uuid4()), entries) == 2
        assert sql(f"SELECT chip FROM bullfight_gameinfo1 WHERE mid={uids[0]}") == str(closing_chips[0])
        assert redis("HGET", f"MEMDATA_{uids[0]}", "CHIPS") == str(closing_chips[0])
        sql(f"UPDATE bullfight_gameinfo1 SET chip=chip-5 WHERE mid={uids[1]}")
        # Replay the exact post-commit / pre-projection state after restarting data.
        docker("stop", "-t", "10", data_id)
        sql(f"UPDATE joker_douniu_settlement SET projected=0 WHERE round_id='{round_id}'")
        for uid in uids:
            redis("HSET", f"MEMDATA_{uid}", "CHIPS", "1000")
        docker("start", data_id)
        wait_for(lambda: sql("SELECT projected FROM joker_douniu_settlement") == "1")
        for uid, chips in zip(uids, closing_chips):
            assert redis("HGET", f"MEMDATA_{uid}", "CHIPS") == str(chips)
        final_table = room_request("create", 53, 1)
        final_chips = play(final_table, 53, False)
        assert sum(final_chips) == 2000
        wait_for(lambda: redis("HGET", "WAIT_CLOSE_GROUP_NEW", "53") == f"{final_table}_53_1")
        assert room_request("close", 53, final_table) == -1
        history_table = room_request("create", 55, 10)
        play(history_table, 55, False, history=True)
        wait_for(lambda: redis("HGET", "WAIT_CLOSE_GROUP_NEW", "55") == f"{history_table}_55_1")
        table = room_request("create", 54, 10)
        for uid in uids:
            redis("HSET", "USER_GAME_STATUS", str(uid), f"302_{table}_54")
        docker("exec", relay, "touch", "/tmp/hold-round-reply")
        def restart_room(expire_vote=False):
            docker("kill", room)
            if expire_vote:
                # 在隔离测试的停机窗口模拟五分钟已经过去。保留原局号和所有结算字段。
                saved = json.loads(redis("HGET", snap_key, str(table)))
                assert saved["vote"]["applicant"] == uids[0]
                saved["vote"]["expiresAt"] = int(time.time() * 1000) - 1000
                redis("HSET", snap_key, str(table), json.dumps(saved, ensure_ascii=False))
            docker("start", room)
            wait_for(lambda: docker("exec", room, "test", "-s", "/tmp/joker-douniu-alloc.ready") == "" and heartbeat_new())
            return docker("port", room, "13600/tcp").split(":")[-1]

        def heartbeat_new():
            current = int(docker("port", room, "13600/tcp").split(":")[-1])
            with socket.create_connection(("127.0.0.1", current), 2) as s, s.makefile("rb") as stream:
                s.sendall(frame(0x110, b""))
                return len(stream.read(18)) == 18

        with subprocess.Popen([*client_check, "--restart", port, str(table)], text=True,
                              env={**os.environ, "FIRST_ROOM_KEY": keys[0], "SECOND_ROOM_KEY": keys[1]},
                              stdin=subprocess.PIPE, stdout=subprocess.PIPE) as client:
            try:
                assert client.stdout.readline().strip() == "RESTART_AFTER_GRAB"
                snap_key = "JOKER_DOUNIU:302:1802:rooms"
                snapshot = json.loads(redis("HGET", snap_key, str(table)))
                round_id = snapshot["table"]["roundId"]
                client.stdin.write(restart_room() + "\n")
                client.stdin.flush()
                assert client.stdout.readline().strip() == "RESTART_DURING_SETTLEMENT"
                wait_for(lambda: sql(f"SELECT projected FROM joker_douniu_settlement WHERE round_id='{round_id}'") == "1")
                saved_result = json.loads(redis("HGET", snap_key, str(table)))["table"]["pendingSettlement"]
                assert len(saved_result["entries"]) == 2 and sum(e["delta"] for e in saved_result["entries"]) == 0
                before_restart = sql("SELECT mid,chip FROM bullfight_gameinfo1 WHERE mid IN (424241,424251) ORDER BY mid")
                client.stdin.write(restart_room(expire_vote=True) + "\n")
                client.stdin.flush()
                assert client.stdout.readline().strip() == "CONFIRM_SETTLEMENT"
                docker("exec", relay, "rm", "/tmp/hold-round-reply")
                out, _ = client.communicate(timeout=25)
                assert client.returncode == 0, out
                recovered = list(map(int, out.split("DouniuCheck OK ")[1].split()))
                assert before_restart == "\n".join(f"{uid}\t{chips}" for uid, chips in zip(uids, recovered))
                for uid, chips in zip(uids, recovered):
                    assert sql(f"SELECT chip FROM bullfight_gameinfo1 WHERE mid={uid}") == str(chips)
                    assert redis("HGET", f"MEMDATA_{uid}", "CHIPS") == str(chips)
                assert sql("SELECT COUNT(*) FROM joker_douniu_settlement") == "4"
                assert sql("SELECT COUNT(*),COUNT(DISTINCT douniu_round_id) FROM t_free_game_round") == "4\t4"
                assert sql("SELECT COUNT(*),SUM(score),SUM(total),MIN(game_id) FROM t_free_game_singleresult") == "8\t0\t8\t302"
                history = json.loads(sql("SELECT content FROM t_free_game_round WHERE activity_id=54 AND round_index=1"))
                assert {p["uid"]:p["cards"] for p in history["userinfos"]} == {p["uid"]:p["cards"] for p in snapshot["table"]["players"]}
                wait_for(lambda: redis("HGET", "WAIT_CLOSE_GROUP_NEW", "54") == f"{table}_54_1")
                assert redis("HEXISTS", snap_key, str(table)) == "0"
                # 已结束的桌在下一次启动也必须保持关闭，即使 Redis 中残留入房授权。
                new_port = restart_room()
                redis("HSET", "USER_GAME_STATUS", str(uids[0]), f"302_{table}_54")
                subprocess.run([*client_check, "--closed", new_port, str(table)], check=True, timeout=30,
                               env={**os.environ, "FIRST_ROOM_KEY": keys[0]})
            finally:
                if client.poll() is None: client.kill()
        print("Verified room SIGKILL after dealing and after SQL commit with lost acknowledgement; same hands, decisions, receipt and balances.")
        print("Verified final-round closure, authenticated Java play, reconnect, SQL/Redis balances, idempotence, rollback and recovery.")

    def probe(image, jvm):
        sql("""DELETE FROM bullfight_gameinfo1; INSERT INTO bullfight_gameinfo1 VALUES (101,70,4,8,3,2,9);
               DELETE FROM t_activity_user; INSERT INTO t_activity_user VALUES (101,6,0,17);""")
        redis("FLUSHDB")
        result = []
        gold_id = None
        for role, port in [("gold", 6005), ("data", 6001)]:
            if role == "data":
                gold_ip = json.loads(docker("inspect", gold_id))[0]["NetworkSettings"]["Networks"][network]["IPAddress"]
                tree = ET.parse(tmp / "data.xml")
                section = tree.find(".//GAME")
                for old in section.findall("UpdateServer"):
                    section.remove(old)
                section.insert(list(section).index(section.find("DBList")),
                               ET.Element("UpdateServer", ip=gold_ip, port="6005"))
                tree.write(tmp / "data.xml", encoding="utf-8")
                redis("DEL", "MEMDATA_101")
                sql("""INSERT INTO bullfight_gameinfo1 VALUES (111,0,0,0,0,0,0);
                       INSERT INTO t_activity_user VALUES (111,6,0,0);""")
            mount = lambda file, remote: ["-v", str(tmp / file) + ":" + remote + ":ro"]
            args = ["-e", "GAME_ROLE=" + role, "-e", "JOKER_REDIS_CONFIG=/srv/redis.json",
                    "-p", "127.0.0.1::" + str(port)] + mount("redis.json", "/srv/redis.json") + mount(role + ".xml", "/srv/" + role + "/bin/config.xml")
            cid = run(role, *args, image, *([] if jvm else [role, "-h", "0.0.0.0", "-p", str(port), "-s", "0"]))
            endpoint = ("127.0.0.1", int(docker("port", cid, str(port) + "/tcp").split(":")[-1]))
            def ready():
                with socket.create_connection(endpoint, 1) as check:
                    # Docker Desktop may accept before the process is listening.
                    check.settimeout(0.2)
                    try:
                        return check.recv(1) != b""
                    except socket.timeout:
                        return True
            try:
                wait_for(ready)
                with socket.create_connection(endpoint, 5) as conn, closing(conn.makefile("rb")) as reader:
                    def send(cmd, body, reply=None):
                        packet = frame(cmd, body)
                        conn.sendall(packet[:3])
                        conn.sendall(packet[3:])
                        if reply is not None:
                            length = struct.unpack("!I", reader.read(4))[0]
                            response = reader.read(length)
                            assert response[0:2] == b"BY" and struct.unpack_from("!i", response, 4)[0] == reply
                            result.append((cmd, response.hex()))
                    if role == "data":
                        send(0x1004, ints(0, 101), 0x2004)  # MySQL cache miss
                        create = ints(0) + text("create") + ints(111) + text("5000000000") + ints(4, 30, 2, 1) + text("") + ints(15)
                        for _ in range(2):
                            send(0x1001, create, 0x2001)
                        send(0x1005, ints(1) + text("") + ints(111, 5) + text(""), 0x2002)
                        send(0x1002, ints(1) + text("partial") + ints(111, 0, -1, -80, 1, 0) + text("") + ints(-1), 0x2002)
                        send(0x1006, ints(111, 12, 2, 6))
                        send(0x301a, ints(111, 6, 20, 1200, 2), 0x301a)
                        send(0x301c, ints(111))
                        send(0x301d, ints(111, 1200, 2, 6), 0x301d)
                        send(0x302d, ints(111, 3, 6))
                        send(0x3200, ints(302, 51, 2, 4, 1), 0x3200)
                        send(0x1004, ints(0, 111), 0x2004)
                        result.append(redis("HMGET", "MEMDATA_111", "MONEY", "EXP", "WIN", "LOST", "SCORE", "CHIPS"))
                        assert redis("HGET", "GROUP_USER_TABLE_STATE_111", "6") == "3"
                        assert redis("HGET", "TABLE_LIST_302", str((51 << 16) + 1)) == "0,0,0,0"
                        expected_money, *_, expected_chips = result[-1].splitlines()
                        wait_for(lambda: sql("SELECT money,chip FROM bullfight_gameinfo1 WHERE mid=111")
                                == expected_money + "\t" + expected_chips, 15)
                        wait_for(lambda: sql("SELECT present_chip,bring_chip FROM t_activity_user WHERE userid=111")
                                == "35\t2", 15)
                        send(0x1003, ints(0) + text("") + ints(111), 0x2003)
                        assert redis("EXISTS", "MEMDATA_111") == "0"
                        if jvm:
                            check_rounds(image, cid, endpoint)
                    else:
                        redis("HSET", "MEMDATA_101", "MONEY", "5000000000", "EXP", "5", "WIN", "7", "LOST", "8", "SCORE", "19", "CHIPS", "11")
                        send(0x3004, ints(101))
                        send(0x3005, ints(101, 6, 14, 21))
                        send(0x3005, ints(101, 6, 18, 0))
                        wait_for(lambda: sql("SELECT present_chip,bring_chip FROM t_activity_user") == "18\t21", 15)
                        value = sql("SELECT money,exp,score,wintimes,losetimes,chip FROM bullfight_gameinfo1")
                        assert value == "5000000000\t5\t19\t7\t8\t11", value
                        result.append(value)
            except Exception:
                # Application logs may contain legacy configuration details. Keep them local.
                print("Verification failed for", image, role, flush=True)
                raise
            finally:
                if role == "gold":
                    gold_id = cid
                else:
                    docker("stop", "-t", "10", cid, gold_id)
        return result

    reference, actual = probe(native, False), probe(java, True)
    assert reference == actual, [(i, a, b) for i, (a, b) in enumerate(zip(reference, actual)) if a != b]
    print("Native and Java data replies, Redis state and gold database updates match.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("native")
    parser.add_argument("java")
    args = parser.parse_args()
    with tempfile.TemporaryDirectory() as tmp, ExitStack() as scope:
        run_suite(args.native, args.java, Path(tmp), scope)
