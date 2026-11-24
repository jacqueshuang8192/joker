# 后端完整性与部署核验

## 2026-11-24 纯 Java 普通牛牛复测

隔离的 Linux/amd64 编排从空库启动了 Java API、数据服务与 `rooms`，并启用了可选的金币服务。真实 HTTP 与 TCP 协议回归覆盖注册、密码房、联盟观战、换人后的两局战绩、两桌同时运行、定向大厅通知和在线查询。结束第一桌后强制终止 `rooms`，第二桌从同一 Redis 恢复并完成剩余牌局。账本对两桌分别记录两局，逐局只有一笔回执，且缓存已补记。筹码非零、提交后丢回执、余额冲突回滚另由账务回归验证。[整栈回归](backend/tests/pure-java.sh) · [账务对照](backend/game-java/tests/compare.py)

本节验证范围为 302 普通牛牛的协议流程。癞子、斗公牛、外围、俱乐部抽水、旧版赠钻用户锁和真机支付仍有功能或验收缺口。下面的原生分桌进程重启记录对应混合部署。[领域边界与玩法范围](backend/game-java/README.md)

## 2026-11-24 原生与混合部署的修复与复测

| 范围 | 修复和验证 |
|---|---|
| 牛牛结算 | 按座位累计分摊整数筹码，对每名玩家和庄家的期末余额设上下限。原审计的 500 局与另 1,000 局边界牌例通过，逐人核对了余额、单人封顶和全桌总和。 |
| 整局入账 | Java data 原子提交全部玩家分表的 chip 与唯一局号回执。Redis 补记完成后才确认整局。真实 Java 双人对局核对了广播、Redis CHIPS、MySQL chip 和独立的钱包 money。相同回执重试、同局号不同内容、第二人余额冲突导致整局回滚、重启补记均有回归。 |
| Java 牛牛重启续局 | 双客户端在发牌并确认抢庄后强制终止房间进程，使用相同场次与服务编号重启，核对两人手牌、抢庄决定和下注。随后由测试转发器暂扣真实 data 的结算成功回执，确认 MySQL 提交后再次强制终止房间；恢复后沿用同一局号，核对返回的手牌、MySQL/Redis 余额和新增回执条数。满局退桌后再重启一次，残留的玩家授权也无法重新打开旧桌。 |
| 入房和客户端协议 | 核对 Redis 中的当前会话、分配场次、桌号及活动。已覆盖两种正常入房包、凭据失效、桌号不符、抢庄和下注阶段消息、断线重连，以及首次发牌与最终亮牌的一致性。 |
| 大厅和 SQL | 商品、兑换记录、任务、财富榜、单局战绩均通过 HTTP 回归，核对了返回类型和私人战绩可见性。MySQL 5.7 上验证了聚合总分、同分名次、代理玩法与配置的对应关系、空销售计数累加。 |
| 首装和原生开房 | Flyway V5 创建结算回执，V6 为全空的玩法目录载入原档中的 302 牛牛。静态大厅名单为空时读取原生 hall 发布的地址。隔离环境使用 API 工程的开房客户端向当前编排的原生 alloc 和 douniu 发出开房请求，取得有效桌号。 |
| 客户端 | Android 桥可读取可选的 joker_api_url 字符串资源，Lua 在未配置时保留 HttpAddr。三个 Android 桥用 SDK 28 和原归档依赖编译。Lua 客户端的传输选择与拆包回归通过。 |

### 密码房、联盟观战与连续退桌

空库升级到 Flyway V9 后有 165 张业务表。使用两个新注册账号，经实际 HTTP、大厅和 Java 房间验证了六位密码开房、错误密码重输、成功后入座、重连，以及两张密码相同的桌分别授权。房规和邀请码查询均未返回房间密码。盟主转让覆盖旧盟主分成比例为空的历史记录，并分别核对了转让前后的观战身份。

