# 千玺游戏客户端

`desktop/main/` 来自外层 ClientHall，`desktop/alternate/` 来自另一份 ClientHall。两份均包含大厅、玩法脚本和对应资源。先从 [主版启动入口](desktop/main/src/main.lua)、[大厅](desktop/main/hall/) 或 [玩法](desktop/main/games/) 开始阅读。Android、iOS 和其他原生项目在 [platforms/](platforms/) 中。

## 主版常用入口

| 要修改的内容 | 源码位置 |
|---|---|
| 登录与注册界面 | [hall/login](desktop/main/hall/login/) |
| 启动流程 | [main.lua](desktop/main/src/main.lua)、[MainScene.lua](desktop/main/src/app/scenes/MainScene.lua) |
| 登录 API 域名 | Windows 改 [config.lua](desktop/main/src/config.lua) 的 `HttpAddr`，Android 改 [CocosCaller.java](platforms/main/AndroidProject/frameworks/runtime-src/proj.android-studio/libcocos2dx/java/src/org/cocos2dx/lib/CocosCaller.java) 的 `getHttpAddr()` |
| 游戏玩法与公共资源 | [games](desktop/main/games/)、[assets](desktop/main/assets/) |
| 客户端网络回归测试 | [tests](tests/) |

## 移动端工程

| 工程 | 入口 |
|---|---|
| 主版 Android | [Gradle 工程](platforms/main/AndroidProject/frameworks/runtime-src/proj.android-studio/) |
| 主版 iOS | [HelloLua.xcodeproj](platforms/main/AndroidProject/frameworks/runtime-src/proj.ios_mac/HelloLua.xcodeproj/) |
| 另一版移动工程 | [alternate](platforms/alternate/AndroidProject/frameworks/runtime-src/) |
| 外层 Android 工程 | [outer](platforms/outer/frameworks/runtime-src/proj.android-studio/) |

两份桌面源码按 `src/`、`hall/`、`games/` 和 `assets/` 整理。要还原运行时的相对路径，在仓库根目录执行：

```sh
python3 client/tools/export_desktop.py --variant main build/main/ClientHall
```

Windows 运行还需要从本地配套运行包补入 EXE、DLL，并使用自己的测试账号配置。仓库含启动批处理，历史账号、用户设置、签名材料、日志、APK 和本机编译输出保存在仓库之外。发布副本中以 `LOCAL_` 开头的历史第三方凭据替代值须按自己的服务配置；涉及服务端密钥的流程应由自己的后端提供。

移动工程各自使用自己的资源集。Android 可通过 `COCOS2DX_ROOT` 指定完整引擎位置，旧项目还依赖包含 GNU STL 的相应 NDK。iOS 工程需适配部署目标、接入匹配的引擎、游戏资源及业务桥接后再签名打包。GitHub Actions 构建的是后端 Java 和 C++ 镜像。
