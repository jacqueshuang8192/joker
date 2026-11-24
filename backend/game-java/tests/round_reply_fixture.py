"""Isolated CI relay for the one-request-per-connection Java room data client."""
from pathlib import Path
import socket
import socketserver
import struct


def packet(stream):
    prefix = stream.read(4)
    if len(prefix) != 4:
        raise EOFError()
    size = struct.unpack("!I", prefix)[0]
    if not 14 <= size <= 65532:
        raise ValueError("invalid fixture frame")
    payload = stream.read(size)
    if len(payload) != size:
        raise EOFError()
    return prefix + payload


class DataReply(socketserver.StreamRequestHandler):
    def handle(self):
        request = packet(self.rfile)
        with socket.create_connection(("data", 6001), timeout=4) as upstream, upstream.makefile("rb") as reader:
            upstream.sendall(request)
            reply = packet(reader)
        if request[8:12] == struct.pack("!I", 0x1010) and Path("/tmp/hold-round-reply").exists():
            return
        self.wfile.write(reply)


with socketserver.ThreadingTCPServer(("0.0.0.0", 6001), DataReply) as server:
    server.serve_forever()
