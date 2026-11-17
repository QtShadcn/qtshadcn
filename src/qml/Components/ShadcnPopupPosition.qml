// src/qml/Components/ShadcnPopupPosition.qml
import QtQuick

// shadcn/ui 风格弹层的边界定位器（issue #16）
//
// QQC.Popup 只有「相对父项摆一个坐标」，没有 Radix 的 side / align / sideOffset /
// collisionPadding 那一套 —— 靠近窗口底部的弹层会整块被顶出可视区。
// 这个对象把定位算成纯数据（不创建 Item、不碰动画），供 DropdownMenu / Select /
// Tooltip 共用：
//
//   ShadcnPopupPosition {
//       id: placement
//       anchor: trig
//       container: Overlay.overlay          // 可选；留空自动用 Windows.contentItem
//       popupWidth: popup.implicitWidth
//       popupHeight: popup.implicitHeight
//       side: "bottom"                      // 首选方向
//       sideOffset: 4
//   }
//   // 坐标系必须一致：弹层父项 = placement.frame，x/y 才能直接赋值
//   popup.parent: placement.frame
//   popup.x: placement.x
//   popup.y: placement.y
//
// 三个容易踩错的地方，这里一次性收掉：
//
// 1) 坐标系。`popup.x/y` 是**弹层父项**坐标系里的值（默认父项是声明它的那个
//    Item，可能在带 padding 的 Card 里）。所以必须 mapToItem 到弹层所在坐标系，
//    再把弹层的 parent 设成同一个 Item。直接读 `anchor.y` 只拿到父项坐标，跨层
//    容器会整体偏移。
//
// 2) Overlay.overlay 在 QtObject 里读不到（attached property 需要有 Item 作用域，
//    在 QtObject 中恒为 null —— 实测）。所以 container 是可选的：留空时退回
//    `anchor.Window.contentItem`，它与 overlay 同原点和同尺寸（实测一致），
//    弹层父项同样绑 frame 即可。
//
// 3) 绑定依赖。`mapToItem()` 是 C++ 调用，读 x/y/width/height 不会建立 QML
//    绑定依赖（实测：改 anchor.y 后坐标不重算）。`_depTick` 手工把祖先链和
//    frame 的几何读一遍，把这条依赖补回来（含窗口尺寸变化）。
//
// 规则对齐 Radix：
//   1. 首选方向放得下就放
//   2. 放不下换对侧（也可用 fallbackSides 指定更长的候选序列）
//   3. 两侧都放不下 → 取空间大的一侧，把高度钳到可用高度内（clamped = true，
//      调用方据此给内容区加滚动）
//   4. 横向默认左对齐触发项；右边缘溢出则钳回边界内（align: "end"/"center" 同理）
QtObject {
    id: root

    // ── 输入 ──────────────────────────────────────────────
    // 触发项：定位与翻转都以它的 rect 为基准
    property Item anchor: null
    // 坐标系 / 碰撞边界。组件里传 Overlay.overlay；留空自动用窗口 contentItem。
    // 传一个更小的 Item 可以只在某个容器内做碰撞（如 sheet 内嵌弹层）
    property Item container: null
    // 弹层期望尺寸（宽 <= 0 时退回触发项宽度；高 <= 0 时按 0 处理）
    property real popupWidth: 0
    property real popupHeight: 0
    // 首选方向："bottom" | "top"
    property string side: "bottom"
    // 额外候选方向（按序尝试）；为空时自动补对侧
    property var fallbackSides: []
    // 横向对齐："start"（默认，左对齐触发项）| "end" | "center"
    property string align: "start"
    // 与触发项的间距（shadcn sideOffset）
    property real sideOffset: 4
    // 与边界的最小留白（shadcn collisionPadding）
    property real collisionPadding: 8

    // ── 输出 ──────────────────────────────────────────────
    // 弹层应使用的父项：与坐标同一坐标系（弹层渲染在 overlay 层时绑它）
    readonly property Item frame: {
        if (root.container)
            return root.container;
        var a = root.anchor;
        if (!a)
            return null;
        var w = a.Window;
        return w ? w.contentItem : null;
    }
    // 最终坐标（父项 = frame 时可直接赋给 popup.x / popup.y）
    readonly property real x: _geometry.x
    readonly property real y: _geometry.y
    // 钳制后的尺寸：高 = min(popupHeight, 可用高度)；宽 = min(popupWidth, 边界宽 - 2*内边距)
    readonly property real width: _geometry.width
    readonly property real height: _geometry.height
    // 实际采用的方向（"bottom" | "top"）：翻转后动画方向要跟着反
    readonly property string resolvedSide: _geometry.side
    // 采用方向上的可用空间（钳制前）
    readonly property real availableHeight: _geometry.availableHeight
    // 是否因两侧都放不下而钳制了高度（调用方据此启用内容滚动）
    readonly property bool clamped: _geometry.clamped
    // 触发项在 frame 坐标系里的 rect（调试 / 测试断言用）
    readonly property rect anchorRect: Qt.rect(_geometry.ax, _geometry.ay,
                                               _geometry.aw, _geometry.ah)

    // 方向落定时发出，便于调用方做一次性副作用（如切换入场动画方向）。
    // 位置本身请直接绑定 x / y —— 属性自带 notify，不需要经信号中转。
    signal positioned(real px, real py, string pside)

    onResolvedSideChanged: root.positioned(root.x, root.y, root.resolvedSide)

    // ── 内部 ──────────────────────────────────────────────
    // 见文件头第 3 条：手工读一遍几何，让坐标随布局 / 窗口尺寸变化重算。
    readonly property real _depTick: {
        var sum = 0;
        var p = root.anchor;
        while (p) {
            sum += p.x + p.y + p.width + p.height;
            p = p.parent;
        }
        var f = root.frame;
        if (f)
            sum += f.width + f.height;
        return sum;
    }

    readonly property var _geometry: root._compute()

    function _compute() {
        var result = {
            "ax": 0, "ay": 0, "aw": 0, "ah": 0,
            "x": 0, "y": 0, "width": 0, "height": 0,
            "side": root.side === "top" ? "top" : "bottom",
            "availableHeight": 0,
            "clamped": false
        }

        var a = root.anchor;
        if (!a)
            return result;

        // 真正读取祖先几何以建立绑定依赖（值本身只有「是否 < 0」这一用途，
        // 恒为 false；写成可达分支是为了不被优化掉）
        if (root._depTick < 0)
            return result;

        var f = root.frame;
        var topLeft = a.mapToItem(f, 0, 0);
        result.ax = topLeft.x;
        result.ay = topLeft.y;
        result.aw = a.width;
        result.ah = a.height;

        var pad = root.collisionPadding > 0 ? root.collisionPadding : 0;
        var off = root.sideOffset;

        // 有 frame 才有边界；没有（尚未进窗口）就只排序方向、不钳制
        var hasBounds = !!f && f.width > 0 && f.height > 0;
        var bw = hasBounds ? f.width : 0;
        var bh = hasBounds ? f.height : 0;

        var pw = root.popupWidth > 0 ? root.popupWidth : result.aw;
        if (hasBounds)
            pw = Math.min(pw, Math.max(0, bw - pad * 2));
        var ph = root.popupHeight > 0 ? root.popupHeight : 0;

        // 各方向可用空间
        var belowY = result.ay + result.ah + off;
        var topEdge = result.ay - off;
        var belowSpace = hasBounds ? (bh - pad - belowY) : ph;
        var aboveSpace = hasBounds ? (topEdge - pad) : ph;

        function spaceOf(sideName) {
            return sideName === "top" ? aboveSpace : belowSpace;
        }

        // 候选序列：首选 → fallbackSides → 对侧
        var candidates = [result.side];
        var extra = root.fallbackSides;
        if (extra && extra.length) {
            for (var i = 0; i < extra.length; ++i) {
                if (candidates.indexOf(extra[i]) < 0)
                    candidates.push(extra[i]);
            }
        }
        var opposite = result.side === "top" ? "bottom" : "top";
        if (candidates.indexOf(opposite) < 0)
            candidates.push(opposite);

        // 1/2. 首选放得下就放，放不下按序列试对侧
        var chosen = candidates[0];
        var space = spaceOf(chosen);
        for (i = 0; i < candidates.length; ++i) {
            if (spaceOf(candidates[i]) >= ph) {
                chosen = candidates[i];
                space = spaceOf(chosen);
                break;
            }
        }

        // 3. 都放不下 → 空间大的一侧 + 高度钳制
        var clamped = false;
        if (space < ph) {
            for (i = 0; i < candidates.length; ++i) {
                var s = spaceOf(candidates[i]);
                if (s > space) {
                    chosen = candidates[i];
                    space = s;
                }
            }
            clamped = true;
        }

        var available = Math.max(0, space);
        var height = Math.min(ph, available);

        // 横向：默认左对齐触发项，右边缘溢出则钳回边界内
        var px;
        if (root.align === "end")
            px = result.ax + result.aw - pw;
        else if (root.align === "center")
            px = result.ax + (result.aw - pw) / 2;
        else
            px = result.ax;

        var py = (chosen === "top") ? (topEdge - height) : belowY;

        if (hasBounds) {
            var minX = pad;
            var maxX = bw - pad - pw;
            px = (maxX <= minX) ? minX : Math.max(minX, Math.min(px, maxX));

            var minY = pad;
            var maxY = bh - pad - height;
            py = (maxY <= minY) ? minY : Math.max(minY, Math.min(py, maxY));
        }

        result.x = Math.round(px);
        result.y = Math.round(py);
        result.width = pw;
        result.height = height;
        result.side = chosen;
        result.availableHeight = available;
        result.clamped = clamped;
        return result;
    }
}
