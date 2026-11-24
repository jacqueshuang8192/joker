# 1Panel 切换 Java 游戏服务

部署纯 Java 普通牛牛请使用独立的单文件编排。大厅、分桌、在线查询和牌桌由同一个 Java 进程处理。下表列出原生与混合部署的对应关系，本文的 WSS 网关也适用于纯 Java 编排。[纯 Java 编排](../1panel/pure-java.yml) · [安装、验收和切换步骤](../../DEPLOYMENT.md#纯-java-牛牛部署)

| 服务 | 原生部署 | Java 混合部署 |
|---|---|---|
| 登录、注册、后台 HTTP 接口、Flyway | joker-api | 同一个 joker-api |
| 玩家游戏数据 data，内部 TCP 6001 | C++ | Java 23 |
| 可选金币落库 gold，内部 TCP 6005 | C++ | Java 23 |
| 大厅 hall、房间分配 alloc、在线用户 user | C++ | C++ |
| 牛牛 douniu | 原 Linux amd64 程序 | 1Panel 默认原生。联调可设 `DOUNIU_RUNTIME=game-java`，并使用 Java data |
| 客户端接入 | 原 TCP | 可继续用 TCP，也可加 Java 网关使用 WSS |

## 部署或切换

1. 使用包含本次改动的同一次 Actions 发布。在 1Panel 按原部署手册准备四项基础服务，并使用主编排。源码版填写 `IMAGE_TAG=sha-完整提交号`，下载该次 Actions 部署包时主编排已经写入标签。[主编排](../1panel/docker-compose.yml)
2. 选择原生版时使用默认设置。选择 Java 混合版时，在**主编排**的环境变量里增加一行 `DATA_GOLD_RUNTIME=game-java`，保存并重建。路径部署则把同一行加到部署目录的 `.env`。Java 读取原来的 data.xml、gold.xml 和 redis.json。两种实现使用相同的 Redis、MySQL 分表和服务端口。请在一局结束并暂停新对局后切换，等原金币服务完成最后一个更新周期。
3. `gold` 沿用可选 profile。需要金币定时落库时，先核对原部署手册中的 `runtime/gold.xml` 并启用 `gold` profile。若业务要求 **data 自动通知 gold**，还需在实际 data.xml 的对应 GAME 里，在 RedisList 后、DBList 前添加 `<UpdateServer ip="127.0.0.1" port="6005"/>`，重建 data。默认模板未指定该端点，仅启动 gold 不会产生更新。
4. 在 1Panel 的容器列表查看 data 和已启用的 gold。Java 版的镜像名应为 `joker-game-java`，状态应为 healthy。切回 C++ 时将主编排的 `DATA_GOLD_RUNTIME` 改为 `native`，在同一维护窗口重建服务，并保留已有配置卷和数据库。

### 在测试环境切换牛牛房间

当前编排的原生 alloc 在连续对局满局退桌测试中发生重启，可能影响同一场次其他房间的分配与重连。下列步骤用于联调环境。

在 1Panel 主编排使用同一次构建的 api、native、game-java 镜像。确认没有进行中的对局后，在主编排环境变量填入以下两行并重建。保留原有 `ADVERTISE_IP` 和数据库连接参数。

```dotenv
DATA_GOLD_RUNTIME=game-java
DOUNIU_RUNTIME=game-java
```

1. 在 1Panel 确认 `api` 已完成 Flyway V9，`hall-4700` 和 `douniu` 均显示 healthy。
2. 检查配置卷的 `runtime/hall-server.xml`。302 场次应同时有 `gameID="1"` 和 `gameID="0"` 两个 Node，均指向同一个 alloc。面板粘贴模式的 prepare 在 `PANEL_INI` 完全相同时会沿用卷内文件。旧卷若只有 1，备份该文件，复制现有 302 的 Node 并把副本的 gameID 改为 0，保存后重建 `hall-4700`。全新卷会直接使用新版模板。[大厅配置模板](../../config/hall-server.xml.in)
3. 在本次源码实际打包的 `config.lua` 中设置 `JAVA_DOUNIU = true`，重新导出桌面资源或重打移动包，并重新登录。新版客户端将大厅消息发往路由 0，与 alloc 回包一致。使用两个账号创建、加入同一个邀请码房间，依次核对准备、结算和战绩。密码房可在 302 开房页勾选“设置六位密码”，再用第二个账号核验输错重试、入座和重连。
4. 切回原生前先结束活动桌。将 `DOUNIU_RUNTIME` 恢复为 `native`，客户端使用 `JAVA_DOUNIU = false` 的资源重新登录。data 与 gold 的切换见上方步骤。

## 可选的 WSS 客户端接入

1. 在 1Panel 创建第二个编排并粘贴本目录的 Compose，沿用主编排的 `IMAGE_TAG` 和 `PANEL_NETWORK`。若部署包中已预填镜像标签，可省略 IMAGE_TAG。网关默认从面板网络访问 `api:4700` 和 `api:13600`。同一网络部署多套游戏时将 `GAME_HOST` 填为目标 API 容器名。[网关编排](docker-compose.yml)
2. 在游戏域名的 HTTPS 网站下，将 **/ws/** 路径反代至 `http://127.0.0.1:8090`。如果 OpenResty 是接入同一外部 Docker 网络的独立容器，使用 `http://joker-gateway:8090`。转发时保留完整的 `/ws/hall` 和 `/ws/douniu` 路径，开启 WebSocket 支持。继续将 `/hbiInterface/` 转发给原 API。
3. 域名使用 Cloudflare 代理时，为源站设置有效的 HTTPS 证书，用 443 接入并允许 WebSocket 升级。部署新客户端资源，在实际打包使用的 `config.lua` 里填写下方配置，并将现有 HTTP 接口地址同步指向自己的 HTTPS 地址。旧客户端继续通过原 TCP 端口连接，因此继续保留它们所需的监听地址和放行规则。大厅的 `ADVERTISE_IP` 仍填写 IPv4，更新后的客户端对 4700 和 13600 两个端口使用配置中的 WSS 域名。[Cloudflare WebSocket 文档](https://developers.cloudflare.com/network/websockets/)
4. 在宿主机执行 `curl -fsS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8090/health` 应返回 200。检查域名反代时，从实际客户端登录、进入大厅和房间，在网站访问日志中确认两个路径的升级状态为 101。网关只在能连接对应 TCP 上游时接受升级，上游不可达会返回 502。正式切流前还应使用目标 Android、iOS 或桌面运行时验证 TLS 信任链、对局和断线重连。

```lua
GAME_WSS_URL = "wss://game.example.com"
HttpAddr = "https://game.example.com/hbiInterface"
```

经网关接入时，原生进程看到的 TCP 对端地址是网关的内网 IP。需要基于玩家真实 IP 判断的业务，应单独核对。

上例中的域名换成自己的。去掉 GAME_WSS_URL 配置并重新发布客户端资源即可切回原 TCP。

## 从源码构建和核验

在仓库根目录使用 JDK 23、Maven、Docker。Actions 对 PR 运行检查，对 main 和版本标签发布同一提交的 api、native 和 game-java 镜像。

```sh
mvn -B -f backend/game-java/pom.xml clean package
docker build --platform linux/amd64 -t joker-game-java:local -f backend/game-java/Dockerfile .
java backend/game-java/tests/GatewayCheck.java backend/game-java/target/joker-game-java.jar
```

本机有对应原生镜像时，运行下面的对照测试，把示例中的 joker-native:local 换成本机标签。测试创建独立 Docker 网络及临时 MySQL、Redis，并在退出时清理。它会验证数据服务的创建、查询、更新、兑换、牌桌和删除操作，以及金币服务两条写入指令。测试数据包含大于 32 位整数的余额。

```sh
mvn -B -f backend/api/pom.xml package
python3 backend/game-java/tests/compare.py joker-native:local joker-game-java:local
```

普通牛牛的开房、邀请码入房、原生大厅分桌、双人结算和战绩已在隔离 Docker 环境用协议客户端联通。Java 房间进程重启可以从相同场次、服务编号和 Redis 的快照恢复。正式切换前仍需使用目标客户端及业务规则验收，尤其是非明牌抢庄玩法及俱乐部抽水规则。[当前功能与验证范围](../../backend/game-java/README.md#可验收的玩法)
