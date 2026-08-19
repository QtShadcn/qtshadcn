#!/usr/bin/env bash
# 给所有 showcase 组件页生成 PNG 截图，输出到 docs/public/images/components/。
# 依赖：showcase 已 make build（offscreen 平台下 grabWindow 渲染）。
#
# 用法：
#   ./scripts/screenshot.sh                            # 全量
#   ./scripts/screenshot.sh button select textarea     # 只截指定组件（slug 或 Page 名）
#   SHOWCASE=... ./scripts/screenshot.sh               # 自定义二进制
#   OUT_DIR=... ./scripts/screenshot.sh                # 自定义输出
#   CROP="190,0,790,704" ./scripts/screenshot.sh       # 裁剪矩形 x,y,w,h（默认裁左侧菜单）
#   CROP="" ./scripts/screenshot.sh                    # 不裁剪（整窗 980×720）
#   SHOT_DELAY_MS=2000 SLEEP=1 ./scripts/screenshot.sh # 更慢更稳（复杂页面）
#   SKIP_OVERVIEW=1 ./scripts/screenshot.sh            # 跳过表单等非纯组件页

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SHOWCASE="${SHOWCASE:-$ROOT/build/bin/showcase}"
OUT_DIR="${OUT_DIR:-$ROOT/docs/public/images/components}"
QML_IMPORT_PATH="${QML_IMPORT_PATH:-$ROOT/build/src:$ROOT/build/examples/showcase}"
# 裁剪矩形 "x,y,width,height"：默认裁掉左侧菜单（190px）；设 "" 或 "0,0,980,720" = 整窗
CROP="${CROP-190,0,790,704}"

# 位置参数 = 只截这些组件（slug 如 button/button-group 或 Page 名如 ButtonPage.qml）；为空 = 全量
TARGETS=("$@")

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

    # 指定了目标组件则只截这些（slug 或 Page 名匹配）
    if [ "${#TARGETS[@]}" -gt 0 ]; then
        match=0
        for t in "${TARGETS[@]}"; do
            if [ "$t" = "$name" ] || [ "$t" = "$page_name" ] || [ "$t" = "${page_name%.qml}" ]; then
                match=1; break
            fi
        done
        [ "$match" -eq 0 ] && continue
    fi

    # 跳过表单等非纯组件页（默认全截；SKIP_OVERVIEW=1 跳过）
    case "$name" in
        form) [ -n "${SKIP_OVERVIEW:-}" ] && { echo "  skip  $name"; continue; } ;;
    esac

    printf "  → %-16s (%s) " "$name" "$page_name"
    crop_arg=()
    if [ -n "$CROP" ]; then
        crop_arg=(--crop "$CROP")
    fi
    if out_line="$("$SHOWCASE" --screenshot "$page_name" --output "$out" "${crop_arg[@]}" 2>&1)"; then
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
