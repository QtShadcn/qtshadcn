#!/usr/bin/env python3
"""从 QtShadcn 主仓库同步 QML 源与图标到本包（保持副本最新）。

用法:
    # 同步（写文件）
    python sync.py --src /path/to/qtshadcn

    # 仅检查是否过期（不写），CI 用：源更新但未同步则非零退出
    python sync.py --src /path/to/qtshadcn --check

同步规则:
    - src/qml      -> src/pyqtshadcn/qml/   （排除 ShadcnTable.qml，其依赖 C++ ShadcnTableModel）
    - src/assets/icons/*.svg -> src/pyqtshadcn/icons/
    - src/pyqtshadcn/QtShadcn/qmldir 复制并剔除 ShadcnTable 行
    - 校验 qmldir 中每个组件都对应一个存在的 qml 文件
"""
from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

# ShadcnTable 依赖 C++ ShadcnTableModel，纯 Python 包暂不支持
EXCLUDE_QML = {"ShadcnTable.qml"}
QMldir_EXCLUDE = re.compile(r"^\s*ShadcnTable\s")


def sync_qml(src_qml: Path, dst_qml: Path, check: bool) -> bool:
    ok = True
    dst_qml.mkdir(parents=True, exist_ok=True)
    for f in sorted(src_qml.rglob("*.qml")):
        if f.name in EXCLUDE_QML:
            continue
        target = dst_qml / f.relative_to(src_qml)
        rel = f.read_text(encoding="utf-8")
        if target.exists():
            cur = target.read_text(encoding="utf-8")
            if cur != rel:
                ok = False
                if not check:
                    target.write_text(rel, encoding="utf-8")
                else:
                    print(f"[check] 过期: {target.relative_to(Path.cwd())}")
        else:
            ok = False
            if not check:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(rel, encoding="utf-8")
            else:
                print(f"[check] 缺失: {target.relative_to(Path.cwd())}")
    return ok


def sync_icons(src_icons: Path, dst_icons: Path, check: bool) -> bool:
    ok = True
    dst_icons.mkdir(parents=True, exist_ok=True)
    for f in sorted(src_icons.glob("*.svg")):
        target = dst_icons / f.name
        if target.exists():
            if target.read_bytes() != f.read_bytes():
                ok = False
                if not check:
                    shutil.copy2(f, target)
                else:
                    print(f"[check] 过期: {target.relative_to(Path.cwd())}")
        else:
            ok = False
            if not check:
                shutil.copy2(f, target)
            else:
                print(f"[check] 缺失: {target.relative_to(Path.cwd())}")
    return ok


def sync_qmldir(src_qml: Path, dst_qmldir: Path, qmldir_src: Path, check: bool) -> bool:
    ok = True
    lines = qmldir_src.read_text(encoding="utf-8").splitlines()
    out = [ln for ln in lines if not QMldir_EXCLUDE.match(ln)]
    # 校验：qmldir 里每个组件都对应一个存在的 qml 文件
    # qmldir 路径形如 `qml/Components/X.qml`（相对 QtShadcn 模块目录），
    # 映射到主仓库 src/qml/Components/X.qml（去掉前缀 qml/）
    for ln in out:
        m = re.match(r"^\s*\S+\s+\d+\.\d+\s+(\S+)\s*$", ln)
        if not m:
            continue
        qml_rel = m.group(1)
        if qml_rel.startswith("qml/"):
            qml_rel = qml_rel[len("qml/"):]
        if not (src_qml / qml_rel).exists():
            print(f"[warn] qmldir 引用不存在的 QML（应已排除）: {qml_rel}")
            ok = False
    text = "\n".join(out) + "\n"
    if dst_qmldir.exists():
        if dst_qmldir.read_text(encoding="utf-8") != text:
            ok = False
            if not check:
                dst_qmldir.write_text(text, encoding="utf-8")
            else:
                print(f"[check] 过期: {dst_qmldir.relative_to(Path.cwd())}")
    else:
        ok = False
        if not check:
            dst_qmldir.write_text(text, encoding="utf-8")
        else:
            print(f"[check] 缺失: {dst_qmldir.relative_to(Path.cwd())}")
    return ok


def main() -> int:
    ap = argparse.ArgumentParser(description="Sync QML/icon resources from qtshadcn main repo")
    ap.add_argument("--src", required=True, type=Path, help="qtshadcn 主仓库根目录")
    ap.add_argument("--check", action="store_true", help="仅检查不写，过期则非零退出")
    args = ap.parse_args()

    root = Path.cwd()
    src_qml = args.src / "src" / "qml"
    src_icons = args.src / "src" / "assets" / "icons"
    qmldir_src = args.src / "pyqtshadcn" / "QtShadcn" / "qmldir"

    if not src_qml.is_dir():
        print(f"[error] 找不到源 QML 目录: {src_qml}", file=sys.stderr)
        return 2
    if not src_icons.is_dir():
        print(f"[error] 找不到源图标目录: {src_icons}", file=sys.stderr)
        return 2
    if not qmldir_src.is_file():
        print(f"[error] 找不到源 qmldir: {qmldir_src}", file=sys.stderr)
        return 2

    dst_qml = root / "src" / "pyqtshadcn" / "QtShadcn" / "qml"
    dst_icons = root / "src" / "pyqtshadcn" / "icons"
    dst_qmldir = root / "src" / "pyqtshadcn" / "QtShadcn" / "qmldir"

    ok = True
    ok &= sync_qml(src_qml, dst_qml, args.check)
    ok &= sync_icons(src_icons, dst_icons, args.check)
    ok &= sync_qmldir(src_qml, dst_qmldir, qmldir_src, args.check)

    if args.check:
        if ok:
            print("[check] 资源已是最新，无需同步。")
            return 0
        print("[check] 资源已过期，请运行 `python sync.py --src <qtshadcn>`。", file=sys.stderr)
        return 1
    print("[sync] 完成。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
