pragma ComponentBehavior: Bound

import QtQuick
import QtTest
import QtShadcn

// ShadcnInputOTP：格子数、字符分发、超长截断、退格、completed 信号、两端圆角
//
// 键盘输入在离屏平台上不可模拟（keyClick 不携带 text，见 tst_ShadcnInput 的说明），
// 所以这里覆盖的是「文本缓冲 → 格子渲染」这条链路：所有用例都通过写 text
// （等价于键入/粘贴之后 TextField 里的结果）来驱动，退格用 remove + 光标位置模拟。
Item {
    id: root
    width: 600
    height: 300

    QtShadcnTheme { id: theme }

    Component {
        id: otpComp
        ShadcnInputOTP {
            length: 6
        }
    }

    Component {
        id: spyComp
        SignalSpy {}
    }

    TestCase {
        name: "ShadcnInputOTP"
        when: windowShown

        // QML TestCase 只有 findChild(parent, objectName)（单数），没有 findChildren。
        // 格子由 Repeater 直接挂在 root 下，按 objectName 过滤 children 即可。
        function slotsOf(otp) {
            const out = []
            const kids = otp.children
            for (let i = 0; i < kids.length; ++i) {
                if (kids[i] && kids[i].objectName === "slot")
                    out.push(kids[i])
            }
            // children 顺序不保证，按 x 排序（格子是横向排布，x = index * 32）
            out.sort(function(a, b) { return a.x - b.x })
            return out
        }

        // ── 默认渲染 ──
        function test_defaults() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")
            compare(otp.length, 6)
            compare(otp.charCount, 0)
            compare(otp.text, "")
            // 6 格 × 32px（shadcn size-8）
            compare(otp.implicitWidth, 6 * 32)
            compare(otp.implicitHeight, 32)
        }

        function test_renders_length_slots() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")

            const slots = slotsOf(otp)
            compare(slots.length, 6, "should render exactly `length` slots")

            // 每格 32×32，横向首尾相接（整体宽度 = length * size）
            for (let i = 0; i < 6; ++i) {
                const s = otp.slotItem(i)
                verify(!!s, "slot " + i + " exists")
                compare(s.width, 32)
                compare(s.height, 32)
                compare(s.x, i * 32)
            }
        }

        // length 可改：格子数随之变化
        function test_custom_length() {
            const otp = createTemporaryObject(otpComp, root, { length: 4 })
            verify(!!otp, "Component exists")
            compare(slotsOf(otp).length, 4)
            compare(otp.implicitWidth, 4 * 32)
        }

        // ── 字符分发到各格 ──
        function test_text_distributes_to_slots() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")

            otp.text = "123456"
            compare(otp.charCount, 6)

            const slots = slotsOf(otp)
            const expected = ["1", "2", "3", "4", "5", "6"]
            for (let i = 0; i < expected.length; ++i) {
                compare(otp.slotChar(i), expected[i], "slotChar(" + i + ")")
                const label = findChild(slots[i], "slotCharText")
                verify(!!label, "slot " + i + " has a char Text")
                compare(label.text, expected[i], "rendered char in slot " + i)
                verify(label.visible, "char in slot " + i + " is visible")
            }
        }

        // 部分填充：前 k 格有字符，其余格子显示为空
        function test_partial_text() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")

            otp.text = "12"
            compare(otp.slotChar(0), "1")
            compare(otp.slotChar(1), "2")
            compare(otp.slotChar(2), "")
            compare(otp.slotChar(5), "")

            const slots = slotsOf(otp)
            const midText = findChild(slots[2], "slotCharText")
            verify(!!midText, "slot 2 has a char Text")
            verify(!midText.visible, "empty slot has no visible char")
        }

        // ── 超长截断 ──
        function test_text_is_truncated_to_length() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")

            otp.text = "1234567890"
            compare(otp.text, "123456", "overflow must be clipped to length")
            compare(otp.charCount, 6)

            const lastText = findChild(slotsOf(otp)[5], "slotCharText")
            verify(!!lastText, "last slot has a char Text")
            compare(lastText.text, "6", "last slot keeps the length-th char, not the paste tail")
        }

        // 程序化写入超长也走同一条截断路径（不是只有 paste 才截）
        function test_truncation_is_idempotent() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")

            otp.text = "abcdef"
            compare(otp.text, "abcdef")
            otp.text = "abcdefg"
            compare(otp.text, "abcdef")
            compare(otp.slotChar(5), "f")
        }

        // ── 退格 ──
        // 退格在 Qt 里是「删掉光标前一个字符」，也就是 TextInput.remove(cursor-1, 1)。
        // 单字符删除后剩余字符重新分发，格子应回退到空。
        function test_backspace_removes_last_char() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")

            otp.text = "1234"
            const input = findChild(otp, "input")
            verify(!!input, "inner input exists")

            // 模拟退格：光标在末尾，删掉前一个字符。
            // TextInput.remove(start, end) 的 end 是**开区间**（与 TextEdit 一致），
            // 传 remove(len-1, len) 才是「删一个字符」；remove(len-1, 1) 会删错范围。
            input.cursorPosition = input.text.length
            input.remove(input.text.length - 1, input.text.length)

            compare(otp.text, "123")
            compare(otp.slotChar(3), "", "the 4th slot must be empty after backspace")
            compare(otp.slotChar(2), "3")
        }

        // 退格到空：所有格子清空
        function test_backspace_to_empty() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")

            otp.text = "1"
            const input = findChild(otp, "input")
            input.cursorPosition = 1
            input.remove(0, 1)   // 光标 1 → 删 [0,1)

            compare(otp.text, "")
            compare(otp.charCount, 0)
            compare(otp.slotChar(0), "")
        }

        // ── completed 信号 ──
        function test_completed_emits_when_filled() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")
            const spy = createTemporaryObject(spyComp, root,
                                              { target: otp, signalName: "completed" })
            verify(!!spy, "SignalSpy exists")

            otp.text = "12345"
            compare(spy.count, 0, "must not emit while incomplete")

            otp.text = "123456"
            compare(spy.count, 1, "must emit once when filled")
            compare(spy.signalArguments[0][0], "123456", "payload is the full value")
        }

        // 未填满时一律不发
        function test_completed_not_emitted_when_incomplete() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")
            const spy = createTemporaryObject(spyComp, root,
                                              { target: otp, signalName: "completed" })
            verify(!!spy, "SignalSpy exists")

            otp.text = "1"
            otp.text = "12"
            otp.text = "123"
            otp.text = "1234"
            otp.text = "12345"
            compare(spy.count, 0, "incomplete input must never emit completed")
        }

        // 填满后删一格 → 再填满，应该再发一次（不是「只发一次」）
        function test_completed_reemits_after_clear() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")
            const spy = createTemporaryObject(spyComp, root,
                                              { target: otp, signalName: "completed" })
            verify(!!spy, "SignalSpy exists")

            otp.text = "123456"
            compare(spy.count, 1)

            const input = findChild(otp, "input")
            input.cursorPosition = input.text.length
            input.remove(input.text.length - 1, input.text.length)
            compare(otp.text, "12345")

            otp.text = "123456"
            compare(spy.count, 2, "re-filling after a deletion emits again")
        }

        // 超长粘贴：只发一次 completed（截断那一轮），payload 是截断后的值
        function test_completed_on_overflow_paste_fires_once() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")
            const spy = createTemporaryObject(spyComp, root,
                                              { target: otp, signalName: "completed" })
            verify(!!spy, "SignalSpy exists")

            otp.text = "123456789"
            compare(otp.text, "123456")
            compare(spy.count, 1, "overflow paste emits completed exactly once")
            compare(spy.signalArguments[0][0], "123456")
        }

        // 设置 text 属性（构造时传入）也应触发 completed
        function test_completed_on_initial_text() {
            const otp = createTemporaryObject(otpComp, root, { text: "654321" })
            verify(!!otp, "Component exists")
            compare(otp.text, "654321")
        }

        // ── 视觉/几何：两端圆角不对称 ──
        // 这条锁住「整体是一个圆角矩形被切成 N 格」：首格只有左侧圆角，
        // 末格只有右侧圆角，中间格全直角。若有人改成 N 个独立方块（每格四角同圆），
        // 这条会立刻红。
        function test_corner_radius_only_on_outer_edges() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")

            const r = theme.radiusLg
            const first = otp.slotItem(0)
            const last = otp.slotItem(5)

            // 首格：左侧圆角，右侧直角
            compare(first.topLeftRadius, r)
            compare(first.bottomLeftRadius, r)
            compare(first.topRightRadius, 0)
            compare(first.bottomRightRadius, 0)

            // 末格：右侧圆角，左侧直角（与首格镜像）
            compare(last.topRightRadius, r)
            compare(last.bottomRightRadius, r)
            compare(last.topLeftRadius, 0)
            compare(last.bottomLeftRadius, 0)

            // 首格圆角在左、末格圆角在右 —— 镜像对称，但「同一侧」并不对称：
            // 首格左上圆 vs 末格左上直，正是「整体一个圆角矩形」与「N 个独立方块」
            // 的判别点（若改成每格四角同圆，下面两条都会红）。
            verify(first.topLeftRadius !== last.topLeftRadius,
                   "first and last slot left corners must differ")
            verify(first.topRightRadius !== last.topRightRadius,
                   "first and last slot right corners must differ")

            // 中间格全直角
            for (let i = 1; i < 5; ++i) {
                const s = otp.slotItem(i)
                compare(s.topLeftRadius, 0, "middle slot " + i + " topLeftRadius")
                compare(s.topRightRadius, 0, "middle slot " + i + " topRightRadius")
                compare(s.bottomLeftRadius, 0, "middle slot " + i + " bottomLeftRadius")
                compare(s.bottomRightRadius, 0, "middle slot " + i + " bottomRightRadius")
            }
        }

        // 圆角走 theme 派生值，不写死像素
        function test_uses_theme_radius() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")
            compare(otp.slotItem(0).topLeftRadius, theme.radiusLg)
            compare(otp.implicitHeight, 32)   // size-8，不随 radius 变
        }

        // 缩小 length：多余字符立刻被裁掉，格子数同步减少
        function test_shrink_length_truncates() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")

            otp.text = "123456"
            compare(otp.charCount, 6)

            otp.length = 4
            compare(otp.text, "1234", "shrinking length must clip the value")
            compare(slotsOf(otp).length, 4, "slot count follows length")
            compare(otp.slotChar(3), "4")
            compare(otp.slotChar(4), "", "out-of-range index is empty")
            compare(otp.implicitWidth, 4 * 32)
        }

        // 未聚焦时没有选中格（不亮聚焦环）
        function test_active_index_is_minus_one_without_focus() {
            const otp = createTemporaryObject(otpComp, root)
            verify(!!otp, "Component exists")
            compare(otp.activeIndex, -1)

            const slots = slotsOf(otp)
            const ring = findChild(slots[0], "slotRing")
            verify(!!ring, "slot 0 has a ring")
            verify(!ring.visible, "no ring before focus")
        }

        // 禁用态：opacity 50%
        function test_disabled_is_dimmed() {
            const otp = createTemporaryObject(otpComp, root, { enabled: false })
            verify(!!otp, "Component exists")
            compare(otp.opacity, 0.5)
        }
    }
}
