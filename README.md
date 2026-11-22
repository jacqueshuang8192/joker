# 神兽客户端与后端部署

本仓库同时维护 Cocos2d-x/Lua 客户端、Java API 和 C++ 游戏服务。客户端源码和平台工程请从 [client/README.md](client/README.md) 进入。服务器安装、升级和排障请按[1Panel 部署手册](DEPLOYMENT.md)操作，核验结果见 [后端检查报告](AUDIT.md)。

## 源码目录

| 要找的代码 | 仓库内的位置 |
|---|---|
| Java 的 HTTP 接口与业务逻辑 | `api/src/main/java/com/j/joker/`，从 `controller/` 找接口，从 `service/` 找业务逻辑 |
| 数据库查询映射 | MyBatis-Flex Mapper 接口在 `api/src/main/java/com/j/joker/mapper/`，对应的 MyBatis XML 在 `api/src/main/resources/mapper/` |
| Java 调用游戏服务 | `api/src/main/java/com/j/joker/impl/groupgame/GroupGameImpl.java` 负责开房、解散和退房的 TCP 消息 |
| 大厅、用户、数据、金币服务 | `native/services/hall/`、`user/`、`data/`、`gold/`，四个目录均位于 `native/services/` 下 |
| 房间分配与赛事 | `native/services/alloc/Game/`，其中 `GameServerMatches.cpp` 集中处理赛事的创建、查找、加入和列表 |
| 原生依赖与牛牛程序 | `native/vendor/hiredis/` 为第三方库源码，`native/prebuilt/douniu/` 为现有牛牛程序和运行库 |
| 构建与容器启动 | `api/Dockerfile`、`native/Dockerfile`、`native/build.sh`，原生服务入口和健康检查在 `native/container/` |
| 部署与数据库 | 根目录 `docker-compose.yml`，配置模板在 `config/`，Flyway 版本迁移在 `database/migrations/`，配置生成与核验工具在 `tools/` |
| 已停用的 Java 源文件 | `archive/java/` 保留原包路径和文件内容，供追溯历史 |

排查房间问题时，可以先看 `com/j/joker/service/game/FreeGameService.java` 如何选择游戏服务器，再到 `GroupGameImpl.java` 核对发往该地址的消息字段。

1Panel 部署包只包含编排、模板、数据库脚本、部署工具和说明。查看或修改业务代码时，请打开完整源码仓库。

## 本地运行 Java API

使用 JDK 23 和 Maven，在仓库根目录执行下列命令。先准备好 `runtime/api.properties`（生成方式见下方部署步骤），并确保配置中的 MySQL、Redis 和其他业务服务可达。Spring Boot 启动时会校验历史记录并执行 JAR 内待应用的 Flyway 迁移。

```sh
mvn -f api/pom.xml clean package
JOKER_CONFIG="$PWD/runtime/api.properties" java -jar api/target/joker-api.jar
```

启动入口为 `com.j.joker.JokerApiApplication`，默认访问路径为 `http://localhost:8080/hbiInterface/index.html`。Spring Boot 内嵌 Tomcat 和 Jasper，启动时会把 JAR 内的 JSP 写入 JVM 临时目录用于编译。1Panel 仍挂载同一份 `runtime/api.properties`，升级时请使用与镜像同版本的 Compose 文件。直接在宿主机运行时，按实际可达地址设置 JDBC、MongoDB 和 Redis（包括邀请码使用的 `redis.port1`）。

## 推送和自动打包

推送 `main` 或 `v*` 版本标签会触发本仓库的后端发布流程。镜像名前缀是 `ghcr.io/jacqueshuang8192/joker`。

Actions 工作流会用 JDK 23 从源码生成 Spring Boot 可执行 JAR，在 Linux 上构建两张镜像，并在隔离网络中用空数据卷启动 Compose。自动检查包括 Flyway 建表、MyBatis-Flex 主键回填和分页、XML 分表读写、Spring 事务回滚、JSP 渲染、游戏服务端口和版本查询接口。检查通过后，推送到 GHCR。PR 执行构建和检查，发布由推送 main 或 v 开头的版本标签触发。手动运行会发布该提交的 SHA 标签。

| 镜像 | 标签 |
|---|---|
| `ghcr.io/owner/repo-api` | `sha-<完整提交 SHA>`、`main` 或推送的版本标签 |
| `ghcr.io/owner/repo-native` | 同一次提交的同名标签 |