客户端带桌号的心跳每两秒经过大厅，与 Java 解码器按同一字节样本核对。普通桌连续两局并更换一名玩家后，总榜包含三人。联盟观战者能在满桌时旁观，玩家亮牌前看不到对手的手牌。

**原生与混合标签的整栈发布检查仍有阻塞。** 在隔离编排中依次测试密码房、联盟房及普通桌，三组业务断言通过，普通桌满局退桌后原生 alloc 进程重启。其 `GameGroup::CancelGroupTable` 在删除映射条目后继续递增原迭代器。当前整栈回归保留了对进程启动时间的检查。正式切换前须验证连续退桌后分桌进程持续运行，以及同一进程内其他活动桌仍可重连。

### 普通牛牛端到端回归

整栈测试在独立 Docker 编排中通过真实 HTTP 注册新账号，使用邀请码、原生大厅 TCP 选桌和 alloc 写入的 Redis 授权进入 Java 房间。第一局由房主和客人打完，两人均能从大厅查询该局手牌。客人离座后新玩家加入，第二局结束时总榜包含先后三名参与者。新注册账号的初始筹码为零。有筹码的输赢核对使用独立的 data/gold 与结算回执回归。

客户端九份普通牛牛协议资源通过 Lua 准备、取消、选座和大厅路由封包检查。Java 牌例覆盖普通房洗牌、同花顺优先级、五小牛的十点边界、五花牛包含十、牛七至牛牛的自定义倍数、推注与断线恢复。Flyway V7 将牌面、个人战绩和余额按局原子保存。V8 补齐历史总表有记录而对应分表缺行的玩家。用同一临时数据库重放 V8 两次，已存在的分表金额保持原值。

