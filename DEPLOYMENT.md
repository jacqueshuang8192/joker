# Joker 后端 · 1Panel 部署手册

## 纯 Java 牛牛部署

这套编排使用 Java 23 的 API、大厅、分桌、在线查询、牛牛房间和数据服务。常驻容器为 `api`、`rooms`、`data`，使用 `joker-api` 和 `joker-game-java` 两种镜像。以下步骤适用于单机 Linux amd64 的 302 牛牛，包含癞子、斗公牛、外围和俱乐部赢家抽水。[纯 Java 单文件编排](deploy/1panel/pure-java.yml)

1. 在 1Panel 安装 MySQL、Redis、MongoDB 和 Memcached。为游戏单独建一个 MySQL 库和有建表、迁移、读写权限的账号。让这四项服务通过同一面板网络或内网地址可达，启用 Redis 持久化。网络和权限示例见本文第 2 节。
2. 在对应提交的 GitHub Actions 中查看 **Verify and publish pure Java images**。该任务成功后，下载 `1panel-pure-java` 并解压，将其中的 `docker-compose.yml` 粘贴到 **容器 → 编排 → 创建编排 → 编辑**。文件已固定本次提交的镜像标签。直接使用源码编排时，填写 `IMAGE_TAG=java-sha-完整提交号`。如需始终拉取 main 分支最近一次通过纯 Java 验证的版本，填写 `IMAGE_TAG=java-main`。两张镜像的名称分别为 `ghcr.io/jacqueshuang8192/joker-api` 和 `ghcr.io/jacqueshuang8192/joker-game-java`。
3. 设置下表的环境变量，然后创建编排。`prepare` 成功退出后，`api` 启动并执行 JAR 内的 Flyway 迁移。确认 `api`、`data`、`rooms` 均为 healthy。玩家 HTTP 入口为 `/hbiInterface/`，默认反向代理到宿主机 `127.0.0.1:8080`。普通 TCP 客户端需要能连到 `4700` 和 `13600`。使用域名和 WSS 时可另开同一 Java 标签的网关。[WSS 配置](deploy/java/README.md)
4. 发布包含本次大厅登录改动的客户端资源，设置 `JAVA_DOUNIU = true` 和实际的 `HttpAddr`。重新登录后，API 下发 `pureJavaHall` 及当前会话的游戏凭据。用两个账号创建和加入同一张普通牛牛桌，完成一局，再从大厅核对战绩。[客户端部署说明](client/README.md)

| 环境变量 | 如何填写 |
|---|---|
| `ADVERTISE_IP` | 玩家可达的 IPv4。旧客户端选桌协议要求 IPv4，WSS 域名填在客户端的 `GAME_WSS_URL`。 |
| `PANEL_NETWORK` | 实际 Docker 网络名，默认 `1panel-network`。 |
| `MYSQL_HOST`、`MYSQL_DATABASE`、`MYSQL_USER`、`MYSQL_PASSWORD` | MySQL 内网主机、专用库、账号、密码。 |
| `REDIS_HOST`、`REDIS_USER`、`REDIS_PASSWORD` | 游戏专用 Redis 的地址和认证信息。使用默认用户时可留空用户名。 |
| `MONGO_HOST`、`MONGO_USER`、`MONGO_PASSWORD`、`MONGO_AUTH_DATABASE` | MongoDB 内网地址、账号、密码、认证库。业务库为 `douyoudb`。 |
| `MEMCACHED_HOST` | Memcached 的内网主机。上述四项服务使用自定义端口时，填写编排中各自的 `*_PORT`。 |

`prepare` 从游戏镜像自带模板生成独立的 `settings/runtime-java`，沿用同一卷的 `keys.json`。API 的 `hall.port=4701` 用于同一编排内的通知，玩家仍连 4700。配置中的玩家数据 6001、在线查询 7500、分桌 11603 也走容器回环。纯 Java 的换筹码、兑回和牌桌结算都由 `data` 写玩家分表，可选的 `gold` 用于兼容旧通知。V12 的 `joker_player_cache_sync` 保存已提交、待同步到 Redis 的账号。