仓库需要启用 Actions 并允许工作流写入 Packages。工作流使用 GitHub 自动签发的 `GITHUB_TOKEN`。若组织限制发布权限，或已有同名包，需要管理员给该仓库授予包写入权限。[GitHub 镜像发布说明](https://docs.github.com/en/actions/use-cases-and-examples/publishing-packages/publishing-docker-images)

## 首次部署到 1Panel

部署包提供[可直接粘贴到 1Panel 的独立编排](deploy/1panel/docker-compose.yml)，适合新建实例。使用内置 Flyway 的同次发布镜像，运行配置保存在 `settings` 卷。直接使用源码中的独立编排时须填写该次发布的 `IMAGE_TAG`。仓库根目录的编排用于与源码同次发布的部署包。

1. 在 1Panel 准备 MySQL、MongoDB、Redis、Memcached 和游戏专用库，解压同版本的部署包到 `/opt/joker`。
2. 在部署目录复制 `panel.ini.example` 为 `panel.ini`，填写网络、玩家可达的 IPv4、游戏端口绑定地址及四项服务的连接信息，再执行 `python3 tools/configure.py && docker compose config --quiet`。GitHub 发布包预填同一版本的镜像标签。
3. 在 **容器 → 编排 → 创建编排 → 路径选择** 中选择 `/opt/joker/docker-compose.yml`。全部应用服务定义在这一份 Compose 文件中。API 默认监听本机 `8080`，游戏对外使用 TCP `4700` 和 `13600`。网络设置、HTTPS 反向代理和验收步骤见[部署手册](DEPLOYMENT.md)。

**已有部署迁移**：在新目录准备新版部署包。先备份旧应用配置、上传卷和数据库，将旧 MySQL、MongoDB 以及需要保留的 Redis 数据恢复至面板管理的实例，再切换连接。沿用旧 `runtime/api.properties` 中的业务、支付及协议密钥，以及大厅对应的 KEY；将新版连接设置合入已有配置。旧 `.env` 的编排名与上传卷也要核对。首装脚本只在新目录生成配置，迁移完成前请保留旧卷。

## 业务数据与客户端配置

构建 API 时，Maven 将 `database/migrations/` 的 SQL 原样打入 JAR。Spring Boot 使用业务库连接执行待应用的迁移。API 健康后，Compose 再启动原生游戏服务。空库依次执行 V1 至 V4，创建 163 张业务表。V1 提供 86 张原始表，V2 补建 62 张兼容表，V3 补建 14 张通用 Mapper 引用的表，并为赛事玩家记录补齐两个筹码列。V4 新增用户名登录凭据表。Flyway 通过 `flyway_schema_history` 记录版本和校验和。在 `api` 日志中查看迁移结果。

旧版编排升级时，先备份数据库并保留原编排名与数据卷。已有业务表且尚无迁移历史的库会以版本 0 接入，再执行待应用的迁移。已有 V2 的库执行 V3 和 V4。V3 按列检查 `t_activity_user`，只添加缺少的 `bring_chip` 和 `present_chip`。已有同名表的结构和索引需要与业务库核对。以后使用新的版本文件记录结构变更。更新时部署同次发布的镜像和编排。每次启动 API 都会校验迁移历史。

V2 覆盖代理、充值、订单、联盟、任务和战绩等代码所用的表。字段来自实体及查询，类型、长度和索引按可见读写行为选取。佣金比例、商品、任务规则等业务数据需要从匹配版本的备份恢复或按实际业务配置。分表按真实后缀检查，核对命令和已知查询限制见 [数据库核验记录](AUDIT.md#数据库完整性)。

迁移失败时用 `docker compose logs api` 定位出错语句。MySQL 5.7 的 DDL 可能已部分生效，需核对表结构和迁移历史后再重试。回退应用镜像不会回退数据库版本。

玩家、支付、渠道、版本记录和实际游戏配置需要在服务器上从自己的备份恢复。先备份现有数据，在隔离库验证恢复文件后再操作。原包的完整 SQL 含删表语句和历史数据。单纯重启编排或改镜像标签不会重新初始化已有卷。

部署生成的 `runtime/api.properties` 和 XML/INI 是实际运行配置。接入已有客户端时，按客户端协议核对 `protocol.aesKey`、`protocol.defaultKey`、`protocol.mtKey` 和大厅的 KEY。配置支付、短信、微信、OSS 等功能时需填写自己的服务参数。生成的 `agent.initialPassword` 用于旧代理开户流程。运行配置应仅由服务器管理员管理，备份时将 `panel.ini`、`.env`、`runtime/` 和面板数据库备份一起保护。配置文件以只读方式挂载；修改文件后重新创建受影响的容器。

Java、大厅、用户、数据、房间分配和金币服务直接连接面板 Redis，密码和 ACL 用户从 `runtime/redis.json` 读取。预编译牛牛通过自身启动进程内的本地转发访问同一 Redis。游戏进程与 API 共享网络，API 发布 HTTP 和游戏端口。重建 API 容器时一起重建应用编排。上传文件保存在 `uploads` 卷，四项基础服务的数据由 1Panel 管理。

金币更新服务位于 `gold` profile。归档缺少它原用的 `config.xml`。初始化同时生成了按源码字段编写的 `runtime/gold-example.xml`。与自己的游戏编号、数据库及更新间隔核对后，将确认过的配置放到 `runtime/gold.xml`，再启用该 profile。可选服务单独验收。

## 更新与回退

等待 Actions 完成，记录新旧两组镜像的 SHA 标签。修改服务器 `.env` 的 `IMAGE_TAG`，在同一个编排拉取新镜像并重新创建容器。若该次提交也改了编排、配置模板或数据库要求，先比对同次提交的文件并备份数据。回退镜像时改回旧 SHA，再次拉取并重建。数据库迁移需单独规划。发布镜像成功后，更新 1Panel 的时间由服务器管理员决定。

在服务器的编排目录中可执行下列只读检查，`-p` 的值与面板编排名保持一致。

```sh
docker compose -p shenshou ps
docker compose -p shenshou logs --tail=80 api
curl -fsS 'http://127.0.0.1:8080/hbiInterface/version/queryVersion?type=2&interfaceType=J'
```

版本表尚无有效大厅记录时，接口可以成功返回而没有版本数据。业务验收还应使用测试账号完成登录、进大厅、开房、加入、结算及重连。
