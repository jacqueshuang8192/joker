"""Create a private Compose environment and application configs alongside docker-compose.yml."""
import argparse
import ipaddress
import os
from pathlib import Path
import re
import secrets
import tempfile


def parse_args(root):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--image-prefix", required=True, help="ghcr.io/owner/repository")
    parser.add_argument("--tag", required=True, help="sha-<40 hex digits> or main")
    parser.add_argument("--advertise-ip", required=True, type=ipaddress.IPv4Address)
    args = parser.parse_args()
    if not re.fullmatch(r"[a-z0-9]+(?:[./_-][a-z0-9]+)*", args.image_prefix):
        parser.error("Use a lowercase image prefix without scheme or tag.")
    if not re.fullmatch(r"[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}", args.tag):
        parser.error("Invalid image tag")
    if args.advertise_ip.is_unspecified or args.advertise_ip.is_multicast:
        parser.error("Supply a unicast IPv4 address reachable by the game client.")
    if (root / ".env").exists() or (root / "runtime").exists():
        parser.error("Configuration already exists. Edit .env or runtime/ in place.")
    return args


def configuration_values(advertise_ip):
    values = {key: secrets.token_hex(24) for key in (
        "DB_PASSWORD", "ROOT_PASSWORD", "DEFAULT_KEY", "SYSTEM_PASSWORD", "SIGN_KEY", "AGENT_PASSWORD")}
    values.update(AES_KEY=secrets.token_hex(8), MT_KEY=secrets.token_hex(8), ADVERTISE_IP=str(advertise_ip))
    return values


def write_runtime_configs(root, runtime, values):
    runtime.mkdir()
    for source in sorted((root / "config").glob("*.in")):
        output = runtime / source.name[:-3]
        output.write_text(re.sub(r"@([A-Z_]+)@", lambda m: values[m[1]], source.read_text()))
        # Compose bind-mounts each file into a container running as uid 10001.
        output.chmod(0o444)


def write_environment(env, args, values):
    env.write_text("IMAGE_PREFIX={}\nIMAGE_TAG={}\nADVERTISE_IP={}\n"
                   "API_BIND=127.0.0.1\nAPI_PORT=8080\nGAME_BIND=127.0.0.1\n"
                   "DB_PASSWORD={}\nDB_ROOT_PASSWORD={}\n".format(
                       args.image_prefix, args.tag, args.advertise_ip,
                       values["DB_PASSWORD"], values["ROOT_PASSWORD"]))


def main():
    root = Path(__file__).resolve().parents[1]
    args = parse_args(root)
    os.umask(0o077)
    values = configuration_values(args.advertise_ip)
    with tempfile.TemporaryDirectory(dir=root) as tmp:
        stage = Path(tmp)
        runtime = stage / "runtime"
        env = stage / ".env"
        write_runtime_configs(root, runtime, values)
        write_environment(env, args, values)
        runtime.rename(root / "runtime")
        try:
            os.link(env, root / ".env")
        except BaseException:
            (root / "runtime").rename(runtime)
            raise
    print("Created .env and runtime/. Keep both private and backed up.")


if __name__ == "__main__":
    main()
