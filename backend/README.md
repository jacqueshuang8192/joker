# Joker 服务端

[`game-java/`](game-java/) 是可独立构建的 Java 23 游戏工程。纯 Java 编排将大厅、分桌、在线查询和牛牛牌桌放在 `rooms` 进程，`data` 负责玩家账务。需要与旧游戏服务互通时可单独运行 `douniu`，另有 `gold` 和 `gateway` 可选。[DDD 代码结构](game-java/README.md#ddd-代码结构) · [纯 Java 部署](../DEPLOYMENT.md#纯-java-牛牛部署)

以下路径相对于 `backend/`。

| 要修改的内容 | 源码位置 |
|---|---|
| Spring Boot 启动入口 | [JokerApiApplication.java](api/src/main/java/com/j/joker/JokerApiApplication.java) |
| HTTP 接口与业务逻辑 | [controller](api/src/main/java/com/j/joker/controller/)、[service](api/src/main/java/com/j/joker/service/) |
| 数据查询与建表 | [Mapper 接口](api/src/main/java/com/j/joker/mapper/)、[Mapper XML](api/src/main/resources/mapper/)、[Flyway 迁移](api/src/main/resources/db/migration/) |
| API 提供的 JSP 和静态页面 | [webapp](api/src/main/webapp/) |
| Java 与 C++ 之间的房间消息 | [FreeGameService.java](api/src/main/java/com/j/joker/service/game/FreeGameService.java) 选择房间服务器，[GroupGameImpl.java](api/src/main/java/com/j/joker/impl/groupgame/GroupGameImpl.java) 收发 TCP 消息 |
| 原生服务 | [services](native/services/) 下的 `hall` 大厅、`user` 用户、`data` 数据、`alloc` 房间分配与赛事、`gold` 金币 |
| 原生依赖与牛牛程序 | [hiredis 源码](native/vendor/hiredis/)、[牛牛预编译程序及运行库](native/prebuilt/douniu/) |
| 镜像构建与启动 | [API Dockerfile](api/Dockerfile)、[原生 Dockerfile](native/Dockerfile)、[编译脚本](native/build.sh)、[原生容器入口](native/container/) |
| 后端联调 | [tests](tests/) 在独立的 Compose 环境中检查迁移、登录、JSP 和游戏服务 |
| 历史源码 | [archive/java](archive/java/) 保存停用的 Java 文件，[archive/examples](archive/examples/) 保存旧 Jetty 启动与调试示例 |

## 本地构建原生镜像

在仓库根目录执行 `docker build --platform linux/amd64 -f backend/native/Dockerfile -t joker-native:local .`。构建使用同一提交的 C++ 代码、`config/*.in` 模板和面板配置生成脚本。

## 本地运行 Java API

使用 JDK 23 和 Maven，在仓库根目录执行下列命令。先准备好 `runtime/api.properties`（生成方式见[部署手册](../DEPLOYMENT.md)），并确保配置中的 MySQL、Redis 和其他业务服务可达。Spring Boot 启动时会校验历史记录并执行 JAR 内待应用的 Flyway 迁移。

```sh
mvn -f backend/api/pom.xml clean package
JOKER_CONFIG="$PWD/runtime/api.properties" java -jar backend/api/target/joker-api.jar
```

启动入口为 `com.j.joker.JokerApiApplication`，默认访问路径为 `http://localhost:8080/hbiInterface/index.html`。Spring Boot 内嵌 Tomcat 和 Jasper，启动时会把 JAR 内的 JSP 写入 JVM 临时目录用于编译。1Panel 仍挂载同一份 `runtime/api.properties`，升级时请使用与镜像同版本的 Compose 文件。直接在宿主机运行时，按实际可达地址设置 JDBC、MongoDB 和 Redis（包括邀请码使用的 `redis.port1`）。
