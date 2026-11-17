import QtQuick
import QtTest
import QtShadcn

// ShadcnFadeZoomTransition：弹层过渡的实际行为
//
// 为什么要有这份测试：抽出公共过渡件之后，「Transition 还生效吗」是最容易
// 静默坏掉的东西 —— 组件写错（比如 shown 传反、animations 结构不对）不会报错，
// 弹层照样打开，只是不再有渐入。截图也看不出来。只能靠运行时采样 opacity。
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

        // 进场：open() 后 opacity 应经历 (0,1) 的中间值，而不是直接跳到 1。
        // 采样点取 30ms（动画 100ms），此时必然还在过渡中。
        function test_dialog_enter_has_intermediate_opacity() {
            const d = createTemporaryObject(dlgComp, root)
            verify(!!d, "dialog created")

            compare(d.opacity, 1.0, "未打开时应是静止态 1.0")
            d.open()
            wait(30)
            const mid = d.opacity
            tryCompare(d, "opacity", 1.0)
            verify(mid < 1.0,
                   "opacity 应从 0 渐入；实测采样 " + mid + "（=1 说明 enter transition 没生效）")
        }

        // 退场同理：close() 之后 opacity 应掉到 1 以下再回到 0（或至少不再是 1）
        function test_dialog_exit_animates_out() {
            const d = createTemporaryObject(dlgComp, root)
            d.open()
            tryCompare(d, "opacity", 1.0)
            d.close()
            wait(30)
            const mid = d.opacity
            verify(mid < 1.0,
                   "退场时 opacity 应开始下降；实测 " + mid + "（=1 说明 exit transition 没生效）")
        }
    }
}
