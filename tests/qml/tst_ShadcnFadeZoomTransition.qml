import QtQuick
import QtTest
import QtShadcn

// ShadcnFadeZoomTransition：弹层过渡的实际行为
//
// 为什么要有这份测试：抽出公共过渡件之后，「Transition 还生效吗」是最容易
// 静默坏掉的东西 —— 组件写错（比如 shown 传反、animations 结构不对）不会报错，
// 弹层照样打开，只是不再有渐入。截图也看不出来。只能靠运行时采样 opacity。
//
// ── 采样策略（两次踩坑后定型）──────────────────────────────
//
// 第一版：「open() 后 wait(30)，读一次 opacity 断言 < 1」。本地 6.11 过，CI 的
// 6.8 挂了 —— 那里的动画启动更慢，30ms 时 opacity 还是 1。问题在于把「什么时候
// 开始动」也当成了断言对象；真正要验证的是「有没有过渡」，不是「第 30ms 处在第几帧」。
//
// 第二版：死循环轮询。同样不行 —— 忙等期间事件循环不推进，opacity 永远不变。
//
// 定版：小小地 wait() 一下让事件循环转起来（动画才能推进），逐帧采样整个动画窗口。
// 只要在窗口内**出现过**严格位于 (0,1) 的中间值，就证明在逐帧插值。这个判据对
// 启动延迟免疫，同时保留抓「动画被删掉」的能力 —— 没有过渡时 opacity 直接
// 由 1 跳到 0（或停在 1），永远不会落在开区间里。
Item {
    id: root
    width: 400
    height: 400

    Component {
        id: dlgComp
        ShadcnDialog {
            ShadcnDialogContent {
                ShadcnDialogHeader { ShadcnDialogTitle { text: "标题" } }
            }
        }
    }

    TestCase {
        name: "ShadcnFadeZoomTransition"
        when: windowShown

        // 在 2s 窗口内逐帧找中间值。用 wait() 推进事件循环 —— 忙等会让动画
        // 一帧都不走（QML 动画由事件循环驱动）。必须定义在 TestCase 内：
        // wait() 是 TestCase 方法，Item 层调不到。
        // 判据只看「是否出现过严格中间值」。不要在中途因为「已经到 0」就提前返回 ——
        // 进场动画正是从 0 开始涨，第 1 帧读到 0 是正常的，提前退出会误判成失败。
        function sawIntermediate(getter) {
            for (let i = 0; i < 200; ++i) {
                wait(5)
                const v = getter()
                if (v > 0.001 && v < 0.999)
                    return true
            }
            return false
        }

        // 进场：open() 后 opacity 从 0 涨到 1，中途必然出现 (0,1) 的中间值。
        // 若 enter transition 缺失，open() 会让 opacity 直接变成 1，观测不到中间态。
        function test_dialog_enter_has_intermediate_opacity() {
            const d = createTemporaryObject(dlgComp, root)
            verify(!!d, "dialog created")
            compare(d.opacity, 1.0, "未打开时是静止态 1.0")

            d.open()
            verify(sawIntermediate(function() { return d.opacity }),
                   "进场应观测到 (0,1) 的中间 opacity；从未出现说明 enter transition 没生效")

            tryCompare(d, "opacity", 1.0)
        }

        // 退场：close() 后同理，应观测到 (0,1) 的中间值。
        // 无 exit 过渡时 opacity 会停在 1（Popup 关闭并不改 opacity），同样观测不到。
        function test_dialog_exit_animates_out() {
            const d = createTemporaryObject(dlgComp, root)
            verify(!!d, "dialog created")
            d.open()
            tryCompare(d, "opacity", 1.0)

            d.close()
            verify(sawIntermediate(function() { return d.opacity }),
                   "退场应观测到 (0,1) 的中间 opacity；从未出现说明 exit transition 没生效")
        }

    }
}
