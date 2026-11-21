"""Run one legacy service as container PID 1 and reap its daemon child."""
import os
import signal
import sys
from pathlib import Path

PROGRAMS = {
    "hall": "CCHallServer", "user": "UserServerSHM", "data": "CCMemDataServer",
    "alloc": "AllocRoomServer", "douniu": "DouNiuServerGroup_new", "gold": "CCGoldUpdateServer",
}

def stop(signum, frame):
    # Only signal processes in this container's private PID namespace.
    try:
        os.kill(-1, signal.SIGTERM)
    except ProcessLookupError:
        pass

def main():
    role, *args = sys.argv[1:]
    if role not in PROGRAMS or os.getpid() != 1:
        sys.exit("Expected a service name and a private container PID namespace (PID 1).")
    os.chdir("/srv/{}/bin".format(role))
    os.environ["LD_LIBRARY_PATH"] = os.getcwd()
    if role == "douniu":
        os.environ["LD_PRELOAD"] = os.path.abspath("libace_fix2.so")
    for sig in (signal.SIGTERM, signal.SIGINT):
        signal.signal(sig, stop)
    program = "./" + PROGRAMS[role]
    if os.fork() == 0:
        os.execv(program, [program] + args)
    status = 0
    while True:
        try:
            _, status = os.wait()
        except ChildProcessError:
            break
    return os.WEXITSTATUS(status) if os.WIFEXITED(status) else 128 + os.WTERMSIG(status)

if __name__ == "__main__":
    sys.exit(main())
