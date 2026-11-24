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

assert len(hall["data"]["douniuKey"]) == 64
routes = [
    ("/goods/queryGoodsList", {"type": "1"}, lambda data: isinstance(data["list"], list)),
    ("/goods/queryExchangeHistory", {}, lambda data: isinstance(data, list)),
    ("/task/getTaskList", {}, lambda data: isinstance(data, dict)),
    ("/gold/getGoldRanking", {}, lambda data: isinstance(json.loads(data), list)),
]
for path, params, shape in routes:
    response = post(path, {**identity, **params}, form=True)
    assert response["returnCode"] == "0" and shape(response["data"]), path
    assert post(path, {**identity, **params, "XYToken": "expired"}, form=True)["returnCode"] != "0"
rounds = "/freeGame/querRoundsByActivityId"
assert post(rounds, {**identity, "activityId": 851}, form=True)["returnCode"] != "0"
own = post(rounds, {"XYUid": 851, "XYToken": "ci-rounds", "activityId": 851}, form=True)
assert own["returnCode"] == "0" and own["data"][0]["content"] == "ci-round"
print("Verified five authenticated hall reads, response shapes and private round visibility")
