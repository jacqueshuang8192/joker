"""CI probe from inside the application network. Compare a hall heartbeat across both transports."""
import base64
import hashlib
import os
import socket
import struct


heartbeat = struct.pack("!I2sHIhhBBi", 18, b"BY", 0, 0x110, 1, 0, 0, 0, 0)
with socket.create_connection(("127.0.0.1", 4700), 5) as raw:
    raw.sendall(heartbeat)
    assert raw.makefile("rb").read(len(heartbeat)) == heartbeat

for path in ["/ws/hall", "/ws/douniu"]:
    with socket.create_connection(("joker-gateway", 8090), 5) as ws, ws.makefile("rb") as stream:
        key = base64.b64encode(os.urandom(16)).decode()
        ws.sendall((f"GET {path} HTTP/1.1\r\nHost: joker-gateway\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n"
                    f"Sec-WebSocket-Version: 13\r\nSec-WebSocket-Key: {key}\r\n\r\n").encode())
        assert stream.readline().startswith(b"HTTP/1.1 101 ")
        headers = {}
        while (line := stream.readline()) not in (b"\r\n", b""):
            name, value = line.split(b":", 1)
            headers[name.lower()] = value.strip()
        accept = hashlib.sha1((key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").encode()).digest()
        assert headers[b"sec-websocket-accept"] == base64.b64encode(accept)
        if path == "/ws/hall":
            payload = base64.b64encode(heartbeat)
            mask = os.urandom(4)
            ws.sendall(bytes([0x81, 0x80 | len(payload)]) + mask +
                       bytes(n ^ mask[i % 4] for i, n in enumerate(payload)))
            result = b""
            while len(result) < len(heartbeat):
                opcode, size = stream.read(2)
                assert opcode == 0x81 and size < 126
                result += base64.b64decode(stream.read(size), validate=True)
            assert result == heartbeat
print("Native hall heartbeat matched through the gateway; Douniu upstream handshake succeeded.")
