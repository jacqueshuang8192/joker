"""从仓库根目录运行，核对各打包目录实际使用的心跳、大厅登录和密码房脚本。"""
from pathlib import Path
import subprocess


tests = Path(__file__).resolve().parent
client = tests.parent
sockets = [p for p in sorted(client.rglob("ScoketGame.lua")) if "archive" not in p.parts]
assert sockets, "缺少打包的大厅脚本"
for socket in sockets:
    root = next(p for p in socket.parents if p.name in {"assets", "main", "alternate"})
    source = root / "src"
    byte_array = source / "framework/cc/utils/ByteArray.lua"
    if not byte_array.is_file():
        byte_array = root / "framework/cc/utils/ByteArray.lua"
    if 'require("hall.network.Encrypt")' in socket.read_text():
        cipher = socket.parent / "network/Encrypt.lua"
    else:
        cipher = source / "socket/Encrypt.lua"
        if not cipher.is_file():
            cipher = root / "socket/Encrypt.lua"
    subprocess.run(["lua", tests / "douniu_heartbeat.lua", socket, byte_array, cipher], check=True)
    keypad = socket.parent / "scene/group/join/group_join.lua"
    subprocess.run(["lua", tests / "douniu_password.lua", keypad], check=True)
    subprocess.run(["lua", tests / "hall_login.lua", socket.parent / "HallServer.lua"], check=True)
    bootstrap = root / "hall/network/Request.lua"
    assert 'PURE_JAVA_HALL = responseData["data"]["pureJavaHall"] == true' in bootstrap.read_text(), bootstrap
print(f"Verified heartbeat, room PIN and hall login in {len(sockets)} packaged halls.")
