"""Check the listening port of this service in the shared network namespace."""
from pathlib import Path

args = Path("/proc/1/cmdline").read_bytes().decode().split("\0")
port = int(args[args.index("-p") + 1])
for name in ("tcp", "tcp6"):
    for line in Path("/proc/net", name).read_text().splitlines()[1:]:
        fields = line.split()
        if fields[3] == "0A" and int(fields[1].split(":")[1], 16) == port:
            raise SystemExit(0)
raise SystemExit(1)
