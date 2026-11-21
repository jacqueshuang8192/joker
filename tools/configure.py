"""Create a private Compose environment and application configs alongside docker-compose.yml."""
import argparse
import configparser
import json
import ipaddress
import os
from pathlib import Path
import re
import secrets
import tempfile
from urllib.parse import quote
from xml.sax.saxutils import escape


def parse_args(root):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--settings", type=Path, default=root / "panel.ini")
    parser.add_argument("--image-prefix")
    parser.add_argument("--tag")
    parser.add_argument("--advertise-ip", type=ipaddress.IPv4Address)
    args = parser.parse_args()
    settings = configparser.ConfigParser(interpolation=None)
    try:
        with args.settings.open(encoding="utf-8") as stream:
            settings.read_file(stream)
        args.image_prefix = args.image_prefix or settings["deployment"]["image_prefix"]
        args.tag = args.tag or settings["deployment"]["tag"]
        args.advertise_ip = args.advertise_ip or ipaddress.IPv4Address(settings["deployment"]["advertise_ip"])
        args.network = settings["deployment"]["network"]
        for section in ("mysql", "mongodb", "redis", "memcached"):
            host = settings[section]["host"]
            if not re.fullmatch(r"[a-zA-Z0-9_][a-zA-Z0-9_.-]*", host) or not 1 <= settings.getint(section, "port") <= 65535:
                raise ValueError("invalid endpoint in [" + section + "]")
            if host.lower() == "localhost" or host.startswith("127.") or host == "0.0.0.0":
                raise ValueError("[" + section + "] needs an address reachable from another container")
        if not re.fullmatch(r"[a-zA-Z0-9_][a-zA-Z0-9_.-]*", args.network):
            raise ValueError("invalid Docker network name")
        if not re.fullmatch(r"[A-Za-z0-9_-]+", settings["mysql"]["database"]):
            raise ValueError("invalid MySQL database name")
        if not settings["mysql"]["user"] or not settings["mysql"]["password"]:
            raise ValueError("fill in [mysql] user and password")
        if bool(settings["mongodb"]["user"]) != bool(settings["mongodb"]["password"]):
            raise ValueError("set both MongoDB user and password")
        if settings["redis"]["user"] and not settings["redis"]["password"]:
            raise ValueError("set the Redis ACL password")
        if any(any(ord(c) < 32 for c in value) for section in settings.sections()
               for value in settings[section].values()):
            raise ValueError("multiline and control characters are unsupported")
    except (OSError, KeyError, ValueError, configparser.Error) as exc:
        parser.error("Check panel.ini (copy panel.ini.example for first install): " +
                     (str(exc) if type(exc) is ValueError else type(exc).__name__))
    args.settings = settings
    if not re.fullmatch(r"[a-z0-9]+(?:[./_-][a-z0-9]+)*", args.image_prefix):
        parser.error("Use a lowercase image prefix without scheme or tag.")
    if not re.fullmatch(r"[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}", args.tag):
        parser.error("Invalid image tag")
    if args.advertise_ip.is_unspecified or args.advertise_ip.is_multicast:
        parser.error("Supply a unicast IPv4 address reachable by the game client.")
    if (root / ".env").exists() or (root / "runtime").exists():
        parser.error("Configuration already exists. Edit .env or runtime/ in place.")
    return args


def configuration_values(args):
    advertise_ip = args.advertise_ip
    values = {key: secrets.token_hex(24) for key in (
        "DEFAULT_KEY", "SYSTEM_PASSWORD", "SIGN_KEY", "AGENT_PASSWORD")}
    values.update(AES_KEY=secrets.token_hex(8), MT_KEY=secrets.token_hex(8), ADVERTISE_IP=str(advertise_ip))
    db = args.settings["mysql"]
    mongo = args.settings["mongodb"]
    auth = ""
    if mongo["user"]:
        auth = quote(mongo["user"], safe="") + ":" + quote(mongo["password"], safe="") + "@"
    uri = "mongodb://{}{}:{}/douyoudb?authSource={}".format(
        auth, mongo["host"], mongo["port"], quote(mongo["auth_database"], safe=""))
    cache = args.settings["memcached"]
    values.update(DB_HOST=db["host"], DB_PORT=db["port"], DB_NAME=db["database"], DB_USER=db["user"],
                  DB_PASSWORD=db["password"], MONGO_URI=uri, MEMCACHED_HOST=cache["host"], MEMCACHED_PORT=cache["port"])
    return values


def write_runtime_configs(root, runtime, values, redis):
    runtime.mkdir()
    for source in sorted((root / "config").glob("*.in")):
        output = runtime / source.name[:-3]
        replacements = values
        if output.suffix == ".xml":
            replacements = {k: escape(v, {'"': "&quot;", "'": "&apos;"}) for k, v in values.items()}
        elif output.suffix in (".properties", ".conf"):
            replacements = {k: v.replace(chr(92), chr(92) * 2) for k, v in values.items()}
        output.write_text(re.sub(r"@([A-Z_]+)@", lambda m: replacements[m[1]], source.read_text()))
        # Compose bind-mounts each file into a container running as uid 10001.
        output.chmod(0o444)

    credentials = runtime / "redis.json"
    credentials.write_text(json.dumps(dict(host=redis["host"], port=redis.getint("port"),
                                           user=redis["user"], password=redis["password"])))
    credentials.chmod(0o444)


def write_environment(env, args):
    env.write_text("IMAGE_PREFIX={}\nIMAGE_TAG={}\nADVERTISE_IP={}\nPANEL_NETWORK={}\n"
                   "API_BIND=127.0.0.1\nAPI_PORT=8080\nGAME_BIND=127.0.0.1\n".format(
                       args.image_prefix, args.tag, args.advertise_ip, args.network))


def main():
    root = Path(__file__).resolve().parents[1]
    args = parse_args(root)
    os.umask(0o077)
    values = configuration_values(args)
    with tempfile.TemporaryDirectory(dir=root) as tmp:
        stage = Path(tmp)
        runtime = stage / "runtime"
        env = stage / ".env"
        write_runtime_configs(root, runtime, values, args.settings["redis"])
        write_environment(env, args)
        runtime.rename(root / "runtime")
        try:
            os.link(env, root / ".env")
        except BaseException:
            (root / "runtime").rename(runtime)
            raise
    print("Created .env and runtime/. Keep both private and backed up.")


if __name__ == "__main__":
    main()
