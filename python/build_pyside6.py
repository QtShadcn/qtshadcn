#!/usr/bin/env python3

"""Build the PySide6 distribution from the shared and backend sources."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def copy_sources(project: Path) -> None:
    source_root = project / "src"
    adapter_root = source_root / "pysideshadcn"
    common_root = adapter_root / "common"
    adapter_root.mkdir(parents=True)
    common_root.mkdir()

    for filename in ("__init__.py", "capability.py"):
        shutil.copy2(ROOT / "python" / "pyside6" / filename, adapter_root / filename)
    for filename in ("__init__.py", "icons.py", "theme.py"):
        shutil.copy2(ROOT / "python" / "common" / filename, common_root / filename)

    module_dir = common_root / "QtShadcn"
    module_dir.mkdir()
    shutil.copy2(ROOT / "python" / "common" / "QtShadcn" / "qmldir", module_dir)
    shutil.copytree(ROOT / "src" / "qml", module_dir / "qml")
    shutil.copytree(ROOT / "src" / "assets" / "icons", common_root / "icons")

    shutil.copy2(ROOT / "python" / "pyside6" / "README.md", project / "README.md")
    for filename in ("LICENSE", "THIRD-PARTY-NOTICES.md"):
        shutil.copy2(ROOT / filename, project / filename)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out-dir", type=Path, default=ROOT / "dist-pyside6")
    args = parser.parse_args()
    output_dir = args.out_dir.resolve()

    with tempfile.TemporaryDirectory(prefix="pysideshadcn-build-") as temporary_dir:
        project = Path(temporary_dir)
        copy_sources(project)
        shutil.copy2(ROOT / "python" / "pyside6" / "pyproject.toml", project)
        subprocess.run(  # noqa: S603
            [sys.executable, "-m", "build", "--outdir", str(output_dir), str(project)],
            check=True,
        )


if __name__ == "__main__":
    main()
