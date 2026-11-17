pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtTest
import QtShadcn

// 三个弹层窗口边界行为的端到端锁定（issue #16）
//
// 单测（tst_ShadcnPopupPosition.qml）锁的是定位算法本身；这里锁「组件真的
// 按算法的结果摆放」—— 接入时最容易错的不是算法，而是坐标系：弹层渲染在
// window overlay 层，popup.x/y 是**弹层父项**坐标系里的值，父项与定位器用的
// frame 不一致就会整体偏移（不报错、只是位置不对）。
//
// 另外钉住 issue 里的原始症状：贴近窗口底部的 Select / DropdownMenu /
// Tooltip 必须留在窗口内，而不是被顶到外面。
Item {
    id: root
    width: 500
    height: 400

    // ── 贴底 Select ──
    ShadcnSelect {
        id: sel
        x: 40
        y: 340
        width: 200
        model: ["一", "二", "三", "四", "五", "六"]
    }

    // ── 贴底 DropdownMenu ──
    ShadcnDropdownMenu {
        id: menu
        x: 300
        y: 340
        ShadcnDropdownMenuTrigger { text: "菜单" }
        ShadcnDropdownMenuContent {
            ShadcnDropdownMenuItem { text: "一" }
            ShadcnDropdownMenuItem { text: "二" }
            ShadcnDropdownMenuItem { text: "三" }
        }
    }

    // ── 贴底 Tooltip ──
    Item {
        id: tipHost
        x: 40
        y: 370
        width: 60
        height: 24
        ShadcnTooltip { id: tip; text: "读到底的提示"; open: true }
    }

    // ── 空间充足时的 DropdownMenu（不应翻转）──
    ShadcnDropdownMenu {
        id: menuTop
        x: 100
        y: 20
        ShadcnDropdownMenuTrigger { text: "顶部菜单" }
        ShadcnDropdownMenuContent {
            ShadcnDropdownMenuItem { text: "一" }
            ShadcnDropdownMenuItem { text: "二" }
        }
    }

    TestCase {
        name: "popup_placement_integration"
        when: windowShown

        // ── Select：贴底必须翻到上方并留在窗口内 ──
        function test_select_stays_inside_window() {
            sel.popup.open()
            tryCompare(sel.popup, "opened", true)
            wait(80)

            const p = sel.popup
            verify(p.y + p.height <= root.height,
                   "Select 弹层越出窗口底边: y=" + p.y + " h=" + p.height)
            verify(p.y >= 0, "Select 弹层越出窗口顶边: y=" + p.y)
            verify(p.x >= 0 && p.x + p.width <= root.width, "Select 弹层横向越界")
            // 触发器在 y=340，弹层高度 > 40 → 必须翻到上方
            verify(p.y < 340, "底部空间不够时应翻到触发器上方，实际 y=" + p.y)
            sel.popup.close()
        }

        // ── Select：空间充足时不翻转 ──
        function test_select_no_flip_when_space_below() {
            const wasY = sel.y
            sel.y = 20
            sel.popup.open()
            tryCompare(sel.popup, "opened", true)
            wait(80)

            const p = sel.popup
            verify(p.y >= 20 + sel.height, "下方放得下时应在触发器下方，实际 y=" + p.y)
            sel.popup.close()
            sel.y = wasY
        }

        // ── Tooltip：贴底翻到上方，且横向不出窗口 ──
        function test_tooltip_stays_inside_window() {
            wait(120)
            // Tooltip 是 open:true 常显，直接读它的定位结果
            const y = tip.popup.y
            const h = tip.popup.height
            const x = tip.popup.x
            const w = tip.popup.width

            verify(y + h <= root.height, "Tooltip 越出窗口底边: y=" + y + " h=" + h)
            verify(y >= 0, "Tooltip 越出窗口顶边: y=" + y)
            verify(x >= 0 && x + w <= root.width, "Tooltip 横向越界: x=" + x + " w=" + w)
            // 宿主在 y=370、高 24（底边 394），气泡放不下 → 翻到上方
            verify(y < 370, "贴底 Tooltip 应翻到上方，实际 y=" + y)
            compare(tip.placement.resolvedSide, "top")
        }

        // ── DropdownMenu：贴底翻转 ──
        function test_dropdown_menu_stays_inside_window() {
            menu.open = true
            wait(120)

            const y = menu.placement.y
            const h = menu.placement.height
            verify(menu.placement.resolvedSide === "top",
                   "贴底菜单应翻到上方，实际 " + menu.placement.resolvedSide)
            verify(y + h <= root.height, "DropdownMenu 越出窗口底边: y=" + y + " h=" + h)
            menu.open = false
        }

        // ── DropdownMenu：空间充足时保持下方 ──
        function test_dropdown_menu_no_flip() {
            menuTop.open = true
            wait(120)
            compare(menuTop.placement.resolvedSide, "bottom")
            // 菜单容器在 y=20，trigger 高 32 → 弹层 y = 20 + 32 + 4(sideOffset)
            compare(menuTop.placement.y, 20 + 32 + 4)
            menuTop.open = false
        }

        // ── 弹层父项必须与定位器坐标系一致（overlay 层）──
        function test_popup_parent_matches_placement_frame() {
            menu.open = true
            wait(80)
            compare(menu.placement.frame, Overlay.overlay,
                    "DropdownMenu 弹层父项应是 overlay")
            compare(sel.placement.frame, Overlay.overlay,
                    "Select 弹层父项应是 overlay")
            menu.open = false
        }
    }
}
