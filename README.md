# 神兽后端部署

把本目录作为一个独立的私有 GitHub 仓库。Java 接口和原生服务分别发布到 GHCR，部署目标是 Linux AMD64。原包的完整性、每个模块的构建方式及数据库缺项见 [后端检查报告](AUDIT.md)。

## 源码目录

| 要找的代码 | 仓库内的位置 |
|---|---|
| Java 的 HTTP 接口与业务逻辑 | `api/src/main/java/com/hbi/`，从 `controller/` 找接口，从 `service/` 找业务逻辑 |
| 数据库查询映射 | Java Mapper 接口在 `api/src/main/java/com/hbi/mapper/`，对应的 MyBatis XML 在 `api/src/main/resources/mapper/` |
| Java 调用游戏服务 | `api/src/main/java/com/hbi/impl/groupgame/GroupGameImpl.java` 负责开房、解散和退房的 TCP 消息 |
| 大厅、用户、数据、金币服务 | `native/services/hall/`、`user/`、`data/`、`gold/`，四个目录均位于 `native/services/` 下 |
| 房间分配与赛事 | `native/services/alloc/Game/`，其中 `GameServerMatches.cpp` 集中处理赛事的创建、查找、加入和列表 |
| 原生依赖与牛牛程序 | `native/vendor/hiredis/` 为第三方库源码，`native/prebuilt/douniu/` 为现有牛牛程序和运行库 |
| 构建与容器启动 | `api/Dockerfile`、`native/Dockerfile`、`native/build.sh`，原生服务入口和健康检查在 `native/container/` |
| 部署与数据库 | 根目录 `docker-compose.yml`，配置模板在 `config/`，建表脚本在 `database/`，配置生成与核验工具在 `tools/` |
| 已停用的 Java 源文件 | `archive/java/` 保留原包路径和文件内容，供追溯历史 |

排查房间问题时，可以先看 `com/hbi/service/game/FreeGameService.java` 如何选择游戏服务器，再到 `GroupGameImpl.java` 核对发往该地址的消息字段。

1Panel 部署包只包含编排、模板、数据库脚本、部署工具和说明。查看或修改业务代码时，请打开完整源码仓库。

## 推送和自动打包

在 GitHub 新建空的私有仓库，进入本目录，执行以下命令。将 OWNER、REPO 替换为实际所有者和仓库名。

```sh
git remote add origin git@github.com:OWNER/REPO.git
git push -u origin main
```

Actions 工作流会用 JDK 8 从源码生成 WAR，在 Linux 上构建两张镜像，并在隔离网络中用空数据卷启动 Compose。自动检查包括数据库建表、服务端口和一次读取临时测试版本号的 HTTP 请求。检查通过后，推送到 GHCR。PR 执行构建和检查，发布由推送 main 或 v 开头的版本标签触发。手动运行会发布该提交的 SHA 标签。

| 镜像 | 标签 |
|---|---|
| `ghcr.io/owner/repo-api` | `sha-<完整提交 SHA>`、`main` 或推送的版本标签 |
| `ghcr.io/owner/repo-native` | 同一次提交的同名标签 |

仓库需要启用 Actions 并允许工作流写入 Packages。工作流使用 GitHub 自动签发的 `GITHUB_TOKEN`。若组织限制发布权限，或已有同名包，需要管理员给该仓库授予包写入权限。[GitHub 镜像发布说明](https://docs.github.com/en/actions/use-cases-and-examples/publishing-packages/publishing-docker-images)

## 首次部署到 1Panel

1. 在 1Panel 的镜像仓库中登录 `ghcr.io`，使用有权读取这两个私有包的 GitHub 用户及带 `read:packages` 的凭据。若在服务器终端登录，用 `docker login ghcr.io` 的交互提示输入凭据。
2. 下载该次成功工作流的 `1panel-deploy` 构件并解压，或将同一提交的 `docker-compose.yml`、`tools/configure.py`、整个 `config/` 和 `database/` 放到服务器的同一目录，例如 `/opt/shenshou-compose`。也可以检出该提交的完整私有仓库。服务器只拉取镜像，无需 JDK、Maven 或 C++ 编译器。
3. 在该目录运行下面的初始化命令。镜像前缀使用全小写，IPv4 填客户端实际能访问的地址，SHA 取自已成功发布的工作流。脚本使用 Python 3 标准库，生成本机专用的 `.env` 和 `runtime/`。
4. 在 1Panel 进入 **容器 → 编排 → 创建编排 → 路径选择**，选择服务器上这份 `docker-compose.yml`，使用固定的编排名，例如 `shenshou`。如果面板没有自动读取同目录的 `.env`，在编排的环境变量设置中导入该文件。部署前可在终端用 `docker compose config --quiet` 核对插值和结构。[1Panel 编排说明](https://github.com/1Panel-dev/docs/blob/v2/docs/user_manual/containers/compose.md)

```sh
cd /opt/shenshou-compose
python3 tools/configure.py --image-prefix ghcr.io/owner/repo \
  --tag sha-完整提交SHA --advertise-ip 客户端可达的IPv4地址
docker compose config --quiet
docker compose pull
```

默认 HTTP 和游戏端口仅绑定宿主机回环地址。可先在服务器终端访问 `http://127.0.0.1:8080/hbiInterface/index.html`。接入客户端时，按服务器网卡设置 `.env` 中的 `GAME_BIND`，大厅使用 TCP 4700–4704，牛牛使用 TCP 13600。修改绑定地址后重新创建编排。若机器在 NAT 后面，`ADVERTISE_IP` 是客户端访问的地址，`GAME_BIND` 是宿主机本地绑定地址。改变公告地址时也要同步修改 `runtime/hall-config.xml` 中 ServerInfo 的 ip。HTTP API 可由 1Panel 网站反向代理到回环地址上的 `API_PORT`，按需开放业务路径。MySQL、Redis、MongoDB、Memcached 及用户、数据和分配服务仅在容器网络中访问。

## 业务数据与客户端配置

MySQL 5.7 在首次使用空卷时创建 `shenshou_game` 和原包可提取的 86 张基础表。本仓库的初始化脚本仅含建表定义。玩家、支付、渠道、版本记录和实际游戏配置需要在服务器上从自己的备份恢复。先备份现有数据，在隔离库验证恢复文件后再操作。原包的完整 SQL 含删表语句和历史数据。单纯重启编排或改镜像标签不会重新初始化已有卷。

部署生成的 `runtime/api.properties` 和 XML/INI 是实际运行配置。接入已有客户端时，按客户端协议核对 `protocol.aesKey`、`protocol.defaultKey`、`protocol.mtKey` 和大厅的 KEY。配置支付、短信、微信、OSS 等功能时需填写自己的服务参数。生成的 `agent.initialPassword` 用于旧代理开户流程。运行配置应仅由服务器管理员管理，备份时将 `.env`、`runtime/` 和数据库卷一起保护。配置文件以只读方式挂载；修改文件后重新创建受影响的容器。

原程序使用数字 IP 及本机回环连接。这里让各容器共享 cache 的网络命名空间，各自保留进程空间和文件系统。部署使用一份用户服务，原配置中十个用户端口槽均指向这份实例的 7500 端口。cache 容器重建时应重建整组服务。数据库和上传文件使用命名卷，升级时沿用编排名。

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
