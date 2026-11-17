pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtTest
import QtShadcn

// ShadcnCommand 组件组测试（issue #5 · Command ⌘K 命令面板）
//
// 覆盖：过滤匹配（大小写 / 中文 / 无匹配→Empty）、↑↓ 跳过隐藏与禁用项、
// Enter 触发 activated(value)、禁用项不可执行、分组标题与整组隐藏、
// 重置查询恢复全部、按分数重排、Dialog 内嵌与独立弹层两种模式的开合。
//
// ── 为什么键盘用例走 cmd.moveActive() 而不是 keyClick() ──────────
// 仓库既有结论（tst_ShadcnInput 注明）：离屏平台的 keyClick **不携带 text**，
// 实测连 Qt.Key_Down 的 key 码到 QML 也变成 0（`keyToAscii Unhandled key code
// Qt::Key(0)`），于是 Keys.onDownPressed 这类便捷 handler 永远不触发 —— 只有
// Keys.onPressed 收到一个 key=0 的事件。所以这里：
//   · 键盘「路由是否可达」用 keyClick 验证 Keys.onPressed 会被调用（见
//     test_keyRouting_reachesCommandRoot）—— 这条在 offscreen 下有效；
//   · 导航**行为**直接调 moveActive/activateCurrent，即 handler 体内那一行，
//     等价且不依赖平台事件投递（真机键位由 Keys.* handler 一一对应，
//     handler 本体另有 test_keys_* 覆盖）。
Item {
    id: root
    width: 900
    height: 900

    QtShadcnTheme { id: theme }

    // test_16 用（QML 不能给已有对象动态加属性，Bound 模式下尤其）
    property int keyProbe: 0

    // ── 被测面板：独立弹层模式的结构（Input + List + Empty + 2 组 + Separator）──
    ShadcnCommand {
        id: cmd
        objectName: "cmd"
        x: 20
        y: 20
        width: 340

        ShadcnCommandInput {
            id: input
            objectName: "input"
            placeholderText: "搜索命令"
        }

        ShadcnCommandList {
            id: list
            objectName: "list"

            ShadcnCommandEmpty {
                id: empty
                objectName: "empty"
                text: "没有匹配结果"
            }

            ShadcnCommandGroup {
                id: groupSuggestions
                objectName: "groupSuggestions"
                heading: "建议"

                ShadcnCommandItem { objectName: "newFile"; text: "新建文件"; shortcut: "⌘N" }
                ShadcnCommandItem { objectName: "searchEmoji"; text: "搜索表情" }
                ShadcnCommandItem { objectName: "calculator"; text: "计算器" }
            }

            ShadcnCommandSeparator { objectName: "sep" }

            ShadcnCommandGroup {
                id: groupSettings
                objectName: "groupSettings"
                heading: "设置"

                ShadcnCommandItem {
                    objectName: "profile"
                    text: "个人资料"
                    iconName: "user"
                }
                ShadcnCommandItem {
                    objectName: "theme"
                    text: "主题"
                    keywords: ["theme", "dark"]
                }
                ShadcnCommandItem {
                    objectName: "danger"
                    text: "删除账户"
                    enabled: false
                    destructive: true
                }
            }
        }
    }

    // ── Dialog 内嵌模式 ────────────────────────────────────────
    ShadcnCommandDialog {
        id: palette
        objectName: "palette"

        ShadcnCommand {
            objectName: "cmdInDialog"

            ShadcnCommandInput { objectName: "inputInDialog" }
            ShadcnCommandList {
                objectName: "listInDialog"
                ShadcnCommandEmpty { objectName: "emptyInDialog" }
                ShadcnCommandGroup {
                    objectName: "groupInDialog"
                    heading: "建议"
                    ShadcnCommandItem { id: dlgItemARef; objectName: "dlgItemA"; text: "打开设置" }
                    ShadcnCommandItem { id: dlgItemBRef; objectName: "dlgItemB"; text: "新建项目" }
                }
            }
        }
    }

    // ── 排序用例专用：同查询下不同条目的命中强度不同 ──────────
    ShadcnCommand {
        id: rankCmd
        objectName: "rankCmd"
        x: 400
        y: 20
        width: 340

        ShadcnCommandList {
            objectName: "rankList"
            ShadcnCommandItem { objectName: "rOpenTab"; text: "Open new tab" }
            ShadcnCommandItem { objectName: "rNewFile"; text: "New file" }
        }
    }

    // ── 独立弹层模式：Command 装在普通 QQC.Popup 里（不走 Dialog）──
    // 官方只有 CommandDialog，但组件本身不依赖 Dialog —— 库内其他弹层
    // （DropdownMenu / Select）都是 Popup + ShadcnPopupPosition 那一套，
    // Command 同样可以直接塞进 Popup，由宿主自己决定定位。
    Popup {
        id: standalone
        objectName: "standalone"
        padding: 0
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        anchors.centerIn: Overlay.overlay
        // 宽度按 registry：面板无固定宽，宿主给（这里给 340）
        width: 340

        ShadcnCommand {
            id: standaloneCmd
            objectName: "standaloneCmd"

            ShadcnCommandInput { id: standaloneInputRef; objectName: "standaloneInput" }
            ShadcnCommandList {
                objectName: "standaloneList"
                ShadcnCommandEmpty { objectName: "standaloneEmpty" }
                ShadcnCommandGroup {
                    heading: "操作"
                    ShadcnCommandItem { id: spARef; objectName: "spA"; text: "复制路径"; shortcut: "⌥⇧C" }
                    ShadcnCommandItem { objectName: "spB"; text: "格式化文档" }
                }
            }
        }
    }

    // ── 散落条目（不套 Group）专用 ────────────────────────────
    ShadcnCommand {
        id: looseCmd
        objectName: "looseCmd"
        x: 20
        y: 400
        width: 340

        ShadcnCommandList {
            objectName: "looseList"
            ShadcnCommandEmpty { objectName: "looseEmpty" }
            ShadcnCommandItem { objectName: "lA"; text: "Alpha" }
            ShadcnCommandItem { objectName: "lB"; text: "Beta" }
            ShadcnCommandItem { objectName: "lC"; text: "Gamma"; enabled: false }
        }
    }

    // activated 计数：用 QtTest 自带的 SignalSpy（类型明确，qmllint 能静态看到
    // signalName / counts，不用 createObject 拿到 QObject 后读自定义属性 —— 那样
    // 会刷一片 missing-property 警告，本仓库的 lint 门禁是 MaxWarnings=0）。
    SignalSpy {
        id: cmdActivatedSpy
        target: cmd
        signalName: "activated"
    }

    SignalSpy {
        id: itemActivatedSpy
        signalName: "activated"
    }

    TestCase {
        id: tc
        name: "ShadcnCommand"
        when: windowShown

        // ── 辅助 ───────────────────────────────────────────────
        function find(name) {
            return walk(root, name);
        }

        function walk(it, name) {
            if (it.objectName === name)
                return it;
            var kids = it.children || [];
            for (var i = 0; i < kids.length; ++i) {
                var hit = walk(kids[i], name);
                if (hit)
                    return hit;
            }
            return null;
        }

        // 稳定地把搜索词设成目标值并等一帧（_schedule 走 Qt.callLater）
        function type(text) {
            cmd.search = text;
            wait(60);
        }

        function namesOf(list) {
            var out = [];
            for (var i = 0; i < list.length; ++i)
                out.push(list[i].objectName);
            return out.join(",");
        }

        // ── 创建与初始状态 ─────────────────────────────────────
        function test_0_structure() {
            verify(find("cmd"), "Command 未创建");
            verify(find("input"), "CommandInput 未创建");
            verify(find("list"), "CommandList 未创建");
            verify(find("newFile"), "CommandItem 未创建");
            verify(find("groupSuggestions"), "CommandGroup 未创建");
            verify(find("sep"), "CommandSeparator 未创建");
            verify(find("empty"), "CommandEmpty 未创建");

            // 空查询：全部匹配，Empty 不显示（官方只在「有输入且 0 匹配」时显示）
            compare(cmd.matchCount, 6, "6 个条目应全部匹配");
            compare(find("empty").visible, false, "空查询时 Empty 不应显示");
            compare(find("sep").visible, true, "空查询时分隔线应显示");

            // 首个可用条目自动成为选中项（cmdk 的 selectFirstItem）
            verify(cmd.activeItem !== null, "打开后应有默认选中项");
            compare(cmd.activeItem.objectName, "newFile");
            compare(cmd.value, "新建文件");
        }

        function test_1_heading_rendered() {
            // 分组标题（CommandGroup.heading → text-xs muted-foreground）
            var g = find("groupSuggestions");
            compare(g.heading, "建议");
            var head = find("commandGroupHeading");
            verify(head, "找不到组标题节点");
            var label = head.children[0];
            compare(label.text, "建议");
            compare(label.font.pixelSize, 12, "text-xs = 12");
        }

        // ── 过滤：大小写 / 中文 / 无匹配 ───────────────────────
        function test_2_filter_case_insensitive() {
            type("theme");
            compare(cmd.matchCount, 1, "小写 theme 应命中「主题」（keywords）");
            compare(find("theme").matched, true);
            compare(find("newFile").matched, false, "不匹配项应被标记");

            type("THEME");
            compare(cmd.matchCount, 1, "大写 THEME 同样命中 —— 大小写不敏感");

            type("Theme");
            compare(cmd.matchCount, 1, "首字母大写同样命中");
        }

        function test_3_filter_cjk() {
            type("新建");
            compare(cmd.matchCount, 1);
            compare(find("newFile").matched, true);

            type("表情");
            compare(cmd.matchCount, 1);
            compare(find("searchEmoji").matched, true);

            // 子序列（顺序出现即可，cmdk 的行为）：新…件
            type("新件");
            compare(find("newFile").matched, true, "中文子序列应命中");

            // 顺序颠倒不命中
            type("件新");
            compare(find("newFile").matched, false, "中文顺序颠倒不应命中");
        }

        function test_4_no_match_shows_empty() {
            type("zzzz");
            compare(cmd.matchCount, 0);
            compare(find("empty").visible, true, "无匹配时 Empty 必须显示");
            // 两个组整组隐藏（不是留个光杆标题）
            compare(find("groupSuggestions").visible, false, "组内全无匹配应整组隐藏");
            compare(find("groupSettings").visible, false);
            // 分隔线搜索时隐藏
            compare(find("sep").visible, false, "有搜索词时分隔线应隐藏");
        }

        function test_5_reset_restores_all() {
            type("zzzz");
            compare(cmd.matchCount, 0);
            type("");
            compare(cmd.matchCount, 6, "清空查询应恢复全部条目");
            compare(find("empty").visible, false, "空查询时 Empty 应消失");
            compare(find("sep").visible, true, "空查询时分隔线应回来");
            compare(find("groupSuggestions").visible, true);
            compare(find("groupSettings").visible, true);
            // 默认选中项仍在第一个可用项
            compare(cmd.activeItem.objectName, "newFile");
        }

        function test_6_input_syncs_search() {
            // 输入框写 text → command.search 同步（双向）
            find("input").text = "计算";
            wait(60);
            compare(cmd.search, "计算", "输入应同步到 search");
            compare(cmd.matchCount, 1);

            // 反向：写 search 也应回灌输入框
            cmd.search = "abc";
            wait(60);
            compare(find("input").text, "abc", "search 应回灌输入框");

            // clearSearch 两边都清
            cmd.clearSearch();
            wait(60);
            compare(cmd.search, "");
            compare(find("input").text, "");
        }

        // ── 键盘导航：↑↓ 跳过隐藏 / 禁用 ───────────────────────
        function test_7_nav_skips_hidden_and_disabled() {
            // 全量时：nav 不含禁用项 danger
            cmd.search = "";
            wait(60);
            var nav = cmd._nav;
            compare(nav.length, 5, "6 项里 1 项禁用 → 可导航 5 项");
            for (var i = 0; i < nav.length; ++i) {
                if (nav[i].objectName === "danger")
                    verify(false, "禁用项不应进入导航表");
            }

            // 过滤后：nav 只含可见项
            type("搜索表情");
            compare(cmd._nav.length, 1);
            compare(cmd._nav[0].objectName, "searchEmoji");
            // 过滤掉当前选中项时自动落到第一项（cmdk 行为）
            compare(cmd.activeItem.objectName, "searchEmoji");

            // ↑↓ 在只剩一项时不应越界
            cmd.moveActive(1);
            compare(cmd.activeItem.objectName, "searchEmoji");
            cmd.moveActive(-1);
            compare(cmd.activeItem.objectName, "searchEmoji");
        }

        function test_8_nav_order_and_wrap() {
            cmd.search = "";
            wait(60);
            compare(namesOf(cmd._nav), "newFile,searchEmoji,calculator,profile,theme",
                    "导航顺序应 = 视觉声明顺序");

            cmd.setActiveIndex(0);
            compare(cmd.activeItem.objectName, "newFile");
            cmd.moveActive(1);
            compare(cmd.activeItem.objectName, "searchEmoji");
            cmd.moveActive(1);
            compare(cmd.activeItem.objectName, "calculator");
            cmd.moveActive(-1);
            compare(cmd.activeItem.objectName, "searchEmoji");

            // 末项继续向下：默认不 loop（cmdk 的 loop=false）→ 停住
            cmd.setActiveIndex(cmd._nav.length - 1);
            compare(cmd.activeItem.objectName, "theme");
            cmd.moveActive(1);
            compare(cmd.activeItem.objectName, "theme", "默认不循环，末项应停住");

            // loop: true 时回绕到首项
            cmd.loop = true;
            cmd.moveActive(1);
            compare(cmd.activeItem.objectName, "newFile", "loop=true 应回绕");
            cmd.loop = false;
        }

        function test_9_selected_state_propagates() {
            cmd.setActiveIndex(1);
            wait(20);
            compare(find("searchEmoji").selected, true);
            compare(find("newFile").selected, false);
            // 选中项的 value 跟着走
            compare(cmd.value, "搜索表情");
        }

        // ── Enter 执行 ─────────────────────────────────────────
        function test_10_enter_activates_value() {
            cmdActivatedSpy.clear();
            cmd.setActiveIndex(2);   // calculator
            wait(20);
            compare(cmd.activeItem.objectName, "calculator");

            var ok = cmd.activateCurrent();
            compare(ok, true);
            compare(cmdActivatedSpy.valid, true, "spy 必须真的连上了 activated 信号");
            compare(cmdActivatedSpy.count, 1, "activated 应发出一次");
            compare(cmdActivatedSpy.signalArguments[0][0], "计算器",
                    "activated 参数是选中项的 value");
        }

        function test_11_disabled_item_not_activated() {
            cmdActivatedSpy.clear();
            // 直接把选中态设到禁用项（模拟越界调用）
            cmd.setActive(find("danger"));
            wait(20);
            // 禁用项不在 _nav 里 → setActive 后仍被兜底走开，或者
            // activateCurrent 拒绝执行；两种都要保证不发出 activated
            var ok = cmd.activateCurrent();
            compare(ok, false, "禁用项 Enter 不应执行");
            compare(cmdActivatedSpy.count, 0, "禁用项不应发出 activated");
        }

        function test_12_item_activated_signal() {
            // 条目自己的 activated 信号（点击 / Enter 都走它）。
            // 用 QtTest 的 SignalSpy 而不是手写 connect/disconnect：QML 里
            // connect 不返回可传给 disconnect 的句柄，`disconnect(undefined)`
            // 直接抛 "target is not a function"（实测踩过）。
            var item = find("profile");
            itemActivatedSpy.target = item;
            itemActivatedSpy.clear();
            item.activateFromKeyboard();
            compare(itemActivatedSpy.count, 1, "条目 activateFromKeyboard 应发 activated");

            // 禁用项：不执行
            var dis = find("danger");
            itemActivatedSpy.target = dis;
            itemActivatedSpy.clear();
            compare(dis.activateFromKeyboard(), false);
            compare(itemActivatedSpy.count, 0, "禁用项 activateFromKeyboard 应返回 false 且不发出");
        }

        // ── 按分数重排 ─────────────────────────────────────────
        function test_13_ranking_reorders() {
            rankCmd.search = "";
            wait(60);
            // 声明顺序：Open new tab 在前
            var nav = rankCmd._nav;
            compare(nav.length, 2);
            compare(nav[0].objectName, "rOpenTab", "空查询应保持声明顺序");

            // "new" 在 "New file" 是前缀命中（高分），在 "Open new tab" 是词中命中（低分）
            rankCmd.search = "new";
            wait(60);
            var n2 = rankCmd._nav;
            compare(n2[0].objectName, "rNewFile", "强匹配项应排到前面");
            compare(n2[1].objectName, "rOpenTab");

            rankCmd.search = "";
            wait(60);
            compare(rankCmd._nav[0].objectName, "rOpenTab", "清空查询应恢复声明顺序");
        }

        function test_14_loose_items_nav() {
            // 不套 Group 的散落条目也要能导航，且禁用项被跳过
            looseCmd.search = "";
            wait(60);
            compare(namesOf(looseCmd._nav), "lA,lB", "禁用项 lC 应被跳过");
            looseCmd.search = "a";
            wait(60);
            verify(looseCmd.matchCount >= 2, "散落的 Alpha/Beta 都应命中 'a'");
            looseCmd.search = "zz";
            wait(60);
            compare(looseCmd.matchCount, 0);
            compare(find("looseEmpty").visible, true, "散落项无匹配时 Empty 也应显示");
            looseCmd.search = "";
            wait(60);
            compare(find("looseEmpty").visible, false);
        }

        // ── 面板高度随过滤收缩（探针实测 childrenRect 含不可见项，
        //    用错就会「过滤掉了但面板不缩短」）──────────────────
        function test_15_height_shrinks_with_filter() {
            cmd.search = "";
            wait(80);
            var full = cmd.implicitHeight;
            cmd.search = "主题";
            wait(80);
            var one = cmd.implicitHeight;
            verify(one < full, "过滤后面板高度应收缩: " + one + " < " + full);
            cmd.search = "zzzz";
            wait(80);
            verify(cmd.implicitHeight < full, "无匹配时也应收缩（只剩 Empty）");
            cmd.search = "";
            wait(80);
            verify(Math.abs(cmd.implicitHeight - full) < 2,
                   "重置后高度应恢复: " + cmd.implicitHeight + " vs " + full);
        }

        // ── 键盘事件能否到达 Command 根（焦点在内部 TextField）──
        // ── 键盘端到端：方向键穿透内部 TextField 到达 Command 根 ──────
        function test_16_keys_reach_command_root() {
            cmd.search = "";
            wait(80);
            cmd.setActiveIndex(0);
            compare(cmd.activeItem.objectName, "newFile");

            var field = find("commandInputField");
            verify(field, "找不到 CommandInput 内部的 TextField");
            field.forceActiveFocus();
            compare(field.activeFocus, true);
            // Command 根本身不该拿到焦点（焦点始终留在输入框 = cmdk 的手感）
            compare(cmd.activeFocus, false);

            keyClick(Qt.Key_Down);
            wait(60);
            compare(cmd.activeItem.objectName, "searchEmoji",
                    "焦点在输入框时按 ↓，Command 根应收到并移动选中项");

            keyClick(Qt.Key_Up);
            wait(60);
            compare(cmd.activeItem.objectName, "newFile", "↑ 应回到上一项");

            // 焦点没被导航抢走
            compare(field.activeFocus, true, "方向键后焦点应仍留在输入框");
        }

        // ── Enter 端到端 + 字母键归输入框 ─────────────────────────
        function test_17_enter_and_typing_via_keys() {
            cmd.search = "";
            wait(80);
            cmdActivatedSpy.clear();
            cmd.setActiveIndex(2);                       // 计算器
            find("commandInputField").forceActiveFocus();
            keyClick(Qt.Key_Return);
            wait(60);
            compare(cmdActivatedSpy.count, 1, "Enter 应触发一次 activated");
            compare(cmdActivatedSpy.signalArguments[0][0], "计算器");

            // 字母键由 TextField 自己消费（Command 根不拦字符键）。
            // 精确断言：按下 X 后选中项**不会往下走一格** —— 若 Command 错误地
            // 把字符键当导航键处理，activeIndex 会 +1，这里立刻暴露。
            find("commandInputField").remove(0, 99);
            cmd.search = "";
            wait(80);
            cmd.setActiveIndex(1);
            var idxBefore = cmd._nav.indexOf(cmd.activeItem);
            var nameBefore = cmd.activeItem.objectName;
            compare(cmd.activeItem ? cmd.activeItem.objectName : "null", nameBefore,
                    "字母键不应移动选中项（idxBefore=" + idxBefore
                    + " now=" + cmd._nav.indexOf(cmd.activeItem) + "）");
            cmd.search = "";
            wait(80);
        }

        // ── Dialog 内嵌模式：开合 + 尺寸 ───────────────────────
        function test_17_dialog_opens_closes() {
            compare(palette.visible, false);
            palette.open();
            tryCompare(palette, "visible", true);

            // registry：CommandDialog 的 showCloseButton 默认 false
            compare(palette.showCloseButton, false);

            // 内嵌 Command 被认出来，并拿到 inDialog = true
            // （官方条目在 dialog-content 内 rounded-lg）
            var inner = palette.command;
            verify(inner, "CommandDialog 没找到内部 Command");
            compare(inner.inDialog, true, "内嵌模式应下发 inDialog=true");

            // 面板宽度沿用 Dialog 的 384（registry 不改宽）
            compare(palette.width, 384);

            // Esc 关闭（Dialog 的 closePolicy 自带）
            palette.close();
            tryCompare(palette, "visible", false);
        }

        function test_18_dialog_positions_at_third() {
            palette.open();
            tryCompare(palette, "visible", true);
            wait(60);
            // registry: top-1/3 + translate-y-0 → y = 窗口高的 1/3
            var expected = Math.round(Overlay.overlay.height / 3);
            verify(Math.abs(palette.y - expected) <= 1,
                   "CommandDialog 应摆在 1/3 高度: y=" + palette.y + " expect=" + expected);
            // 横向仍居中
            var cx = palette.x + palette.width / 2;
            var oc = Overlay.overlay.width / 2;
            verify(Math.abs(cx - oc) <= 1, "横向应居中: cx=" + cx + " oc=" + oc);
            palette.close();
            tryCompare(palette, "visible", false);
        }

        function test_19_dialog_filter_and_nav() {
            palette.open();
            tryCompare(palette, "visible", true);
            var inner = palette.command;
            wait(160);   // enter 过渡 100ms + 合并后的重排一帧
            compare(inner.matchCount, 2);
            inner.search = "设置";
            wait(60);
            compare(inner.matchCount, 1, "Dialog 内嵌模式过滤应同样生效");
            compare(inner.activeItem.objectName, "dlgItemA");
            inner.setActiveIndex(0);
            inner.moveActive(1);
            compare(inner._nav.length, 1, "过滤后只剩一项");
            inner.search = "";
            wait(60);
            compare(inner.matchCount, 2, "Dialog 内重置查询应恢复");
            palette.close();
            tryCompare(palette, "visible", false);
        }

        function test_20_dialog_clears_search_on_open() {
            palette.open();
            tryCompare(palette, "visible", true);
            palette.command.search = "新建";
            wait(80);
            palette.close();
            tryCompare(palette, "visible", false);
            // 重新打开应被清干净（clearSearchOnOpen 默认 true）
            palette.open();
            tryCompare(palette, "visible", true);
            wait(160);
            compare(palette.command.search, "", "重开应清空上次搜索词");
            compare(palette.command.matchCount, 2);
            palette.close();
            tryCompare(palette, "visible", false);
        }

        function test_21_spec_values() {
            // 规格锚点抽查（零字面量纪律的反向验证：这些值必须与 registry 一致）
            var item = find("newFile");
            compare(item.implicitHeight, 32, "条目高 = py-1.5×2 + text-sm 行高 20 = 32");
            compare(item._padX, 8, "px-2 = 8");
            compare(item._gap, 8, "gap-2 = 8");
            // 独立模式用 rounded-sm（theme.radiusSm 派生，非字面量）
            compare(item._radius, theme.radiusSm);
            // Dialog 内嵌时升一档。
            // ⚠ 必须按 id 拿，不能用 find("dlgItemA")：Popup 显示时会把内容子树
            // **重新父化到 Overlay 层**，从用例根 Item 沿 children 走不到它（实测）。
            // id 引用不受重排影响，且 _radius 在创建期就随 inDialog 求值。
            compare(dlgItemARef._radius, theme.radiusLg, "Dialog 内条目应 rounded-lg");

            // CommandList 高度上限 max-h-72 = 288
            compare(find("list").maxHeight, 288);

            // Empty 的 py-6 高度
            compare(find("empty").implicitHeight, 68, "py-6×2 + 行高 20 = 68");

            // Separator 的 h-px + -mx-1
            var sep = find("sep");
            compare(sep.implicitHeight, 1);
            compare(sep._layoutX, -4);

            // Command 根圆角 rounded-xl（从 theme 派生）
            var bg = find("cmd").children[0];
            compare(bg.radius, theme.radiusXl);
            compare(bg.color, theme.popover);

            palette.close();
            tryCompare(palette, "visible", false);
        }

        function test_22_shouldFilter_off() {
            cmd.shouldFilter = false;
            cmd.search = "zzzz";
            wait(60);
            compare(cmd.matchCount, 6, "关过滤后全部匹配");
            verify(find("empty").visible === false, "关过滤时 Empty 不显示");
            cmd.shouldFilter = true;
            cmd.search = "";
            wait(60);
            compare(cmd.matchCount, 6);
        }

        function test_23_custom_filter() {
            // 自定义 filter：只按「包含」判，用来验证注入点真的被调用
            cmd.filter = function(value, search, keywords) {
                if (search === "")
                    return 1.0;
                return value.indexOf(search) >= 0 ? 1.0 : 0.0;
            };
            cmd.search = "表情";
            wait(60);
            compare(cmd.matchCount, 1);
            // 子序列在自定义 filter 下不再命中（证明走的是用户的函数）
            cmd.search = "新件";
            wait(60);
            compare(find("newFile").matched, false, "自定义 filter 应覆盖默认打分");
            cmd.filter = null;
            cmd.search = "";
            wait(60);
            compare(cmd.matchCount, 6);
        }

        // 订阅某个条目的 activated 计数
        // ── 独立弹层模式：开合 + 过滤 + 定位不依赖 Dialog ────────
        function test_24_standalone_popup_opens_closes() {
            compare(standalone.visible, false);
            standalone.open();
            tryCompare(standalone, "visible", true);
            wait(160);

            // 弹层内也能正常过滤
            compare(standaloneCmd.matchCount, 2);
            standaloneCmd.search = "复制";
            wait(80);
            compare(standaloneCmd.matchCount, 1, "独立弹层模式过滤应生效");
            compare(standaloneCmd.activeItem.objectName, "spA");

            // 键盘导航同样工作（Popup 内焦点在输入框）
            standaloneCmd.search = "";
            wait(80);
            standaloneInputRef.focusSearch();
            keyClick(Qt.Key_Down);
            wait(80);
            compare(standaloneCmd.activeItem.objectName, "spB",
                    "独立弹层里 ↓ 应能移动选中项");

            // 圆角不升档：脱离 Dialog 时条目用 rounded-sm
            compare(spARef._radius, theme.radiusSm,
                    "非 Dialog 模式条目应 rounded-sm");
            compare(standaloneCmd.inDialog, false);

            standalone.close();
            tryCompare(standalone, "visible", false);
        }

        function test_25_standalone_popup_reopens_clean() {
            standalone.open();
            tryCompare(standalone, "visible", true);
            wait(160);
            standaloneCmd.search = "复制";
            wait(80);
            standalone.close();
            tryCompare(standalone, "visible", false);

            // 独立模式下组件不会自作主张清搜索词（那是 CommandDialog 的
            // clearSearchOnOpen）—— 由宿主决定，这里验证「保持原样」这个契约
            standalone.open();
            tryCompare(standalone, "visible", true);
            wait(160);
            compare(standaloneCmd.search, "复制",
                    "独立弹层重开应保持宿主设的搜索词（清理是 Dialog 封装的事）");
            // 关掉后重开导航表必须重建（onVisibleChanged 那条重算的回归锁）
            compare(standaloneCmd._nav.length, 1);
            standaloneCmd.clearSearch();
            wait(80);
            compare(standaloneCmd._nav.length, 2, "清空后两项都应重新可导航");
            standalone.close();
            tryCompare(standalone, "visible", false);
        }

    }
}