**仍需验收**的部分包括移动真机、带癞子牌库、斗公牛射门、非明牌抢庄规则、外围、道具、俱乐部与观战权限、支付以及 alloc 重启时活动路由的恢复。C++ 大厅、用户服务与分配器继续运行。原生 `CancelGroupTable` 在遍历期间删除当前迭代器，完整退桌场景仍有原生程序自身的风险。[原生退桌实现](backend/native/services/alloc/Game/GameGroup.cpp#L1000)

复测入口见 [整栈测试](backend/tests/smoke.sh)、[数据库回归](backend/api/src/test/java/com/j/joker/FlexDatabaseCheck.java)、[整局余额与数据服务回归](backend/game-java/tests/compare.py) 和 [牌例](backend/game-java/tests/SettlementCheck.java)。

## 2026-11-24 修复前的全工程功能复核

本次以本地 `833b0d52` 加当前工作区为准，包含尚未提交的 Java 牛牛。使用 JDK 23、Linux/amd64 镜像、独立 Docker 网络和临时数据库。**基础服务可以部署联调。Java 牛牛尚不能接管正式玩家账务，当前工程也没有通过从真机登录到整局结束的验收。**

### 影响使用的问题

| 优先级 | 功能 | 核验结果 |
|---|---|---|
| 阻塞 Java 牛牛切流 | 结算与余额 | 直接调用当前结算类做 500 次四人桌结算。庄家初始筹码 20，三名闲家各 100，底分 1，闲家下注倍数 2，抢庄倍数 1，随机种子 42。有 113 次庄家期末筹码为负。庄家同时遇到赢家和输家时，赔付分支比较可赔池与净亏损，并用净亏损作分摊分母，未落实庄家余额下限。[结算实现](backend/game-java/src/main/java/com/j/joker/game/niuniu/domain/table/Settlement.java) |
| 阻塞 Java 牛牛切流 | 结算持久化 | 玩家进房读 CHIPS，结算变动写 MONEY，筹码增量写 0。连接使用未解析的地址交给普通 Java Socket，在 JDK 23 的本机监听对照中，正常地址连接成功，同地址的未解析形式抛出 UnknownHostException。首次连接失败会停用该客户端后续访问，进房退回默认筹码。逐玩家写回也缺少整局原子性、结果检查与补记机制，客户端可以收到广播而账务未完成。[数据客户端](backend/game-java/src/main/java/com/j/joker/game/niuniu/infrastructure/DataClient.java) · [结算广播](backend/game-java/src/main/java/com/j/joker/game/niuniu/application/DouniuService.java) |
| 阻塞 Java 牛牛切流 | 身份、房间、断线续局 | 登录协议含 mtkey，但 Java 入房逻辑未核验该凭据或分配器的入房授权，房间按请求中的桌号在本地创建。断线会令闲家离座，重连没有恢复该闲家原手牌和本局参与状态的流程。尚缺道具、外围买牛、推注、解散投票、战绩记录、俱乐部抽水及跨服分配。[入房与断线处理](backend/game-java/src/main/java/com/j/joker/game/niuniu/application/DouniuService.java) · [模块范围](backend/game-java/README.md) |
| 阻塞 Java 牛牛切流 | 玩家所见手牌 | 发牌时已将该玩家的手牌发给客户端，定庄后如预选庄家和实际庄家不同，会交换二者的手牌和评估结果。交换后未向两人重发修正的手牌，可能出现客户端所见与结算用牌不同。[发牌与换牌](backend/game-java/src/main/java/com/j/joker/game/niuniu/domain/table/NiuNiuTable.java) · [客户端发牌消息](backend/game-java/src/main/java/com/j/joker/game/niuniu/application/DouniuService.java) |
| 阻塞对应大厅页面 | 商品、兑换记录、任务、排行、战绩 | 使用新注册账号的有效登录态请求下表五个路径，都返回 404。仓库中仍有客户端调用；商品、排行和战绩的对应 Controller 映射可见注释。能进入大厅不代表这些页面能取得数据。[商品接口](backend/api/src/main/java/com/j/joker/controller/common/GoodsController.java#L104) · [排行接口](backend/api/src/main/java/com/j/joker/controller/gold/GoldController.java#L399) |
| 阻塞开房首装验收 | 业务初始数据 | Flyway 执行后、测试脚本插入样本前，t_game、t_game_config、t_group_game、t_game_server、t_game_type 均为 0 行。开房会查询所选游戏及房间服务配置；找不到游戏会返回“组局游戏配置异常”。原生 alloc 达到健康状态，仍缺真实业务数据下的创建、加入、结算及退房验收。[开房逻辑](backend/api/src/main/java/com/j/joker/service/game/FreeGameService.java#L1167) |
| 影响部分业务 | 排行、代理玩法及二级销售计数 | 对当前 XML 的 SQL 在新迁移的 MySQL 5.7.44 上逐条 PREPARE。默认 ONLY_FULL_GROUP_BY 下，querySingleResult、queryGeRenSingleResult、queryGeRenSingleResult2 和 selectByAgent 均报 1055。increaseSecondLayerSellCount 报 1054，Mapper 使用 second_layer_sell_count，迁移创建 secondLayerSellCount。关闭分组检查也无法修复该列名差异。[排行 Mapper](backend/api/src/main/resources/mapper/TFreeGameSingleresult.xml#L18) · [玩法 Mapper](backend/api/src/main/resources/mapper/TGameTypeGameMapper.xml#L27) · [销售计数](backend/api/src/main/resources/mapper/TSecUserMapper.xml#L107) |
| 影响移动端 | Android 原生桥、iOS 构建 | 主 Android 工程绑定的 CocosCaller 中，wxLogin、loginWithPhone 和 share 等入口只有日志，getHttpAddr 返回手机自己的回环地址。受影响的是经这些桥接方法执行的路径。桌面主版 config.lua 另有默认旧地址。主 iOS 工程引用的 cocos2d_libs.xcodeproj 在预期路径缺失。本次未产出签名移动包，也未验证第三方登录、支付到账或真机开局。[Android 桥](client/platforms/main/AndroidProject/frameworks/runtime-src/proj.android-studio/libcocos2dx/java/src/org/cocos2dx/lib/CocosCaller.java#L256) · [iOS 引用](client/platforms/main/AndroidProject/frameworks/runtime-src/proj.ios_mac/HelloLua.xcodeproj/project.pbxproj#L169) |

| 主版客户端功能 | 按对应方法实际请求的路径 | 结果 |
|---|---|---|
| 商品列表 | GET `/goods/queryGoodsList` | 404 |
| 兑换记录 | POST `/goods/queryExchangeHistory` | 404 |
| 任务列表 | POST `/task/getTaskList` | 404 |
| 金币排行榜 | POST `/gold/getGoldRanking` | 404 |
| 单局战绩 | POST `/freeGame/querRoundsByActivityId` | 404 |

上述五个请求都经 `/hbiInterface` 发出。运行中的 OpenAPI 列出了 107 个路径。接口文档、Lua 文件和数据库表的数量都不能用来推算全站功能完成率。

### 本次跑通的范围

| 范围 | 通过的检查 | 验收边界 |
|---|---|---|
| 构建与部署 | 当前源码构建 api、native、game-java 三个镜像，prepare 能生成配置。主编排启动并能将 data、gold 切换到 Java。 | 本地 Docker 环境；未操作生产 1Panel。|
| 数据库与中间件 | 四次 Flyway 迁移，163 张业务表，重建后保留测试记录。MySQL、Redis、MongoDB、Memcached 连通，通过了 Flex、XML、事务回滚和 JSP 渲染测试。 | JSP 只验证渲染，没有走支付回调和对账。 |
| 登录、大厅、网络 | 用户名注册、重复注册、登录、取会话与大厅引导通过。原生大厅心跳在 TCP 及 WebSocket 两条路径返回相同字节，牛牛上游握手通过。六份客户端 SocketTCP 适配入口和两个桌面版本的拆包测试通过。 | 回归使用协议客户端和 Lua 测试，未操作玩家真机。 |
| 玩家数据与金币 | 同一套测试请求分别交给原生、Java 的 data 和 gold，比较响应、Redis 牌桌和玩家记录、MySQL 分表余额和活动筹码，结果一致。 | 这是 data、gold 的对照，不能覆盖 Java 牛牛调用它们的结算过程。 |
| Java 牛牛基本牌局 | 当前 JAR 的 douniu 角色通过双连接心跳、入座、准备、发牌、抢庄、下注和接收结算广播。 | DouniuCheck 关闭了数据服务，未逐手对照原生牛牛的发牌、赔率和最终余额。该用例也未接入当前镜像发布工作流。 |

1Panel 主编排的 douniu 仍使用原生镜像。大厅、在线用户、房间分配也依赖原生服务。主桌面版含 69 个玩法目录（含变体、备份），部署编排中仅定位到牛牛作为独立的玩法进程。配置还引用 9002 广播、6101 道具及日志、7700 用户缓存等附属端点，默认编排没有对应独立服务。真实玩法覆盖须逐项用匹配的后端和业务记录核验。

11 月 23 日离线包所标记的 game-java 镜像内没有 DouniuService.class，本次从工作区构建的 JAR 已包含它。旧离线包和当前工作区的牛牛能力不同。

复核入口见 [整栈测试](backend/tests/smoke.sh)、[数据与金币对照](backend/game-java/tests/compare.py)、[双人牛牛用例](backend/game-java/tests/DouniuCheck.java) 和 [客户端测试](client/tests/)。

## 2026-11-21 历史审计

检查日期为 2026-11-21。核对范围为原整理目录的整个后端，部署仓库选用 `interface_yuan`、五个 Alloc 原生项目及牛牛程序。原归档保留在部署仓库之外。

## Java 23 迁移核验

`joker-api` 使用 Spring Boot 3.5.16、Java 23 和内嵌 Tomcat 10.1。使用 JDK 23 执行 Maven 清洁构建后，在 Linux/amd64 容器中以普通用户启动同一份可执行 JAR。JAR 包含首页 JSP 和七张支付 JSP，数据库凭据由 Compose 挂载。

在隔离的 Compose 环境中，通过 HTTP 逐张请求七个支付视图，检查返回的表单已经执行 JSP 和 EL。使用合成用户、单价 15 的商品和数量 2 请求 `/sfPay/rongZhouPayOrder`，核对麒麟支付视图的表单字段和数据库订单的金额均为 30。验证止于表单生成。另使用临时登录态读取 `/api-docs`，从生成的 OpenAPI 描述中取得 105 个接口路径。

1Panel 外置服务模式已在隔离的 Docker 网络中验证。测试把 MySQL 5.7.44、启用密码的 Redis 7、启用认证的 MongoDB 4.4 和 Memcached 1.6 放在独立的编排中。应用编排通过容器名连接，Flyway 在专用空库中建成 148 张业务表，第二次执行时跳过已完成的迁移。使用 JAR 内实际的 Mongo 客户端完成集合读取，通过用户服务配置的 Memcached 地址完成写入与读取。大厅、分配、牛牛及可选金币服务均通过容器健康检查。测试覆盖本地 Docker 环境，正式的玩家对局仍需业务数据和客户端验收。

## 文件与构建

将原迁移清单中的 5,089 个后端文件与当前文件重新计算 SHA-256 对比。清单内仅 `Alloc/.DS_Store` 变化，另外发现 9 个新增的 Finder 元数据文件。清单内的业务文件均在且哈希一致。该清单记录的是收到的归档，无法证明最初提供方已经交齐所有模块。

| 组件 | 本次检查结果 | 镜像内容 |
|---|---|---|
| Java API，`interface_yuan` | 用 JDK 8 从清洁源码目录成功生成 WAR。原工程有 807 个 Java 源文件。部署副本将其中 356 个仅含注释或空行的文件移入 `backend/archive/java/`，其余 451 个保留在 Maven 源码目录。归档 WAR 和重建 WAR 均有 469 个应用 class 文件。 | 历史部署基线为 Tomcat 9。当前部署使用 Spring Boot 可执行 JAR、内嵌 Tomcat 和 Java 23，沿用 `/hbiInterface`。 |
| 另一份 Java 工程，`Alloc/interface` | 有 806 个 Java 文件。使用当前 Maven 验证原 POM 时因重复声明 `org.apache.httpcomponents:httpmime:4.5` 在模型校验阶段失败。两个接口工程存在内容差异。 | 选用已编译通过且附带可对照 WAR 的 `interface_yuan`。 |
| 大厅 `CCHallServer` | 核心库、大厅代码和 hiredis 均能重新编译。 | C++ 源码构建，默认启动一个实例，监听 TCP 4700。 |
| 用户 `CCUserServer` | 原依赖目录内的 hiredis 只有库文件。使用同一归档其他模块的 hiredis 源码，处理旧头文件名和编译器兼容性后完成编译。 | C++ 源码构建，监听 7500。 |
| 数据 `CCMDataServerNew` | reactor、数据服务及 Redis 客户端均能编译。原构建脚本依赖固定安装路径的 MySQL 客户端静态库。 | 从源码构建，链接 AlmaLinux 的 MariaDB C 客户端，连接 MySQL 5.7。 |
| 金币 `CCGoldUpdateServer` | 能从源码编译。原始运行目录缺少程序要求的 `config.xml`，原总启动脚本也没有启用它。 | 提供可选 profile 及由源码还原的配置示例；正式游戏编号、更新间隔及业务结果须对照线上资料。 |
| 房间分配 `NewAllocServer` | 主程序、GameLib、Json 源码存在。原 Makefile 引用未附带的 ACE SDK 和绝对路径下的 MySQL 客户端库。 | 从源码构建，采用按校验值固定的上游 ACE 6.3.0 头文件和归档 ACE 动态库。 |
| 牛牛 `Douniu` | 归档只有 bin 和 log，没有完整服务端工程。`libACE.so.6.4.0` 实际是记录目标文件名的短文本，`libACE.so.6.4.8` 的 ELF SONAME 是 `libACE.so.6.3.0`。 | 打包原 Linux x86-64 程序、原启动脚本使用的兼容库，并在镜像内重建库链接。现有材料无法从源码重建牛牛。 |

原包中的其他客户端玩法不能仅凭客户端目录推断服务端齐全。原配置还引用广播、日志、道具、缓存用户等外部端点（例如 9002、6101、7700），未识别出这些端点各自对应的独立可部署程序。实际需要的组合取决于启用的业务流程。

## 数据库完整性

V1 从原始 `数据库.sql` 提取 86 张表的定义。最初核对 Java Mapper 的 70 个表名时，有 36 个在 V1 中未按原名匹配。按代码的路由规则展开后，这 36 项对应 32 张普通表和 4 组分表。

| 来源 | 本次清单对应的物理表 |
|---|---|
| V1 已提供 | `t_point_change_record0` 到 `t_point_change_record9`，按俱乐部 ID 对 10 取余 |
| V2 单表 | 32 张，涉及代理、订单、充值、联盟、活动、战绩和其他业务 |
| V2 分表 | `ims_tpmoney0…9` 按代理 ID 分表，`t_player_task0…9` 和 `t_waiweiorder_history0…9` 按玩家 ID 分表，共 30 张 |

V2 的 62 张表使用 `CREATE TABLE IF NOT EXISTS`。列名、类型和索引的依据来自 MyBatis 的增删改查、结果映射及 Java 实体。原库的精确长度、额外列、约束、触发器和业务数据仍需从匹配的备份核对。例如 `ims_tpcommissions` 的读取条件是 `id=0`，实际三级比例应由业务方提供。脚本保留已有同名表的结构和数据。

在 MySQL 5.7.44 上分别验证了空库建表、从 V1 升级、已有同名自定义表和数据的保留、再次运行 Flyway。另用测试事务核对了联盟成员、任务进度、房卡收益、商品金额、玩家战绩和两类分表的实际读写。对涉及 V2 的 103 条 Mapper SQL，将参数替换为绑定占位符并在服务端预编译。默认 SQL 模式下 99 条通过，4 条被 `ONLY_FULL_GROUP_BY` 拒绝：`TFreeGameSingleresult` 的三个分时段排名查询选取了未聚合的日期，`TGameTypeGameMapper.selectByAgent` 按类型分组时选取了未聚合的玩法配置。仅在临时验证会话放宽该项后，103 条全部通过。运行编排沿用原 SQL 模式。

将 71 个通用 Mapper 迁移至 MyBatis-Flex 1.11.8 时，对比了它们实际使用的 70 种实体。迁移前后，每种实体的表名和属性到列名的映射一致。74 份业务 Mapper XML 继续随 JAR 打包。数据库回归在同一 Spring 事务中执行 Flex 和 XML 读写，并在事务结束后验证两者一起回滚。

V3 补齐了 14 张通用 Mapper 引用的表，覆盖反馈、积分赠送、兑换记录、角色资源等实体。列名和字段类型来自实体及 XML，字符串长度和索引是针对可见读写的兼容定义。V3 还会检查 `t_activity_user` 的两个筹码列，只添加缺少的列。MySQL 5.7.44 空库运行 V1 至 V3 后共 162 张业务表。另一组 V2 升级测试保留了已有反馈表的自定义列、既有筹码列的类型及默认值和测试数据。

代理账号表另有历史命名差异。V1 的 `t_sec_user` 使用 `secondLayerSellCount`、`grandfatherId`、`createDate`，当前实体默认映射到对应的下划线列名，销售计数 SQL 也使用 `second_layer_sell_count`。只含 V1 字段的库在执行这些读写时会报列不存在。V3 保留了该表，后续统一命名需核对线上数据及其他读写方。

部署后，可以在能访问 1Panel MySQL 的机器上执行以下只读检查。将四个变量设置为面板中该业务库的地址、端口、用户和库名，按提示输入密码。无输出表示检查清单中的表和两列均存在。

```sh
mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p "$MYSQL_DATABASE" < tools/check-schema.sql
```

应向项目提供方取回与客户端版本匹配的业务库备份、活动及房间配置、需要的附属服务、牛牛及其他玩法服务源码，并核对发布地址和第三方服务配置。现有静态资料不足以可靠推导这些表的唯一索引、数据约束和初始业务记录。

## 目录重构的回归对照

对照本地基线提交 `7c44813`，用相同的 Linux/JDK 8 环境重新构建 WAR。两份 WAR 的条目名称一致，逐项解压比对后，只有 `GroupGameImpl.class` 内容发生变化。用本机 TCP 模拟服务分别调用普通开房、密码开房、解散和退出接口，16 组样本的请求字节与返回值均与基线一致。该测试核对 Java 编解码；实际玩家的整局流程仍需客户端和配套业务数据验收。

逐字节核对了房间分配器拆出的 9 个赛事函数。重编后的分配器与旧版有相同的 6,228 个已定义全局符号名称。大厅、用户、数据、金币、牛牛五个可执行文件与旧镜像的 SHA-256 分别一致。对配置生成器固定随机输入后，比对了生成内容、权限、参数校验及重复初始化时对已有文件的保护。

## 测试范围

本机使用 Docker 的 Linux/amd64 环境进行镜像构建，启动测试使用独立网络、专属容器和一次性数据卷。在旧库样本上查询版本接口能成功返回版本记录。正式发布流程另用空卷执行全部迁移，在测试库写入一条可辨识的大厅版本号，再经 HTTP 接口读取并比对，覆盖 Spring MVC、MySQL 和 Redis 路径。测试结束后删除该临时项目及其卷。

Flyway 接入后，以 MySQL 5.7.44 和 Flyway Community 11.15.0 在隔离的 Linux AMD64 编排验证。启用金币服务时，空库自动生成 86 张业务表和迁移历史表，再次执行 `migrate` 后仍能通过 HTTP 读取同一测试记录。另一组使用旧初始化脚本建库，在插入测试数据后接入 Flyway。V1 执行前后，86 张业务表导出的结构一致，测试记录保留。临时加入 V2 后重新启动编排可以应用新表；更改已应用的 V2 后，Flyway 校验失败，Compose 阻止 API 启动。当时的 V2 测试脚本只存在于临时目录，当前仓库的 V2 是上文所述的兼容表迁移。该版本 Flyway 在启动日志中提示 MySQL 5.7 已超出 Redgate 社区支持范围。

引入 Flyway 前，默认编排中的 14 个容器通过启动检查；另启用示例 gold 配置复测时，15 个容器也均通过。测试环境内分配服务与牛牛服务分别监听 11603 和 13600。金币样例验证到进程监听，未验证真实余额变动。

迁移前，Java 的 Maven 依赖已在空缓存、空自定义配置下解析，并在 Linux/amd64 用 JDK 8 离线编译通过。当前 Java 23 工程通过 Maven Central 获取依赖，Ping++ 使用 com.pingxx:pingpp-java:2.5.7。部署副本已将发现的固定协议及开户凭据移入运行配置，已对提交的文本执行 Gitleaks 扫描。

原生服务健康检查核对指定端口的监听状态。HTTP 首页用于容器存活检查，业务接口另行验证。真实客户端登录、牌局、结算、支付、生产负载及 1Panel 真机发布尚未验收。归档含第三方支付、短信、云存储等配置，部署仓库使用本机生成的配置文件，保留原通道实现以便按需对接。上线使用的协议密钥还要与客户端配套。