旧环境切换前应核对 Redis 的 `MEMDATA_<uid>` 与 MySQL 的 `bullfight_gameinfo<uid % 10>`。两边余额有差异时先按原账单对账，旧接口的后续交易可能因期初值不一致被拒绝。

**从原生或混合版切换**时，先停止新开房，等旧桌结清，备份四项基础服务中需要保留的数据、`settings`（包含 `keys.json` 和运行配置）及 `uploads`。停止旧游戏和数据写入进程，再启动纯 Java 编排。使用旧数据时复核业务密钥、外部服务参数、数据库里的静态大厅路由和客户端版本。首次切换及模板或连接参数发生变化时，初始化会重新生成运行配置，需将自定义的短信、微信、支付等参数从备份合入 `runtime-java/api.properties`并重建相关容器。保留原编排和对应镜像 SHA 以便退回。两套环境同时做对照时，分别使用独立的数据库、Redis、卷和宿主机端口。

### 部署好友积分桌

同一套编排提供 35 个好友桌场次和龙虎、神兽、百家乐三个百人场。部署同一次构建的 API 和 game-java 镜像，确认 API 日志已完成 Flyway V18。发布配套客户端的大厅资源，包含 `ItremGame.lua`、`FriendTable.lua`、`HundredTable.lua`、`ChipPurchase.lua` 和 `network/Request.lua`。保留现有 `/hbiInterface/` 反向代理。重新登录后，在游戏栏选择“好友桌”或“独立规则 · 好友桌”，房主创建后分享八位房号。百人场直接选择经典桌或拼庄桌，至少一名达到门槛的玩家上庄后开放下注。V15、V16 会建立六张默认百人桌的配置记录。好友桌复用 V13、V14 的存储，每次开桌自动生成房号。将下面的示例房号替换为实际房号，即可在业务库查询每局净分。

```sql
SELECT round_no, uid, points FROM joker_friend_round_score
WHERE code = 12345678 ORDER BY round_no, uid;
```

V17 增加筹码购买回执、解散投票和牌谱。升级后登录大厅，通过“兑换筹码”购买或确认原订单，在好友桌的“我的战绩”查看已结束牌局。升级前已覆盖的旧牌谱只能查看积分。切换 V17 时，先核对旧客户端已发出但尚未收到结果的筹码购买；这些交易没有可供新版本查询的订单号。

