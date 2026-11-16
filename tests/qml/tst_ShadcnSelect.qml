import QtQuick
import QtTest
import QtShadcn

// ShadcnSelect：委托文本的取值来源
//
// 回归锁定：旧实现用 Array.isArray(model) 分流，C++ 的 QVariantList /
// QStringList 在 QML 里 Array.isArray 为 false，于是去查 model[textRole]，
// 而 model 不是「当前记录」，结果 String(undefined) 显示成字面量 "undefined"。
// 现在统一从 delegate 注入的 modelData 取 textRole 字段。
Item {
    id: root
    width: 600
    height: 700

    Component {
        id: stringModelComp
        ShadcnSelect {
            width: 240
            model: [qsTr("苹果"), qsTr("香蕉"), qsTr("橙子")]
        }
    }

    Component {
        id: listModelComp
        // 两个 role：单 role 时 QML 会把 modelData 直接当值用，测不到 textRole 取值
        ShadcnSelect {
            width: 240
            textRole: "label"
            model: ListModel {
                ListElement { label: "对象甲"; code: "a" }
                ListElement { label: "对象乙"; code: "b" }
            }
        }
    }

    Component {
        id: objectArrayComp
        ShadcnSelect {
            width: 240
            textRole: "name"
            model: [
                { name: "甲" },
                { name: "乙" }
            ]
        }
    }

    // C++ 侧 QVariantList（测试 runner 通过 context property 注入）
    Component {
        id: cppModelComp
        ShadcnSelect {
            width: 240
            textRole: "label"
            // qmllint disable unqualified
            // TestCppModel 由 qmltests_main.cpp 用 setContextProperty 注入，
            // 它不在任何 QML 作用域里，没有 id 可以限定 —— 唯一合理的例外。
            model: TestCppModel
            // qmllint enable unqualified
        }
    }

    TestCase {
        name: "ShadcnSelect"
        when: windowShown

        // 展开下拉并返回第一项的显示文本
        function firstDelegateText(select) {
            select.popup.open()
            tryCompare(select.popup, "opened", true)

            const list = select.popup.contentItem
            verify(!!list, "Object exists")
            tryVerify(function() { return list.count > 0 && list.itemAtIndex(0) !== null })

            const label = findChild(list.itemAtIndex(0), "delegateText")
            verify(!!label, "Object exists")
            return label.text
        }

        // JS 字符串数组：委托直接显示字符串本身
        function test_string_array_model() {
            const select = createTemporaryObject(stringModelComp, root)
            verify(!!select, "Component exists")
            compare(select.displayText, qsTr("苹果"))
            compare(firstDelegateText(select), qsTr("苹果"))
        }

        // ListModel + textRole：委托要显示 label 字段，不能是 "undefined"
        // （ListModel 不是 JS 数组，正是 Array.isArray 分流踩雷的形态之一）
        function test_list_model_with_text_role() {
            const select = createTemporaryObject(listModelComp, root)
            verify(!!select, "Component exists")
            compare(select.displayText, qsTr("对象甲"))

            const text = firstDelegateText(select)
            compare(text, qsTr("对象甲"))
            verify(text !== "undefined")
        }

        // JS 对象数组 + textRole
        function test_object_array_with_text_role() {
            const select = createTemporaryObject(objectArrayComp, root)
            verify(!!select, "Component exists")
            compare(firstDelegateText(select), qsTr("甲"))
        }

        // C++ 的 QVariantList + textRole：正是把「Array.isArray 分流」打穿的那种输入
        function test_cpp_list_model_with_text_role() {
            const select = createTemporaryObject(cppModelComp, root)
            verify(!!select, "Component exists")

            const text = firstDelegateText(select)
            compare(text, "C++甲")
            verify(text !== "undefined")
        }
    }
}
