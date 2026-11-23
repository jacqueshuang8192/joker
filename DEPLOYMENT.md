# Joker 后端 · 1Panel 部署手册

本手册适用于由 1Panel 管理 MySQL、MongoDB、Redis 和 Memcached 的单机部署。GitHub Actions 构建 Java 23 的 `joker-api` 和 C++ 的 `joker-native` 两张镜像，服务器拉取镜像，无需安装 JDK 或编译器。下面统一使用部署目录 `/opt/joker`、编排名 `shenshou`。

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

Flyway 先执行待应用的迁移。空库依次执行 V1 至 V4，得到 **163 张业务表**及 `flyway_schema_history`。V3 库只需执行 V4。迁移提供表结构，真实玩法、房间、商品、版本记录和第三方渠道参数仍需从匹配的业务备份恢复或由运营方配置。原始历史 SQL 含删表语句，恢复时先在独立库核验。

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
- 在 1Panel 的 MySQL 管理工具中选中游戏库，执行下列 SQL。新建空库的记录应包含版本 `1` 至 `4`，且 `success` 均为 `1`。还可在同一库执行部署包的 `tools/check-schema.sql`，两个结果集都为空表示清单中的表和筹码列齐全。

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

部署内含 V4 迁移的新版 API 镜像，确认 Flyway 成功，然后分发新版客户端。主版桌面的接口地址在 `client/desktop/main/src/config.lua` 的 `HttpAddr`，移动端使用原生桥接返回的地址。设置为自己的 `https://域名/hbiInterface`。仅本机测试支持通过 HTTP 访问 localhost 或 127.0.0.1。

登录页提供微信和账号两种入口。蓝色按钮左侧的“账号登录”同时接受已有手机号或用户名，右侧“注册”支持使用其中任一种账号注册。手机号为11位大陆手机号，沿用既有手机号接口。手机号注册可选填昵称、头像等资料。填写账号和密码后点击“注册并登录”。账号创建成功后客户端会自动登录并进入大厅。如果注册成功后登录连接中断，点击“登录游戏”即可重试。用户名为 3 至 20 位，以英文字母开头，支持英文字母、数字及下划线，大小写视为同名。用户名密码区分大小写，长度为 8 至 64 个 UTF-8 字节。手机号注册密码至少 6 位。新玩家沿用现有的初始资源配置。进入大厅还需要在 `t_game_server` 配置客户端可达的大厅地址和端口。
