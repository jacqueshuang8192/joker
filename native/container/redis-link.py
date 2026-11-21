"""Expose an authenticated upstream Redis connection on the game's private loopback."""
import asyncio
import json
import socket
import sys

LOCAL = ("127.0.0.1", 6379)


def command(*parts):
    encoded = [part.encode("utf-8") for part in parts]
    return ("*%d\r\n" % len(parts)).encode() + b"".join(
        ("$%d\r\n" % len(part)).encode() + part + b"\r\n" for part in encoded)


async def copy_stream(reader, writer):
    while True:
        data = await reader.read(65536)
        if not data:
            writer.write_eof()
            return
        writer.write(data)
        await writer.drain()


async def serve(client, reply, settings):
    upstream = None
    pending = []
    try:
        server, upstream = await asyncio.wait_for(
            asyncio.open_connection(settings["host"], settings["port"]), 5)
        if settings["password"]:
            parts = [settings["user"]] if settings["user"] else []
            upstream.write(command("AUTH", *parts, settings["password"]))
            await upstream.drain()
            if await asyncio.wait_for(server.readline(), 5) != b"+OK\r\n":
                print("Upstream Redis authentication failed", file=sys.stderr, flush=True)
                return
        pending = [asyncio.ensure_future(copy_stream(client, upstream)),
                   asyncio.ensure_future(copy_stream(server, reply))]
        done, _ = await asyncio.wait(pending, return_when=asyncio.FIRST_COMPLETED)
        for task in done:
            task.result()
        if pending[1] not in done:
            # The client has finished sending. Let Redis finish returning its replies.
            await pending[1]
    except (OSError, asyncio.TimeoutError, EOFError) as exc:
        print("Redis connection failed: {}".format(type(exc).__name__), file=sys.stderr, flush=True)
    finally:
        for task in pending:
            task.cancel()
        if pending:
            await asyncio.gather(*pending, return_exceptions=True)
        if upstream:
            upstream.close()
        reply.close()


def main():
    if sys.argv[1:] == ["check"]:
        with socket.create_connection(LOCAL, 3) as conn:
            conn.sendall(command("PING"))
            return 0 if conn.makefile("rb").readline() == b"+PONG\r\n" else 1
    with open("/srv/redis.json", encoding="utf-8") as stream:
        settings = json.load(stream)
    loop = asyncio.get_event_loop()
    loop.run_until_complete(asyncio.start_server(
        lambda reader, writer: serve(reader, writer, settings), *LOCAL))
    loop.run_forever()


if __name__ == "__main__":
    sys.exit(main())
