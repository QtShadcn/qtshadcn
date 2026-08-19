#!/usr/bin/env bash
# 给所有 showcase 组件页生成 PNG 截图，输出到 docs/public/images/components/。
# 依赖：showcase 已 make build（offscreen 平台下 grabWindow 渲染）。
#
# 用法：
#   ./scripts/screenshot.sh                            # 默认路径
#   SHOWCASE=... ./scripts/screenshot.sh               # 自定义二进制
#   OUT_DIR=... ./scripts/screenshot.sh                # 自定义输出
#   SKIP_OVERVIEW=1 ./scripts/screenshot.sh           # 跳过总览/表单等非纯组件页

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SHOWCASE="${SHOWCASE:-$ROOT/build/bin/showcase}"
OUT_DIR="${OUT_DIR:-$ROOT/docs/public/images/components}"
QML_IMPORT_PATH="${QML_IMPORT_PATH:-$ROOT/build/src:$ROOT/build/examples/showcase}"

# offscreen 平台：grabToImage 走软件渲染，无需 GUI
export QT_QPA_PLATFORM=offscreen
export QML_IMPORT_PATH="$QML_IMPORT_PATH"
# 渲染等待时长（ms）：复杂页面（Icon 网格/表单）需多帧，默认 1200，可加大保证完整
export SHOT_DELAY_MS="${SHOT_DELAY_MS:-1200}"
# 每张之间间隔（s）：确保前一个进程完全退出 + 磁盘写完成
SLEEP="${SLEEP:-0.6}"

mkdir -p "$OUT_DIR"

# 遍历所有组件 Page，文件名 ButtonPage.qml -> 输出 button.png
ok=0; fail=0
for page_file in "$ROOT/examples/showcase/pages/"*Page.qml; do
    page_name="$(basename "$page_file")"                       # ButtonPage.qml
    # 输出名与文档 slug 对齐：ButtonGroupPage -> button-group；RadioPage -> radio-group
    name="$(basename "$page_file" Page.qml | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' | tr 'A-Z' 'a-z')"
    [ "$name" = "radio" ] && name="radio-group"
    out="$OUT_DIR/$name.png"

    # 跳过表单等非纯组件页（默认全截；SKIP_OVERVIEW=1 跳过）
    case "$name" in
        form) [ -n "${SKIP_OVERVIEW:-}" ] && { echo "  skip  $name"; continue; } ;;
    esac

    printf "  → %-16s (%s) " "$name" "$page_name"
    if out_line="$("$SHOWCASE" --screenshot "$page_name" --output "$out" 2>&1)"; then
        if [[ "$out_line" == *saved* ]]; then
            echo "✓  $out"
            ok=$((ok+1))
        else
            echo "✗  $out_line"
            fail=$((fail+1))
        fi
    else
        echo "✗  $out_line"
        fail=$((fail+1))
    fi
    sleep "$SLEEP"
done

echo "---"
echo "Done: $ok ok, $fail failed. Output: $OUT_DIR"
[ "$fail" -eq 0 ]
