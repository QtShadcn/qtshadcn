#!/usr/bin/env python3

import shutil
from pathlib import Path

from setuptools import setup
from setuptools.command.build_py import build_py as _build_py

ROOT = Path(__file__).parent


class build_py(_build_py):
    def run(self):
        super().run()
        package_dir = ROOT / "python" if self.editable_mode else Path(self.build_lib) / "pyqtshadcn"
        self.resource_outputs = []
        for source, target in (
            (ROOT / "src" / "qml", package_dir / "QtShadcn" / "qml"),
            (ROOT / "src" / "assets" / "icons", package_dir / "icons"),
        ):
            # These directories contain generated copies only. Replacing them
            # prevents removed or renamed source assets surviving a rebuild.
            if target.exists():
                shutil.rmtree(target)
            shutil.copytree(source, target, dirs_exist_ok=True, ignore=shutil.ignore_patterns(".*"))
            self.resource_outputs.extend(str(path) for path in target.rglob("*") if path.is_file())

    def get_outputs(self, include_bytecode=1):
        return super().get_outputs(include_bytecode) + getattr(self, "resource_outputs", [])


setup(cmdclass={"build_py": build_py})