好友桌按局和整桌累计积分。原 302 的联盟、收费和钱包仍走牛牛服务。好友桌覆盖的规则选项见[玩法清单](backend/game-java/README.md#其他游戏的-java-实现范围)。

## 原生与混合部署

以下章节使用 `joker-api` 和 `joker-native`，并介绍可选的 Java 数据或牛牛服务。示例部署目录为 `/opt/joker`，编排名为 `shenshou`。[Java 混合部署与回退](deploy/java/README.md)

## 在 1Panel 直接粘贴已发布版本的编排

新建实例可使用[单文件编排](deploy/1panel/docker-compose.yml)。请选用已内置初始化脚本和配置模板的 `joker-native`，并搭配同次发布的 `joker-api`。Actions 部署包已填好两张镜像的 SHA 标签。直接使用源码中的编排时，需在环境变量区填写该次发布的 `IMAGE_TAG`。在 **容器 → 编排 → 创建编排 → 编辑** 中粘贴全文，在环境变量区填写 `ADVERTISE_IP` 和 `MYSQL_PASSWORD`。按实际情况填写 `PANEL_NETWORK`、`MYSQL_HOST`、`MYSQL_DATABASE`、`MYSQL_USER`、`MONGO_HOST`、`MONGO_USER`、`MONGO_PASSWORD`、`MONGO_AUTH_DATABASE`、`REDIS_HOST`、`REDIS_USER`、`REDIS_PASSWORD` 和 `MEMCACHED_HOST`。四个服务的端口均可配置。镜像拉取后，`prepare` 直接在无网络的容器内生成配置。已验证环境为 Docker Engine 27.3.1 和 Compose 2.29.7。

启动后 `prepare` 成功退出，`api` 在启动期间执行 Flyway 并进入健康状态。备份 `settings`、`uploads` 及数据库。修改连接参数后重新创建整个编排，以便各服务挂载新配置。已有实例请按第 6 节更新，以沿用原有协议密钥、业务配置和数据库历史。从下载模板的旧版编排升级时，请沿用原编排名和 `settings` 卷，并同时更新编排和镜像标签；旧镜像缺少新版编排使用的初始化脚本。

## 首次部署，按这三步操作

1. 在 Linux x86_64 服务器上用 1Panel 准备 MySQL、MongoDB、Redis、Memcached，创建 MySQL 业务库（默认 `shenshou_game`）。记下四个服务可达的内网地址或容器名、凭据和 Docker 网络名。
2. 从对应版本的 GitHub Actions 下载 `1panel-deploy`，解开网页下载的 ZIP，把里面的 `1panel-deploy.tar.gz` 上传并解压到新目录 `/opt/joker`。在该目录执行以下命令，只编辑一次 `panel.ini`。发布包已填好两张镜像对应的提交标签。启动前运行 `docker compose config --images`，确认业务镜像是 `ghcr.io/jacqueshuang8192/joker-api` 和 `ghcr.io/jacqueshuang8192/joker-native`，两者的 SHA 标签应相同。迁移 SQL 随 API 镜像发布。[镜像构建工作流](https://github.com/jacqueshuang8192/joker/actions/workflows/images.yml)

   ```sh
   cd /opt/joker
   install -m 600 panel.ini.example panel.ini
   vi panel.ini
   python3 tools/configure.py && docker compose config --quiet
   ```

   填写 `network`、玩家可达的 `advertise_ip` 和四项服务的连接信息。准备让外部玩家连接时，把 `game_bind` 填成宿主机网卡 IPv4 或 `0.0.0.0`。API 默认供本机反向代理使用。
3. 在 **容器 → 编排 → 创建编排 → 路径选择** 中选择 `/opt/joker/docker-compose.yml`，名称填 `shenshou`，启动。Spring Boot 完成迁移并通过健康检查后，游戏服务自动启动。为客户端配置 HTTPS 反向代理到 API，放行游戏 TCP `4700` 和 `13600`。[1Panel 编排说明](https://github.com/1Panel-dev/docs/blob/v2/docs/user_manual/containers/compose.md)

所有服务都定义在 `docker-compose.yml`。请保留运行配置的目录层级。服务器需有 Python 3 和 Docker Compose v2。私有 GHCR 包需在 1Panel 中登录 `ghcr.io` 并具备两个镜像的读取权限。已有部署看第 6 节。

## 2. 准备 1Panel 基础服务

| 服务 | 安装后需要确认的内容 |
|---|---|
| MySQL | 创建专用库，例如 `shenshou_game`，字符集选择 `utf8mb4`。为业务账号授予该库的读写、建表、建索引和 `ALTER` 权限，允许应用从 Docker 网络连接。Flyway 使用同一账号。 |
| MongoDB | 记下主机、端口和认证库。应用读写 `douyoudb`。在 `admin` 创建的用户填写 `auth_database = admin`，并给它 `douyoudb` 的读写权限。 |
| Redis | 使用游戏专用实例。记下密码；使用具名 ACL 用户时还需用户名。Java 和可从源码构建的原生服务从 `runtime/redis.json` 读取连接信息，直接向 Redis 认证。预编译牛牛由其启动进程在回环地址适配认证。 |
| Memcached | 记下内网地址和端口，允许游戏服务从其 Docker 网络访问。当前配置使用直接 TCP 连接。 |

已联调的组合为 MySQL 5.7.44、MongoDB 4.4、Redis 7、Memcached 1.6。Flyway 会提示 MySQL 5.7 已超出社区支持范围。其他数据库版本需在匹配的业务库副本上验收。

在 **1Panel → 容器 → 网络** 查实际网络名。四项服务若位于同一 Docker 网络，配置中使用其真实容器名或网络别名，以及**容器内端口**。独立服务器上的服务填写游戏容器可达的内网地址。可用下面两条命令核对网络和容器名。

```sh
docker network ls
docker ps --format 'table {{.Names}}\t{{.Networks}}\t{{.Ports}}'
```

## 3. 填写配置，生成运行文件

```sh
cd /opt/joker
install -m 600 panel.ini.example panel.ini
vi panel.ini
```

| `panel.ini` 段 | 填写方式 |
|---|---|
| `[deployment]` | `network` 填实际外部网络名；`advertise_ip` 填**玩家能连到的 IPv4**；`image_prefix` 和 `tag` 沿用所用包的预填值，`game_bind` 填游戏端口监听地址。 |
| `[mysql]` | 填 `host`、`port`、`database`、`user`、`password`。常用端口为 `3306`。 |
| `[mongodb]` | 填 `host`、`port`、`auth_database`。开启认证时同时填写 `user` 和 `password`。常用端口为 `27017`。 |
| `[redis]` | 填 `host`、`port` 和实际密码。仅使用密码认证时 `user` 留空。常用端口为 `6379`。 |
| `[memcached]` | 填 `host` 和 `port`，常用端口为 `11211`。 |

密码按原文填写，由脚本处理转义。四项服务的 `host` 都应指向服务的可达地址。容器里的 `127.0.0.1` 是容器自身的回环地址。

```sh
python3 tools/configure.py
docker compose -p shenshou config --quiet
docker compose -p shenshou config --images
```

脚本生成 `.env` 和 `runtime/`。后一个目录含数据库凭据、`api.properties`、游戏配置和首次随机生成的协议密钥，连同 `panel.ini` 一起私密备份。已有 `.env` 或 `runtime/` 时脚本会停止。后续修改实际运行文件，再重建相关容器。

**玩家需要连到哪些端口？**

| 用途 | 配置和放行方式 |
|---|---|
| Java HTTP API | `.env` 默认 `API_BIND=127.0.0.1`、`API_PORT=8080`，供宿主机访问。网站反向代理使用上游能到达的地址，保留 `/hbiInterface/` 路径。若 OpenResty 使用独立容器网络，可将其接入同一外部网络，使用 `http://api:8080` 作为上游，从代理容器验证可达性。游戏服务与 `api` 共用网络。 |
| 大厅和牛牛 | `.env` 默认 `GAME_BIND=127.0.0.1`。首装时在 `panel.ini` 设置 `game_bind`，已有部署在 `.env` 修改。对外服务时可用宿主机实际网卡 IPv4，或按部署需要使用 `0.0.0.0`。在云安全组、服务器防火墙和必要的 NAT 规则中放行 TCP `4700`、`13600`。`ADVERTISE_IP` 仍须是玩家可达的具体 IPv4。 |

接入已有客户端前，应核对 `runtime/api.properties` 中的 `protocol.aesKey`、`protocol.defaultKey`、`protocol.mtKey`，并对齐大厅配置中的 KEY。已有系统迁移时沿用配套密钥。若调整公告 IP，同时检查 `.env` 和 `runtime/hall-config.xml`。

## 4. 从面板启动编排

打开 **容器 → 编排 → 创建编排**，选择 **路径选择**，填写名称 `shenshou`，选择 `/opt/joker/docker-compose.yml` 并启动。路径选择能让面板读到同目录的 `.env` 和挂载文件。[1Panel 编排说明](https://github.com/1Panel-dev/docs/blob/v2/docs/user_manual/containers/compose.md)

若使用终端部署，在 `/opt/joker` 执行下面两条命令即可。面板和终端管理同一个实例时，始终使用同一编排名，避免创建第二套容器和上传卷。

```sh
docker compose -p shenshou pull
docker compose -p shenshou up -d
```

Flyway 先执行待应用的迁移。空库依次执行 V1 至 V18，得到 **180 张业务表**及 `flyway_schema_history`，并写入 302 牛牛目录和开房选项。已有 V3 的库继续执行 V4 至 V18。其他玩法、商品、版本记录和第三方渠道参数请从匹配的业务备份恢复或由运营方配置。原始历史 SQL 含删表语句，恢复时先在独立库核验。

可选的 `gold` 服务默认关闭。需要金币更新功能时，根据实际游戏编号和更新间隔核对 `runtime/gold-example.xml`，将确认好的配置保存为 `runtime/gold.xml`，再运行 `docker compose -p shenshou --profile gold up -d`。启用后在后续更新中沿用该 profile。

## 5. 验收

```sh
cd /opt/joker
docker compose -p shenshou ps -a
docker compose -p shenshou logs --tail=80 api
curl -fsS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/hbiInterface/index.html
curl -fsS 'http://127.0.0.1:8080/hbiInterface/version/queryVersion?type=2&interfaceType=J'
```

- 在 `api` 日志中检查 Flyway 成功应用迁移或确认数据库已是最新版本。`api`、`user`、`data`、`alloc`、`douniu` 和 `hall-4700` 应进入健康状态。
- 首页预期 HTTP `200`。如果改过 `API_BIND` 或 `API_PORT`，替换上面两个 URL 的地址和端口。版本接口应有业务响应；要核对版本号，库中须有有效的大厅版本记录。
- 在 1Panel 的 MySQL 管理工具中选中游戏库，执行下列 SQL。使用本版 API 新建空库时应看到版本 `1` 至 `18`，且 `success` 均为 `1`。还可在同一库执行部署包的 `tools/check-schema.sql`，两个结果集都为空表示清单中的表和筹码列齐全。

```sql
SELECT version, description, success
FROM flyway_schema_history
WHERE type = 'SQL'
ORDER BY installed_rank;
```

最后从玩家所在网络，用测试账号依次验证登录、进大厅、开房、加入、结算及断线重连。若要启用支付或代理业务，还需单独验收渠道回调和账号读写。代理账号表 `t_sec_user` 有历史列名差异，见[数据库检查报告](AUDIT.md#数据库完整性)。

## 6. 更新、回退和排障

**已有离线部署改用 GHCR。** 首先确认目标 Actions 已发布包含当前业务功能的两张镜像，且部署包与迁移版本匹配。保留项目名、运行配置和卷，在现有 `.env` 把 `IMAGE_PREFIX` 改为 `ghcr.io/jacqueshuang8192/joker`，把 `IMAGE_TAG` 改为该次发布的 `sha-<完整提交 SHA>`。运行 `docker compose config --images` 核对来源，再执行下面的更新命令。

**从五个大厅切换到一个大厅。** 在维护窗口内，保留原编排名和上传卷。把游戏库 `t_game_server` 的大厅记录收敛为一条，填写玩家可达的 IPv4 和端口 `4700`。当前加载器读取整张表，仅修改旧记录的状态仍可能下发旧端口。将已有 `runtime/api.properties` 的 `game.round` 改为 `1`，在游戏专用 Redis 中清除大厅列表缓存 `GAME_SERVER` 和轮询位置 `GAME_SERVER_ROUND`。换入新版编排后，在部署目录用原项目名执行 `docker compose -p shenshou up -d --force-recreate --remove-orphans`，清理旧的四个大厅容器。验证客户端取得端口 `4700` 且能进入大厅后，收回原先为 `4701–4704` 开的防火墙规则。

**从独立 Redis 转接容器升级。** 保留已有 `runtime/redis.json`（单文件部署保留 `settings` 卷）。使用同次发布的两张新版镜像。在维护窗口先执行 `docker compose -p shenshou down --remove-orphans` 释放旧端口，再用新版编排执行 `docker compose -p shenshou up -d`。保留数据卷，启用金币服务时沿用 `--profile gold`。同网络的反向代理上游改为 `http://api:8080`，宿主机反代地址沿用原配置。以后重建 API 容器时重建整个编排，使游戏进程共用新的网络空间。

**从独立 Flyway 服务升级。** 沿用原 MySQL 库和 `flyway_schema_history`。新版 API 使用业务 JDBC 配置执行 JAR 内的迁移，保留原编排名、密钥及上传卷。首次切换时用新版编排和已集成 Flyway 的镜像执行 `docker compose -p shenshou up -d --force-recreate --remove-orphans`，即可清理旧迁移容器。

**更新已有编排。** 记录当前 `IMAGE_TAG` 和编排名，备份 MySQL、MongoDB、需要保留的 Redis 数据、`uploads` 卷，以及 `panel.ini`、`.env`、`runtime/`。将新部署包解到临时目录，核对后同步同一发布版本的 `docker-compose.yml` 和工具。对比 `config/` 模板，将新增配置合入现有 `runtime/`。修改 `.env` 的 `IMAGE_TAG` 为新 SHA，保留已用的网络、绑定地址和密钥。

```sh
cd /opt/joker
docker compose -p shenshou config --quiet
docker compose -p shenshou pull
docker compose -p shenshou up -d --force-recreate
```

重建时会短暂中断服务，应选择维护窗口。以上命令适用于默认服务；已启用 `gold` 的部署在 `pull` 和 `up` 时加上 `--profile gold`。完成后重复第 5 节验收。已有业务表但没有 Flyway 历史的库会以版本 `0` 接入，首次升级前先在备份副本上执行迁移和验收。

**回退。** 将 `.env` 恢复到上一已发布 SHA，使用与之匹配的编排和运行配置。若保留当前数据库，先核对旧应用能否使用该结构，并保留已执行的全部迁移文件及原校验和，以便 Flyway 启动校验。镜像降级不会撤销数据库变更。若数据库也需恢复，应进入维护窗口，按备份时间点评估新增数据后恢复，再使用与恢复点匹配的 API 镜像和编排启动旧版本。保留 `uploads` 卷和数据库卷。

| 现象 | 排查位置 |
|---|---|
| 拉取镜像提示 `denied` 或 `manifest unknown` | 检查 GHCR 登录权限、两张镜像的名称和 SHA 标签，并确认同次 Actions 已完成发布。 |
| 提示外部网络不存在，或基础服务无法连接 | 对照 `.env` 的 `PANEL_NETWORK` 与 `docker network ls`。检查服务是否加入该网络、名称是否可解析，以及容器内端口和凭据是否正确。 |
| API 在数据库迁移阶段启动失败 | 查看 `docker compose -p shenshou logs api`，核对库名、权限、失败语句及迁移历史。MySQL 的 DDL 可能部分生效，先比对实际结构再重试。 |
| Redis 连接或认证失败 | 查看 `docker compose -p shenshou logs api hall-4700 douniu`，核对 Redis 的内网主机、端口、ACL 用户和密码。 |
| API 在宿主机可访问，外部客户端进不了大厅 | 分别验证 HTTP 反代和游戏 TCP。核对 `GAME_BIND`、`ADVERTISE_IP`、大厅 XML、客户端配置和外网端口转发。 |


### 启用千玺账号登录

在 1Panel 更新 API 镜像，确认 Flyway 已成功执行 V18，再发布配套的大厅资源。用户名管理使用 `hall/login/UsernameView.lua`，好友桌战绩返回使用 `hall/FriendTable.lua`。主版桌面的接口地址在 `client/desktop/main/src/config.lua` 的 `HttpAddr`，Android 默认读取打包资源 `config.lua` 中的 `HttpAddr`，可用 Android 字符串资源 `joker_api_url` 覆盖。iOS 继续使用原生桥返回的地址。设置为自己的 `https://域名/hbiInterface`。仅本机测试支持通过 HTTP 访问 localhost 或 127.0.0.1。

登录页提供微信和账号两种入口。“账号登录”同时接受已有手机号或用户名，右侧“注册”支持使用其中任一种账号注册。用户名为 3 至 20 位，以英文字母开头，支持英文字母、数字及下划线，大小写视为同名。用户名密码区分大小写，长度为 8 至 64 个 UTF-8 字节。手机号使用 11 位大陆手机号，注册密码至少 6 位，可选填昵称、头像等资料。

- **领取恢复码**　注册用户名后，按屏幕上的两行顺序保存完整的 32 位恢复码，点击“已保存，继续”即会自动登录。已有用户名账号升级后，首次在新版大厅使用原密码登录时领取。
- **修改密码**　在“账号登录”选择“修改密码”，输入用户名、原密码和新密码。若遗失恢复码但还记得密码，也可通过此入口换领。
- **忘记密码**　在“账号登录”选择“忘记密码”，输入用户名、恢复码并设置新密码。每次改密或找回成功后，保存新恢复码，旧码随即失效。若提交后断网，先尝试用新密码登录；成功后可再次改密领取恢复码。若已忘记密码又没有保存有效恢复码，当前用户名账号没有其他自助找回渠道。

新玩家沿用现有的初始资源配置。进入大厅时，客户端需要能连接服务器下发的地址和端口。首装的大厅地址取自原生大厅在 Redis 中的注册记录，已有静态配置时优先使用 `t_game_server`。


### 新装时的牛牛目录与升级

API 会执行尚未应用的 Flyway 迁移，当前版本为 V18。V5 新建 `joker_douniu_settlement` 用于 Java 牛牛整局核账。V6 仅在 `t_game`、`t_game_config`、`t_game_type` 和 `t_group_game` 均为空时导入原档 302 牛牛的目录和开房选项。开房端点使用当前编排共享网络内的 `127.0.0.1:11603`。已有玩法数据的库跳过这次目录初始化。V7 扩充牛牛战绩字段并按唯一局号防重。V8 按玩家编号补齐缺行的十个游戏分表，已有分表余额优先。V9 创建 Java 牛牛的房间密码校验表。V10 创建外围庄家流水、玩家筹码占用、俱乐部账单及扣款明细四张表，并扩充整局余额回执。V11 创建台费和上下庄费流水表，为既有赠钻记录增加幂等编号、双方钱包余额及缓存补记状态。

纯 Java 赠钻须同步发布包含新版 `hall/network/Request.lua` 的客户端资源，否则服务端会提示更新。启用联盟积分桌机器人前，核对机器人账号归属、授权状态、桌模板和实际筹码。台费及上下庄费可按活动号在 `joker_table_charge` 对账。[规则和参数](backend/game-java/README.md#可验收的玩法)

`t_game_server` 为空时，API 从 Redis 的 `HALLSERVER` 读取原生大厅注册的地址和端口。首装先确认 hall-4700 健康，并核对 ADVERTISE_IP。默认部署仍运行 C++ 牛牛，客户端保持 `JAVA_DOUNIU = false`。在 1Panel 测试 Java 牛牛时，同时设置 `DATA_GOLD_RUNTIME=game-java` 和 `DOUNIU_RUNTIME=game-java`，客户端启用 `JAVA_DOUNIU` 后重新登录。切换步骤见 [Java 混合部署](deploy/java/README.md)，账务回执见 [Java 游戏服务说明](backend/game-java/README.md)。

Java 牛牛重启续局复用面板 Redis。保留游戏专用 Redis 的持久化数据和原服务编号。首次升级到支持快照的镜像前，先结束旧版的对局。恢复步骤见 [房间进程重启后的恢复](backend/game-java/README.md#房间进程重启后的恢复)。
