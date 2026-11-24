# joker-game-java

Java 23 / Spring Boot 3.5 的游戏服务工程，同一个可执行 JAR 通过 `GAME_ROLE` 选择以下五种角色。

| 角色 | 默认端口 | 作用 | 对应原生实现 |
|---|---|---|---|
| `rooms` | 4700、13600 | 纯 Java 大厅、在线状态、分桌和牛牛。内部端口 4701、7500、11603 供 API 调用 | 大厅、用户服务、分桌及牛牛房间的 302 普通桌流程 |
| `gateway` | 8090 | HTTP `/health` + WebSocket 反代：`/ws/hall`→4700、`/ws/douniu`→13600 | 新增的 Java 网关 |
| `data` | 6001 | 玩家数据：创建/查询/更新/兑换/牌桌，Redis + MySQL 分表 | `native/services/data` |
| `gold` | 6005 | 金币定时落库 | `native/services/gold` |
| `douniu` | 13600 | **牛牛房间服务**：登录、座位、准备、发牌、抢庄、下注、比牌、结算 | `Douniu/bin/DouNiuServerGroup`（C++） |

1Panel 单机部署普通牛牛时，使用 `rooms` 和独立的 `data`。混合部署使用 `douniu` 与原生大厅及分桌通信。两种部署共用同一份牛牛领域代码。[纯 Java 编排](../../deploy/1panel/pure-java.yml) · [部署步骤](../../DEPLOYMENT.md#纯-java-牛牛部署)

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

Java 房间已接入 302 普通明牌抢庄牛牛。1Panel 混合部署使用 Java 的 `data`、`gold` 和 `douniu`，大厅 `hall`、在线用户 `user` 和分桌 `alloc` 仍由原生服务提供。

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

**待补齐和验收的范围**包括癞子及随机癞子、斗公牛射门、外围、道具、俱乐部抽水、其他庄家玩法与原程序的逐局对照，以及原生 alloc 重启后的活动路由恢复。目标部署镜像使用 `DouNiuServerGroup_new`，归档中另一个 `DouNiuServerGroup` 的比牌和结算实现有差异。自定义赔率切流前应与部署使用的二进制和业务数据核对。纯 Java 选桌仅开放已接入的房型，旧赠钻流程所用的用户状态锁、机器人及部分老大厅命令尚未接入。Android、iOS 真机及第三方支付尚未完成端到端验收。

### 联调真实筹码

纯 Java 使用同次发布的 API 和 game-java。混合部署还使用同版本 native。API 启动时执行 Flyway V1 至 V9，V7 补齐牛牛战绩字段，V8 为历史玩家补齐缺失分表记录。V9 保存密码房的加盐校验值。data 和 api 共用网络空间时，独立的房间容器使用 `DATA_HOST=api`，共用网络空间的房间进程使用 `DATA_HOST=127.0.0.1`。每个游戏库使用一个 data 写入实例，启用 gold 时使用同版本的 Java gold。客户端重新打包和旧配置卷的大厅路由升级步骤见 [1Panel Java 部署](../../deploy/java/README.md)。

每局提交前，data 核对开局余额和当前 Redis、MySQL 分表余额。确认时 MySQL 已提交该局所有玩家的筹码和局号，Redis 已同步。数据库拒绝入账或服务失联时，桌子保留在结算阶段，用同一局号重试。根据房间日志中的局号可查询 `joker_douniu_settlement`。记录的 `projected=0` 表示 SQL 已提交，data 会继续补记 Redis。房间在首次发牌前生成该局唯一编号，结算重试与进程重启沿用同一编号。

在混合部署中，Java 房间连接原生 alloc 上报地址和座位数。注册成功后，容器健康检查才通过。房卡桌由 alloc 创建，每桌独立保存房主、邀请码、底注、人数和局数。普通牌可开十人桌，无 JQK 的一副牌最多供八人使用。空桌保留至解散，进行中的牌局会先完成筹码结算。自然打满局数时，alloc 会把桌号、活动和局数登记到 Redis 的 `WAIT_CLOSE_GROUP_NEW`。

混合部署的整栈回归使用新注册的账号，经 HTTP、原生大厅 TCP 和真实 alloc 分桌进行 Java 对局。新账号的初始筹码为零。独立的有筹码测试核对单局广播、个人战绩和 Redis/MySQL 余额，并覆盖重复回执、冲突回滚和强制重启。[整栈测试](../tests/smoke.sh) · [筹码对照与恢复测试](tests/compare.py)

### 房间进程重启后的恢复

在线 Java 牛牛将进行中的桌存入已配置的 Redis。键以 `JOKER_DOUNIU:<场次>:<服务编号>` 开头，保存房间规则、玩家座位、手牌、已确认的抢庄和下注、筹码期初值、局号和结算明细。房间会先保存状态再对玩家广播。快照写入失败时，该桌会暂停并关闭连接，日志记录桌号，恢复 Redis 后重启该房间进程即可从已保存的状态继续。

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
