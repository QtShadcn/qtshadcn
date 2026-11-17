pragma ComponentBehavior: Bound

import QtQuick
import QtTest
import QtShadcn

// ShadcnPopupPosition：弹层边界翻转 / 钳制
//
// 回归锁定：三处弹层（DropdownMenu / Select / Tooltip）曾把 y 硬编码成
// 「trigger 下方 + offset」，靠近窗口底部时整块被顶出可视区。用例按 Radix 的
// 四条规则钉住行为：放得下不翻、放不下翻、两边都放不下钳高、横向溢出钳回。
//
// 另外两条容易写错、肉眼又看不出来的：
//   - 坐标必须经 mapToItem(container) 换算（直接读 anchor.y 拿的是父项坐标，
//     跨层容器如带 padding 的 Card 里会整体偏移）
//   - mapToItem 是 C++ 调用，不会建立 QML 绑定依赖（改 anchor.y 不重算），
//     所以「布局变化后位置要跟动」必须单独测
Item {
    id: root
    width: 480
    height: 320

    // 400×300 的独立边界：用例自己定尺寸，不依赖窗口大小
    Item {
        id: bounds
        x: 20
        y: 10
        width: 400
        height: 300

        // 有过偏移的宿主，用来验证「跨层容器」的坐标换算
        Item {
            id: host
            x: 30
            y: 40

            Item {
                id: trigger
                x: 100
                y: 20
                width: 120
                height: 32
            }
        }
    }

    Component {
        id: placementComp
        ShadcnPopupPosition {
            container: bounds
            anchor: trigger
            popupWidth: 180
            popupHeight: 120
        }
    }

    TestCase {
        name: "ShadcnPopupPosition"
        when: windowShown

        readonly property real pad: 8

        // 每个用例都从干净状态开始：几何会被单个用例改动
        function init() {
            trigger.x = 100
            trigger.y = 20
            trigger.width = 120
            trigger.height = 32
            host.x = 30
            host.y = 40
        }

        function make(props) {
            var p = createTemporaryObject(placementComp, root, props || {})
            verify(!!p, "ShadcnPopupPosition exists")
            return p
        }

        // ── 默认：下方放得下 → 不翻转 ──
        function test_fits_below_keeps_bottom_side() {
            const p = make()

            // trigger 在 container 里的绝对位置 = host(30,40) + trigger(100,20)
            compare(p.anchorRect.x, 130)
            compare(p.anchorRect.y, 60)
            compare(p.anchorRect.width, 120)
            compare(p.anchorRect.height, 32)

            compare(p.resolvedSide, "bottom", "放得下就不该翻")
            compare(p.x, 130)                       // 左对齐 trigger
            compare(p.y, 60 + 32 + 4)               // trigger 下方 + sideOffset
            compare(p.height, 120)                  // 未被钳制
            compare(p.clamped, false)
        }

        // ── 底部放不下 → 翻到上方 ──
        function test_overflows_bottom_flips_to_top() {
            trigger.y = 240                        // 距 container 底只剩很少空间
            const p = make()

            compare(p.resolvedSide, "top", "下方放不下应翻到上方")
            compare(p.clamped, false, "上方放得下就不该钳制")
            compare(p.y, 240 + 40 - 4 - 120)       // trigger.top - sideOffset - height
            verify(p.y >= 0)
        }

        // ── 两侧都放不下 → 选空间大的一侧并钳高 ──
        function test_neither_side_fits_clamps_height() {
            // 边界只有 200 高；anchor 绝对 y = 60（host 40 + trigger 20）
            //   下方空间 = 200 - 8 - (60 + 32 + 4) = 96
            //   上方空间 = (60 - 4) - 8            = 48   → 取下方
            bounds.height = 200
            const p = make({ popupHeight: 300 })

            compare(p.clamped, true, "两侧都放不下必须钳制")
            compare(p.resolvedSide, "bottom", "取空间更大的一侧")
            verify(p.height < 300, "高度应被钳制")
            compare(p.availableHeight, 96)
            compare(p.height, 96)
            compare(p.y, 60 + 32 + 4)
            // 钳制后仍不越界
            verify(p.y + p.height <= 200 - pad)
            bounds.height = 300
        }

        // ── 上方空间更大时钳制也应选上方 ──
        function test_neither_side_fits_prefers_larger_top_space() {
            // anchor 绝对 y = 140（host 40 + trigger 100）
            //   下方空间 = 200 - 8 - (140 + 32 + 4) = 16
            //   上方空间 = (140 - 4) - 8            = 128  → 取上方
            bounds.height = 200
            trigger.y = 100
            const p = make({ popupHeight: 300 })

            compare(p.clamped, true)
            compare(p.resolvedSide, "top", "上方空间更大")
            compare(p.availableHeight, 128)
            compare(p.height, 128)
            compare(p.y, pad, "钳制后贴住碰撞内边距")
            bounds.height = 300
        }

        // ── 横向：右边缘溢出 → 钳回边界内 ──
        function test_horizontal_overflow_clamps_right_edge() {
            trigger.x = 300
            bounds.width = 400
            const p = make()

            compare(p.width, 180)
            compare(p.x, 400 - pad - 180, "右边缘应被钳回碰撞内边距")
            verify(p.x + p.width <= 400 - pad)
            verify(p.x >= pad)
            // 横向溢出不影响纵向方向
            compare(p.resolvedSide, "bottom")
        }

        // ── 横向：align=end / center ──
        function test_horizontal_align_end_and_center() {
            const end = make({ align: "end" })
            compare(end.x, 130 + 120 - 180)        // 右对齐 trigger，仍在边界内

            const center = make({ align: "center" })
            compare(center.x, Math.round(130 + (120 - 180) / 2))
        }

        // ── 坐标换算：必须用 container 坐标，而不是父项坐标 ──
        // 若实现直接读 anchor.y，这里会拿到 20（父项坐标系）而不是 60
        function test_uses_container_coordinates() {
            const p = make()
            compare(p.anchorRect.y, 60)
            compare(p.y, 96)

            // 整条祖先链平移 → 必须跟着动
            host.y = 90
            compare(p.anchorRect.y, 110)
            compare(p.y, 146)
        }

        // ── 布局变化后位置要跟动（mapToItem 不建立绑定依赖）──
        function test_updates_when_trigger_moves() {
            const p = make()
            compare(p.y, 96)

            // 仍要留在下方：300 - 8 - (130 + 32 + 4) = 126 >= 120
            trigger.y = 90
            compare(p.anchorRect.y, 130)
            compare(p.y, 166)

            trigger.height = 40
            compare(p.y, 174)
        }

        // ── 空间变小时自动翻面（resolvedSide 是绑定，不是一次性求值）──
        function test_side_follows_available_space() {
            const p = make()
            compare(p.resolvedSide, "bottom")

            trigger.y = 240
            compare(p.resolvedSide, "top")

            trigger.y = 20
            compare(p.resolvedSide, "bottom")
        }

        // ── resolvedSide 变化应通知（翻转后动画方向靠它）──
        function test_positioned_signal_reports_side() {
            const p = make()
            var seen = []
            p.positioned.connect(function(px, py, side) { seen.push(side) })

            trigger.y = 240
            compare(seen.length >= 1, true, "翻转应发出 positioned")
            compare(seen[seen.length - 1], "top")
        }

        // ── 门边界缺失时不应崩 / 不应产生 NaN ──
        function test_missing_anchor_is_safe() {
            const p = make({ anchor: null })
            compare(p.x, 0)
            compare(p.y, 0)
            compare(p.clamped, false)
        }
    }
}
