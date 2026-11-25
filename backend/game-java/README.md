# joker-game-java

Java 23 / Spring Boot 3.5 的游戏服务工程，同一个可执行 JAR 通过 `GAME_ROLE` 选择以下五种角色。

| 角色 | 默认端口 | 作用 | 对应原生实现 |
|---|---|---|---|
| `rooms` | 4700、13600 | 纯 Java 大厅、在线状态、分桌和牛牛。内部端口 4701、7500、11603 供 API 调用 | 大厅、用户、分桌及 302 牛牛房间 |
| `gateway` | 8090 | HTTP `/health` + WebSocket 反代：`/ws/hall`→4700、`/ws/douniu`→13600 | 新增的 Java 网关 |
| `data` | 6001 | 玩家数据：创建/查询/更新/兑换/牌桌，Redis + MySQL 分表 | `native/services/data` |
| `gold` | 6005 | 金币定时落库 | `native/services/gold` |
| `douniu` | 13600 | **牛牛房间服务**：登录、座位、准备、发牌、抢庄、下注、比牌、结算 | `Douniu/bin/DouNiuServerGroup`（C++） |

1Panel 单机部署 Java 牛牛时，使用 `rooms` 和独立的 `data`。混合部署使用 `douniu` 与原生大厅及分桌通信。两种部署共用同一份牛牛领域代码。[纯 Java 编排](../../deploy/1panel/pure-java.yml) · [部署步骤](../../DEPLOYMENT.md#纯-java-牛牛部署)

## DDD 代码结构

| 业务边界 | 规则与用例 | 外部交互 |
|---|---|---|
| 大厅与分桌 | `rooms/domain` 的 `RoomDefinition` 校验开桌条件，`RoomRoute` 表示活动与桌号的绑定。`rooms/application` 的 `RoomAllocation` 处理同活动重试、桌号冲突和退桌，`Lobby` 处理登录、选桌和在线状态。 | `rooms/interfaces/tcp` 接入 API 的分桌、查询和通知，`RedisLobbyAccounts` 读取当前会话和选桌授权。 |
| 牛牛对局 | `niuniu/domain` 的 `NiuNiuTable` 管理牌桌、座位和牌局阶段，`Settlement` 计算每人输赢。`DouniuService` 协调入局、保存和结算。 | `niuniu/interfaces/tcp` 将新旧游戏包解码为操作。`RoomRepository` 由 Redis 快照实现，`RoundAccounts` 由独立的数据服务实现。 |
| API 密码房 | `com.j.joker.rooms.domain.RoomPin` 表达保留前导零的六位口令。`DouniuRoomPasswordService` 协调续开、尝试次数和解锁。 | HTTP 入口沿用旧地址。MyBatis Mapper 保存加盐校验值，Redis 适配器将入房授权绑定到当前活动与会话。 |

**进程边界按故障恢复需要划分。** 大厅选桌和牛牛牌桌使用同一个活动目录，房间快照恢复后即可重新选桌。这样部署一台服务器时，开桌和退桌直接调用应用层接口，无需另起大厅和分桌进程。这是本项目对《凤凰架构》单体章节的应用。[单体系统时代](https://icyfenix.cn/architecture/architect-history/monolithic.html) · [Spring Boot 单体示例](https://icyfenix.cn/exploration/projects/monolithic_arch_springboot.html)

**一局筹码以 MySQL 本地事务为边界。** 发牌前生成唯一局号，结算时一起提交玩家分表余额、回执和单局战绩。`data` 更新 Redis 后将回执的 `projected` 标为 1；进程中断后可从未完成的回执补记。牌桌收不到确认时按原局号重试，余额只扣一次。这里采用《凤凰架构》讨论的最终一致性思路。[分布式事务](https://icyfenix.cn/architect-perspective/general-architecture/transaction/distributed.html)

领域回归将大厅用例、房间与牛牛领域和 API 口令值对象放在只含 JDK 基础模块的类路径编译，随后执行桌号分配与结算测试。仓库中的商城、代理和支付等旧 API 仍沿用原有分层。[领域检查](tests/domain.sh) · [纯 Java 整栈回归](../tests/pure-java.sh)

## 启动

```sh
# 本地离线演示，使用临时筹码
GAME_ROLE=douniu GAME_BIND_ADDRESS=127.0.0.1 DOUNIU_LOCAL_DEMO=true DOUNIU_DATA_ENABLED=0 java -jar target/joker-game-java.jar

# 数据 / 金币 / 网关
GAME_ROLE=data  java -jar target/joker-game-java.jar
GAME_ROLE=gold  java -jar target/joker-game-java.jar
GAME_ROLE=gateway java -jar target/joker-game-java.jar
```

### douniu 角色环境变量

| 变量 | 默认 | 说明 |
|---|---|---|
| `GAME_PORT` / `DOUNIU_PORT` | 13600 | 监听端口；`GAME_PORT` 优先 |
| `GAME_BIND_ADDRESS` | 0.0.0.0 | 绑定地址 |
| `DOUNIU_GAME_CONFIG` | 示例配置 | 本机离线演示的规则。联网桌采用 alloc 为每张桌下发的配置 |
| `DOUNIU_GUODI` | 50 | 本机演示的锅底。联网桌读取该桌规则中的 `guodi`，缺省为 50 |
| `DOUNIU_DATA_ENABLED` | 1 | 1 使用 Java data 的筹码查询和整局入账。0 仅供显式启用的本地演示 |
| `ALLOC_HOST` / `ALLOC_PORT` | 127.0.0.1 / 11603 | 原生 alloc 的内网端点 |
| `DOUNIU_SERVER_ID` | 1802 | 房间进程编号。同一场次的每个运行实例使用不同编号 |
| `ADVERTISE_IP` | 联网模式必填 | 响应大厅选桌时发送给玩家的 IPv4 |
| `DOUNIU_LEVEL` | 302 | 对照 alloc 的 USER_GAME_STATUS 场次 |
| `JOKER_REDIS_CONFIG` | /srv/redis.json | 提供 API 会话与实际分配记录的 Redis 连接 |
| `DATA_HOST` / `DATA_PORT` | `data` / 6001 | `data` 角色地址 |

## 协议

对接 Cocos/Lua 客户端的 TCP 包格式。

- 18 字节大端包头：`len(=总长-4) / "BY" / ver / cmd / gameId / bizId / platform / check`
- 包体使用 256 项字节置换和累加校验。大厅每两秒发送的 `0x110` 心跳按相同规则编码四字节桌号，也可向 Java 房间发送空包探测
- `STRING` 长度含结尾 `\0`；`ARRAY` 不写长度前缀，靠前置计数字段
- 命令表由 `handle/NiuNiuProtocol.lua` 自动解析为 `src/main/resources/protocol.json`（82 条 GROUP_MODE=2 命令）

## 可验收的玩法

纯 Java 房间支持 302 普通牛牛、癞子和斗公牛，可叠加外围买牛及俱乐部赢家抽水。1Panel 混合部署使用 Java 的 `data`、`gold` 和 `douniu`，大厅 `hall`、在线用户 `user` 和分桌 `alloc` 仍由原生服务提供。

| 玩家操作 | 服务端行为 |
|---|---|
| 开房、入房、换座 | HTTP 返回邀请码。纯 Java 分桌在进程内分配桌号，混合版通过原生 alloc 分配。Java 房间验证当前账号凭据和具体活动。玩家可在空闲阶段坐下、站起、准备或取消准备。 |
| 发牌、抢庄和下注 | 普通桌从同一副牌洗牌并发给各座。抢庄、下注、本人推注和超时托管按阶段处理。客户端分别收到显示档位和当前筹码允许的档位。没有可选档时，普通房超时按一倍推进，结算受实际余额限制。 |
| 亮牌、重连 | 服务端广播本人实际手牌，重复确认只生效一次。断线后可以恢复座位、手牌和已确认的操作。亮牌超时后由服务端补亮。房间在登录、重连与开始新局时发送当前局和总局数。 |
| 单局与总战绩 | 每局按唯一局号写入余额、回执、牌面及个人战绩。牌桌可按局回看，大厅 HTTP 对房主和参与玩家开放该房间战绩。总榜按 MySQL 已入账的各局净分汇总，包含中途离桌的玩家。 |
| 解散和桌内消息 | 房间支持过半同意、全员同意或禁止投票。投票中的玩家和截止时间随房间保存。进行中的牌局先结算再退桌。房间处理文字、表情和位置消息。 |
| 联盟观战 | 盟主可在满桌时入场观看公开亮牌和结算。服务端在观战登录和每局开始时复核当前盟主，观战者没有手牌、下注权和投票权。开启高级选项 5 后，开局后只允许首局玩家重新入座。 |
| 密码房 | 在 Java 部署中新建 302 密码房时设置六位数字。房主直接进房，其他玩家和观战者通过登录后的 HTTP 会话验证密码。成功后，同一会话可重连该桌。换桌或重新登录须重新验证。旧房间结束后再切换运行模式。 |
| 自动选庄 | 定庄、轮庄、牛牛坐庄已用固定手牌跑过多局选庄和快照恢复。 |
| 癞子 | `hasLeper=1` 使用大小王，`2` 每局随机选一个点数作为四张癞子。房间广播和重连携带当局癞子，恢复时核对牌库中每张牌的数量。 |
| 斗公牛 | `subGameType=5` 支持开锅、续庄、升庄、下庄和射门。每局先收输分，再按赢家牌力和锅底余额赔付。 |
| 外围买牛 | `waiwei=1` 开启。入座玩家和主动站起的本桌玩家可以下注，站起的玩家可抢外围庄。无人抢庄时，系统全额赔付已接受的订单，系统差额独立记账。 |
| 俱乐部赢家抽水 | 读取当前俱乐部启用的模板，支持比例、固定额、分段、起抽线、并列赢家和合伙人分成。普通桌按整桌游戏净胜分结账，斗公牛按局结账；外围盈亏单独核算。 |

纯 Java 模板可把 `additional_point_from` 设为 `partner`，从本次总抽水中划出额外赠分后再分摊剩余贡献。默认 `player` 按符合条件的赢家扣取额外赠分。

| 纯 Java 功能 | 配置和使用方式 |
|---|---|
| 台费 | 在启用的俱乐部模板设置 `startCost`，单位为筹码最小单位（100 等于 1 积分）。`startCostOneOrAll=0` 每局发牌前收费，`1` 每名玩家在本桌首次实际缴费后免收后续台费。收费上限为该玩家的可用筹码。 |
| 斗公牛上庄、下庄费 | 模板的 `upBankWater`、`downBankWater` 填 0 至 100 的整数百分比。上庄按初始锅底计费，沿用原程序余额临界时的扣费规则。下庄按本次任庄的牌局净赢计费，外围输赢单独核算。各笔费用随独立编号写入 `joker_table_charge` 并计入联盟分成。 |
| 旧版赠钻 | 同步更新客户端大厅资源。玩家退出牌桌后可通过 `/playerXXX` 从本人的钻石钱包赠送，`/queryPlayerXXX` 分页显示赠出或收取记录。每次赠送使用一个请求编号，网络重试沿用该编号。发送方的入桌状态和赠送锁互斥，两边余额和收据在同一事务中保存。 |
| 联盟机器人 | 使用 `groupType=2` 的积分桌模板，并在玩家账号和本联盟成员记录上标记机器人。启用的机器人须有本场次的可用状态和满足门槛的真实筹码。账号及成员的 `is_robot` 均为 1，本联盟的 `robot_status=1` 可初始化空闲缓存，状态 3 表示回收。真人准备时机器人补空座，按当前手牌抢庄、下注。退桌或解散会释放占用，回收操作在下一局准备时生效。 |
| 大厅 | 302 大厅提供场次人数、联盟桌列表和快速加入、禁玩和解禁、在线成员分页和定向邀请。受邀玩家经普通入房校验入座。盟主可在大厅申请解散联盟桌，进行中的一局先完成结算。 |

桌内互动表情按客户端的 `expression` 和 `EmojiArmatureView` 广播，发送人取实际座位，只接受同桌目标及客户端可展示的编号。其他道具及庄家玩法与原程序的逐局对照、Android/iOS 真机及第三方支付仍待验收。目标原生镜像使用 `DouNiuServerGroup_new`，归档中的 `DouNiuServerGroup` 在比牌和结算上存在差异。原生 alloc 重启后的路由恢复属于混合部署验收。

联盟模板支持 `ipXz=1` 拒绝同 IP 入座，`juLi` 以米计。大厅选桌和牌桌实际落座都会检查，已入座玩家的位置随快照保存。IP 来自大厅 TCP 连接。通过 WSS 时按[网关配置](../../deploy/java/README.md#纯-java-大厅获取玩家-ip)传递真实地址，否则房间会把共用网关的玩家识别为同一 IP。旧大厅 `0x151` 返回本场次的公开金币桌、底注与实际座位，列表受旧客户端单包长度限制。房卡、密码和联盟桌仍使用各自的邀请或联盟入口。

### 其他游戏的 Java 实现范围

纯 Java 编排提供 302 牛牛、35 个好友积分桌场次，以及 3 个百人场玩法。35 个场次中含斗地主和跑得快的三种增选模式。好友桌由新版大厅通过 HTTPS 进入，人数到齐即开始，积分和逐局回执存入 MySQL。百人桌使用玩家筹码，101、102 也可用归档的 TCP 桌协议与新版大厅同桌。

| 入口 | 可选场次与计分方式 |
|---|---|
| 牛牛 | 302 快乐牛牛，含癞子、斗公牛、外围与联盟抽水。无人抢外围庄时系统足额赔付，差额独立记账。 |
| 斗地主、跑得快 | 324 房卡说明版斗地主，9324 明牌与个人加倍。325 三人十六张跑得快，9325 双人飘分，9425 三人飘分。 |
| 扑克、牌九、抢庄 | 317 欢乐金花、360 快乐三公、365 新十三水、315 大牌九、318 推锅牌九、368 无限斗公牛的积分锅桌。庄家切锅或本组结束后，连局房可继续下一局。 |
| 分牌、炸弹 | 369 新余510K、381 泰和过炸、397 新化打炸、383 沅江千分。四人对家组队，按该桌的牌副数、炸弹与收墩规则结算。 |
| 麻将、老牌 | 308 红中麻将可配万能红中与抓鸟。329 柳州麻将、320 长沙麻将、371 新余麻将、358 沅江麻将、366 梅州红中宝、389 戳虾子麻将、391 溆浦老牌各有固定积分房规。 |
| 跑胡子、字牌 | 342 常德跑胡子、345 娄底放炮罚、501 汉寿跑胡子、353 邵阳剥皮、359 八一字牌、374 翻三皮、375 碰碰胡、379 沅江鬼胡子、392 溆浦跑胡子、9342 柳州字牌。 |
| 花牌、96扑克 | 388 荆楚花牌采用 112 张花牌字句版，含花素及两张别杠，384 采用 96 张红黑扑克牌。两者分别使用自己的成组和胡息规则。 |
| 百人场 | 101 龙虎、102 神兽、9103 独立百家乐。每种各有经典桌和拼庄桌，分别最多一人和六人上庄。下注有订单编号，封盘后事务更新钱包、回执和占用记录，服务重启继续原局。 |

**独立规则 v1** 使用新版大厅展示的牌具、听胡门槛、赔率和计分方法。举例来说，常德桌选用十五息起胡，汉寿桌选用十八息；新余 510K 使用两副去王牌，可打同花或杂色 510K。368 的锅桌是四人积分房，每组六手封顶。百家乐单副重洗，净赔为庄 1、闲 1、和 8、庄对 11、闲对 11，和局退庄闲本金。9103、9324、9325、9425、9342 是新版分配的编号；归档未能确认柳州字牌的旧编号。地方桌采用文中列出的固定模式，旧版专用客户端、联盟收费模板和地区可选番型仍有差异。当前归档没有可用于逐局比对的历史牌谱。[好友桌目录与规则](../table-rules/src/main/java/com/j/joker/game/tables/domain/FriendRules.java) · [独立牌例](tests/IndependentRulesCheck.java) · [百人桌回归](tests/HundredTableCheck.java)

### 好友桌联机与连局

在新版大厅的游戏栏中点“好友桌”，选择 1、10 或 20 局。房主分享八位房号，同玩法玩家凭房号加入，人齐后开局。双方结算使用本桌局分。每局结束后全员点“准备下一局”才发牌，局间任何人可以结束此桌。客户端重新登录后，点同玩法进入原桌；可在“我的战绩”按账号翻查本玩法已结束的桌、积分与逐手回放。老房间已被覆盖的局只展示积分。

建房或最近一次座位变动后，等候房连续 30 分钟未满员会自动关闭并释放所有座位。查看房间不会延长期限；到期后原房号不能再入座。轮到玩家后 45 秒无操作，API 后台按该玩法托管出牌，全员离线也会推进。局间 15 分钟无人准备或结束时，系统按已结算积分结束此桌。进行中可提议解散，全员同意即保留此前局分并释放座位，当局封存为解散、计零分。任一玩家拒绝或两分钟未达成一致，投票结束，期间出牌继续。

1Panel 继续使用现有 API 端口。API 验证当前会话，按请求者座位返回其手牌、公共牌和可执行的操作。客户端每 1.5 秒查询版本，玩家操作优先发送，迟到的刷新结果会被丢弃。轮到的玩家无操作超过 45 秒后，本桌成员的下一次查询或操作会触发一步托管。MySQL 保存牌序、已接受的操作、版本、下一局首位和继续确认状态。按桌、局、玩家记录积分，小结和累加在同一事务中提交。服务重启后从已提交的版本恢复。规则源码在两个 Java 模块间共用。[规则源码](../table-rules/src/main/java/com/j/joker/game) · [HTTP 联机回归](tests/FriendTableCheck.java) · [大厅触摸回调回归](../../client/tests/friend_table.lua)

**斗地主的复算口径。** 采用 `introduceScene.lua` 中明确标为 324 的房卡说明，底分 1，叫地主可选 1 或 3，每次抢地主翻倍。此实现由叫牌者以外的两席依次选择一次是否抢地主，四张炸弹翻倍，火箭可压所有牌。原文没有明确回抢和火箭的计分细节，这两点仍待原版牌谱核对。另一份玩家说明还描述了随机首叫、明牌与个人加倍，属于另外的规则配置。[房卡说明](../../client/desktop/main/hall/scene/introduce/introduceScene.lua) · [大厅玩法说明](../../client/desktop/main/hall/playerInstruction/PlayerInstructionLayer.json)

从本模块执行以下命令，可复算仓库随附的固定斗地主牌局，以及自己保存的红中麻将胡牌广播。斗地主样例为回归测试构造。麻将输入为每行一条 308 的 `0x6008` 解码结果，选择 `plain`、`red` 或 `opening-red` 对应无红中、万能红中和已确认的起手红中牌局。

```sh
java -cp target/classes com.j.joker.game.landlord.application.ReplayLandlord tests/fixtures/landlord-house.jsonl
java -cp target/classes com.j.joker.game.runfast.application.VerifyRunFast tests/fixtures/runfast-bombs.jsonl
java -cp target/classes com.j.joker.game.mahjong.application.VerifyHongzhong red rounds.jsonl
```

跑得快样例是构造的回归局。每行的 `events` 按原顺序列出本局全部 `0x6005` 出牌与 `0x6006` 过牌消息，每条包含数值 `cmd` 和解码字段。`result` 是 `0x6008` 结算包，`pointUnit` 是一分对应的最小筹码数。工具只验三人十六张、不飘、无额外倍率的基础房。这个工具根据旧广播核算积分。好友桌的实时出牌裁决在共享规则包的 RunFastRound 中。[跑得快协议](../../client/desktop/main/games/pdk/src/protocol/PDKProtocol.lua)

已有原版脱敏牌谱时，可把客户端解码的单局结算消息（`0x6008`）按每行一条 JSON 保存，从本模块运行 `java -cp target/classes com.j.joker.game.hundred.application.VerifyRound 101 rounds.jsonl`。神兽使用场次 102。工具逐局核对庄闲或龙虎和的比牌结果，出现差异时报告行号并退出。

若已同时记录开局庄家列表和本局被接受的全部订单，可使用同一命令并在末尾加 `--accounts`。每行包含 `bankerList`（按上庄顺序，含 `uid`、期初 `chips`）、`bets`（本局全部 `0x4002` 下注广播，含 `uid`、`betType`、`betScore`，工具按客户端换算为最小筹码单位）和 `result`（完整结算包）。它逐人核对 `turnBlc`。Java 按最大余数分配不可整除的最小筹码，同余按上庄顺序。原说明只写了比例，这项取整约定尚无原版牌谱佐证。超出庄家出资的样本会报告错误。[龙虎原规则](../../client/desktop/main/games/longhu100/src/view/WanFaView.json) · [神兽原规则](../../client/desktop/main/games/shenshou100/src/view/WanFaView.json) · [百人场回归](tests/HundredPlayerCheck.java)

百家乐也支持事后复算。将已结算局的六张原始牌序填入 `result.deal`，按闲、庄、闲、庄和最多两张补牌的顺序排列。填写双方实际牌面、点数、对子标志及回执。运行 `java -cp target/classes com.j.joker.game.hundred.application.VerifyRound 9103 tests/fixtures/baccarat-orders.jsonl --orders` 可复算双对、天然八点和局的订单与钱包变化。[固定样例](tests/fixtures/baccarat-orders.jsonl)

百人场回放另支持 `--orders`。在 `--accounts` 的记录中加入各下注区的最小单位限额 `areaLimits`、玩家期初余额列表 `openingChips`（每项含 uid 和 chips），并为每单提供 requestId。工具会在复算前检查接单约束，同一玩家重复提交同编号同内容的订单只计一次。神兽采用每单位下注预留 13 倍的保守口径。示例为构造的测试数据。[订单回放样例](tests/fixtures/hundred-orders.jsonl)

### 联调真实筹码

纯 Java 使用同次发布的 API 和 game-java。混合部署还使用同版本 native。API 启动时执行 Flyway V1 至 V18，V7 补齐牛牛战绩字段，V8 为历史玩家补齐缺失分表记录。V9 保存密码房的加盐校验值。V10 增加外围账本、玩家筹码占用和俱乐部收费明细。V11 建立独立收费流水，为历史赠钻表补充请求编号、双方余额和缓存补记状态。data 和 api 共用网络空间时，独立的房间容器使用 `DATA_HOST=api`，共用网络空间的房间进程使用 `DATA_HOST=127.0.0.1`。每个游戏库使用一个 data 写入实例，启用 gold 时使用同版本的 Java gold。客户端重新打包和旧配置卷的大厅路由升级步骤见 [1Panel Java 部署](../../deploy/java/README.md)。

纯 Java 编排启用 `JOKER_PURE_JAVA` 后，旧接口改余额、购买或兑回筹码时在同一 MySQL 事务内写玩家分表和 V12 的缓存同步标记。data 回复前更新 Redis，进程重启后从分表补记未完成的账号。新版大厅的“兑换筹码”在发送前保存订单号，回包丢失后点“确认原订单”即可。内部 `0x301a` 在原五个整数后可附加 BY 字符串订单号。同一账号、同号同参数返回原始回执；同号改参数拒绝。无编号的原报文按账号、活动、数量和带入额只接受一次成功购买，再次购买相同数量请使用新版入口。

每局提交前，data 核对开局余额和当前 Redis、MySQL 分表余额。确认时 MySQL 已提交该局所有玩家的筹码和局号，Redis 已同步。数据库拒绝入账或服务失联时，桌子保留在结算阶段，用同一局号重试。根据房间日志中的局号可查询 `joker_douniu_settlement`。记录的 `projected=0` 表示 SQL 已提交，data 会继续补记 Redis。房间在首次发牌前生成该局唯一编号，结算重试与进程重启沿用同一编号。

外围的系统庄使用 `dealer_uid=0`。正数表示系统收取，负数表示系统赔付。系统净额可以为负。玩家坐庄和下注时，data 将该玩家的期初筹码绑定到本局，结算、释放占用、登记流水和扣费共用一个 MySQL 事务。普通桌大结涉及已离桌赢家时，如果该玩家在本实例的另一桌对局中，房间会延后扣费并重试。另一桌开下一局前会重新读取该玩家余额。下列查询可在 1Panel 的业务库执行。

```sql
SELECT COALESCE(SUM(dealer_delta), 0) AS system_net_chips
FROM joker_douniu_side_ledger WHERE dealer_uid = 0;

SELECT activity_id, round_index, fee_total
FROM joker_douniu_club_bill ORDER BY activity_id DESC, round_index;
```

API 和游戏服务使用 Java 23 显式启用 Lombok 注解处理，生成构造器、日志字段和简单 JavaBean 访问器。运行容器只需要原有 JRE。规则领域层可直接用 JDK 编译并运行测试。

在混合部署中，Java 房间连接原生 alloc 上报地址和座位数。注册成功后，容器健康检查才通过。房卡桌由 alloc 创建，每桌独立保存房主、邀请码、底注、人数和局数。普通牌可开十人桌，无 JQK 的一副牌最多供八人使用。空桌保留至解散，进行中的牌局会先完成筹码结算。自然打满局数时，alloc 会把桌号、活动和局数登记到 Redis 的 `WAIT_CLOSE_GROUP_NEW`。

混合部署的整栈回归使用新注册的账号，经 HTTP、原生大厅 TCP 和真实 alloc 分桌进行 Java 对局。新账号的初始筹码为零。独立的有筹码测试核对单局广播、个人战绩和 Redis/MySQL 余额，并覆盖重复回执、冲突回滚和强制重启。[整栈测试](../tests/smoke.sh) · [筹码对照与恢复测试](tests/compare.py)

### 房间进程重启后的恢复

在线 Java 牛牛将进行中的桌存入已配置的 Redis。键以 `JOKER_DOUNIU:<场次>:<服务编号>` 开头，保存房间规则、玩家座位、手牌、已确认的抢庄和下注、筹码期初值、局号和结算明细。房间会先保存状态再对玩家广播。快照写入失败时，该桌会暂停并关闭连接，日志记录桌号，检查 Redis 和 data 的日志。在存储与 data 恢复后重启该房间进程，房间会从快照重放尚未确认的收费事件。

使用原 Redis、相同的 `DOUNIU_LEVEL` 和 `DOUNIU_SERVER_ID` 重启。纯 Java 房间启动时恢复，混合版在收到 alloc 注册应答后恢复。抢庄或下注阶段会给玩家 15 秒重连，超时沿用正常托管流程。结算阶段直接用原局号向 data 核账。两局之间的空闲桌保留房间和局数，玩家回来时重新入座并读取当前余额。

纯 Java 回归同时打开两桌，结束其中一桌，再强制终止并重启 `rooms`。另一桌使用原账号重连，继续下一局。脚本从 MySQL 核对两张桌各自的两局回执及 Redis 补记状态。[双桌恢复测试](tests/PureRoomsCheck.java)

首次从没有房间快照的旧镜像升级，请等旧桌结束。同一编号使用一个房间实例。恢复依赖 Redis 保留最新快照和入房授权，部署时将其纳入持久化和备份，避免这些键被清理或淘汰。Redis 数据丢失、旧备份回滚、原生 alloc 同时重启均需另行核对。

## 测试

```sh
# 编译
mvn -q package

# 网关代理与 data/gold 对照测试（原有）
java tests/GatewayCheck.java target/joker-game-java.jar
# 对照测试还使用同一工作区的 API JAR 和测试类
mvn -q -f ../api/pom.xml package
python3 tests/compare.py joker-native:local joker-game-java:local

java -cp target/classes tests/SettlementCheck.java

# 牛牛角色：心跳→双人登录→准备→发牌→抢庄→下注→结算
java -cp target/classes tests/DouniuCheck.java target/joker-game-java.jar
```
