"""Export one desktop client with the paths expected by Cocos and the Windows launcher."""
import argparse
from pathlib import Path
import shutil
import tempfile


ROOT = Path(__file__).resolve().parents[1]


def export(variant, destination):
    source = ROOT / "desktop" / variant
    destination = destination.resolve()
    if destination.exists():
        raise ValueError(f"Output already exists: {destination}")
    for folder in ("desktop", "platforms", "tools"):
        if ROOT / folder in destination.parents:
            raise ValueError("Choose an output directory outside the source folders.")

    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=destination.parent, prefix=".client-export-") as tmp:
        stage = Path(tmp) / "ClientHall"
        stage.mkdir()
        entries = [source / "src", source / "hall"]
        for group in ("games", "assets", "windows", "launcher", "extras"):
            folder = source / group
            if folder.is_dir():
                entries.extend(sorted(folder.iterdir()))
        for path in entries:
            target = stage / path.name
            if target.exists():
                raise ValueError(f"Conflicting runtime path: {path.name}")
            if path.is_dir():
                shutil.copytree(path, target, ignore=shutil.ignore_patterns(".DS_Store"))
            else:
                shutil.copy2(path, target)

        # Historical copies can still be addressed by name from scripts or downloaded assets.
        archive = source / "archive" / "lua"
        for path in archive.rglob("*.lua"):
            target = stage / path.relative_to(archive)
            if target.exists():
                raise ValueError(f"Archive overlaps active source: {target.relative_to(stage)}")
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)
        stage.rename(destination)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--variant", choices=("main", "alternate"), default="main")
    parser.add_argument("destination", type=Path, help="A new directory for the exported client")
    args = parser.parse_args()
    try:
        export(args.variant, args.destination)
    except (OSError, ValueError) as exc:
        parser.exit(1, f"{exc}\n")
    print(args.destination.resolve())


if __name__ == "__main__":
    main()
