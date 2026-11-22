"""Exercise username credentials against the disposable smoke database."""
import concurrent.futures
import json
import secrets
import sys
from urllib.parse import urlencode
from urllib.request import Request, urlopen


def post(path, data, form=False):
    body = urlencode(data) if form else json.dumps(data)
    content_type = "application/x-www-form-urlencoded" if form else "application/json"
    request = Request(sys.argv[1] + path, data=body.encode(), headers={"Content-Type": content_type})
    with urlopen(request, timeout=15) as response:
        return json.load(response)


name = "Smoke_" + secrets.token_hex(5)
password = secrets.token_hex(12) + "A"


def auth(action, username=name, pwd=password):
    return post("/playerUser/username/" + action, dict(username=username, password=pwd, device=2))


with concurrent.futures.ThreadPoolExecutor(2) as pool:
    registrations = list(pool.map(lambda _: auth("register"), range(2)))
assert sorted(r["returnCode"] for r in registrations) == ["0", "1"]
assert auth("register", name.upper())["returnCode"] == "1"
assert auth("register", "1234")["returnCode"] == "1"
assert auth("register", pwd="short")["returnCode"] == "1"
assert auth("login", pwd=password.lower())["returnCode"] == "1"
assert auth("login", username="unused_" + secrets.token_hex(5))["returnCode"] == "1"
session = auth("login", name.upper())
assert session["returnCode"] == "0"
identity = {"XYUid": session["data"]["userId"], "XYToken": session["data"]["token"]}
hall = post("/playerUser/getUserInfo4GameServer", identity, form=True)
assert hall["returnCode"] == "0"
assert int(hall["data"]["playerProfile"]["userId"]) == identity["XYUid"]
assert hall["data"]["mtKey"] and int(hall["data"]["hall"]["port"]) == 4700
catalog = post("/gold/getGameTypeByRoomType", identity, form=True)
assert catalog["returnCode"] == "0" and isinstance(catalog["data"], dict)
print("Verified unique registration, credentials, player session and hall bootstrap")
