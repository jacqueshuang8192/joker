"""在 1Panel 的 settings 卷中生成 Java 和原生服务共用的运行配置。"""
import json
import os
from pathlib import Path
from tempfile import TemporaryDirectory

from configure import configuration_values, parse_args, write_runtime_configs


def main():
    # panel.ini 含面板连接凭据，keys.json 含协议和业务密钥。仅所有者可读写。
    os.umask(0o077)
    settings = Path("/settings")
    config_text = os.environ["PANEL_INI"]
    saved = settings / "panel.ini"
    # 沿用旧编排的参数快照和目录布局。相同参数重启时也保留管理员的运行配置。
    if saved.exists() and saved.read_text() == config_text:
        print("Settings ready")
        return

    # 在同一卷暂存，配置校验和渲染通过后再替换正式文件。
    with TemporaryDirectory(dir=settings) as tmp:
        stage = Path(tmp)
        panel = stage / "panel.ini"
        panel.write_text(config_text)
        args = parse_args(stage)
        values = configuration_values(args)

        # 首次生成六项随机凭据。修改连接参数或从旧镜像升级时继续使用原密钥。
        keys = settings / "keys.json"
        if keys.exists():
            values.update(json.loads(keys.read_text()))
        else:
            names = ("DEFAULT_KEY", "SYSTEM_PASSWORD", "SIGN_KEY", "AGENT_PASSWORD", "AES_KEY", "MT_KEY")
            staged_keys = stage / "keys.json"
            staged_keys.write_text(json.dumps({name: values[name] for name in names}))
            staged_keys.replace(keys)

        # 模板随镜像放在脚本旁的 config/ 中。运行参数和密码来自本次面板输入。
        runtime = stage / "runtime"
        write_runtime_configs(Path(__file__).parent, runtime, values, args.settings["redis"])
        target = settings / "runtime"
        target.mkdir(exist_ok=True)
        for file in runtime.iterdir():
            file.replace(target / file.name)
        # 最后记录本次输入，避免中途退出时把部分写入当成已经完成。
        panel.replace(saved)
    print("Settings ready")


if __name__ == "__main__":
    main()
