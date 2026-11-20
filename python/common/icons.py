#!/usr/bin/env python3

"""Binding-independent helpers for the bundled icon assets."""

import base64
import re
from pathlib import Path

_COMMENT_RE = re.compile(r"<!--[\s\S]*?-->")


def load_icons(directory: Path) -> dict[str, str]:
    icons = {}
    if directory.is_dir():
        for path in sorted(directory.glob("*.svg")):
            icons[path.stem] = _COMMENT_RE.sub("", path.read_text(encoding="utf-8")).strip()
    return icons


def icon_data_url(svg: str, color: str) -> str:
    svg = svg.replace("currentColor", color)
    encoded = base64.b64encode(svg.encode("utf-8")).decode("ascii")
    return f"data:image/svg+xml;base64,{encoded}"
