pragma ComponentBehavior: Bound

import QtQuick
import QtTest
import QtShadcn

// ShadcnTextarea：textEdited 转发语义 + 高度钳制
//
// 这份测试的重点是 textEdited。TextEdit 的 textEdited 信号是 Qt 6.9 才引入的
// （qmltypes revision 1545），而项目最低支持 6.5 —— 早先的实现直接写
// `onTextEdited:` 在 6.8 上既过不了 qmllint，运行时也是死信号。
// 现在改用 textChanged 转发 + 创建期守卫，这两个用例锁住「该发的发、不该发的不发」。
Item {
    id: root
    width: 600
    height: 400

    Component {
        id: textareaComp
        ShadcnTextarea {}
    }

    // 故意把 onTextEdited 写在 text 之前 —— QML 按书写顺序应用属性，
    // 这样初始赋值发生时 handler 已经连上，创建期误发才暴露得出来。
    // （用 createTemporaryObject 的 properties 传 text 测不出：属性在对象创建
    //   完成之后才应用，等 SignalSpy 挂上去时信号早就发完了，永远是假绿。）
    Component {
        id: prefilledComp
        ShadcnTextarea {
            property int emittedCount: 0
            onTextEdited: emittedCount++
            text: "初始内容"
        }
    }

    Component {
        id: spyComp
        SignalSpy {}
    }

    TestCase {
        name: "ShadcnTextarea"
        when: windowShown

        // 外部写初始 text 属于初始化，不是用户编辑，不应触发 textEdited
        function test_initial_text_does_not_emit() {
            const ta = createTemporaryObject(prefilledComp, root)
            verify(!!ta, "Component exists")
            compare(ta.text, "初始内容")
            // 等到创建期彻底结束再看，避免抢在 textChanged 之前断言
            wait(50)
            compare(ta.emittedCount, 0, "initial text assignment must not emit textEdited")
        }

        // 用户输入必须发出，且带上编辑后的完整文本
        function test_typing_emits_text_edited() {
            const ta = createTemporaryObject(textareaComp, root)
            verify(!!ta, "Component exists")
            const spy = createTemporaryObject(spyComp, root,
                                              { target: ta, signalName: "textEdited" })
            verify(!!spy, "SignalSpy exists")

            const edit = findChild(ta, "edit")
            verify(!!edit, "inner TextEdit exists")
            edit.forceActiveFocus()
            edit.insert(0, "abc")

            tryCompare(spy, "count", 1)
            compare(spy.signalArguments[0][0], "abc")
            compare(ta.text, "abc")
        }

        // 空内容时高度取下限 64（shadcn min-h-16）
        function test_min_height_is_64() {
            const ta = createTemporaryObject(textareaComp, root)
            verify(!!ta, "Component exists")
            tryCompare(ta, "implicitHeight", 64)
        }

        // 内容超过 maxHeight 时高度被钳住，由内部 Flickable 滚动
        function test_height_clamped_by_max_height() {
            const ta = createTemporaryObject(textareaComp, root,
                                             { maxHeight: 100, width: 120 })
            verify(!!ta, "Component exists")
            const edit = findChild(ta, "edit")
            verify(!!edit, "inner TextEdit exists")

            // 塞足够多的行，让内容自然高度远超 100
            edit.text = Array.from({ length: 40 }, (_, i) => "第 " + i + " 行").join("\n")
            tryVerify(function() { return edit.implicitHeight > 100 }, 5000,
                      "content should overflow")
            tryCompare(ta, "implicitHeight", 100)
        }

        // placeholder 只在内容为空时显示
        function test_placeholder_visibility() {
            const ta = createTemporaryObject(textareaComp, root,
                                             { placeholderText: "请输入" })
            verify(!!ta, "Component exists")

            const placeholder = findChild(ta, "placeholder")
            verify(!!placeholder, "placeholder Text exists")
            verify(placeholder.visible, "visible when empty")
            ta.text = "有内容"
            verify(!placeholder.visible, "hidden when filled")
        }
    }
}
