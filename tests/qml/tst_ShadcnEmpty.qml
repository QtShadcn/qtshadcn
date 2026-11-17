import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtTest
import QtShadcn

// ShadcnEmpty：居中列容器 + 组合式子项 + 虚线描边（Shape 实现）
//
// 覆盖点：
// 1. 默认居中：内容列在容器内水平居中、垂直居中（justify-center）
// 2. Header / Title / Description / Content 各自渲染并居中
// 3. EmptyMedia 的 default（无底色）与 icon（size-8 = 32 带底色方块）两变体
// 4. 虚线描边：Shape + ShapePath.DashLine + dashPattern，且**像素级验证真的画出了虚线**
//    （偶数段实线 + 空白段），这是 Rectangle 的 border 做不到的
Item {
    id: root
    width: 720
    height: 560

    QtShadcnTheme { id: theme }

    // 默认结构：Header(Media+Title+Description) + Content
    Component {
        id: fullEmptyComp
        ShadcnEmpty {
            width: 400
            height: 300

            ShadcnEmptyHeader {
                ShadcnEmptyMedia {
                    objectName: "media"
                    variant: ShadcnEmptyMedia.Variant.Icon
                    iconName: "inbox"
                }
                ShadcnEmptyTitle {
                    objectName: "title"
                    text: "No data"
                }
                ShadcnEmptyDescription {
                    objectName: "description"
                    text: "No data found"
                }
            }
            ShadcnEmptyContent {
                objectName: "content"

                ShadcnButton {
                    objectName: "action"
                    text: "Add data"
                }
            }
        }
    }

    // 只放一个标题：验证最小结构 + 垂直居中
    Component {
        id: titleOnlyComp
        ShadcnEmpty {
            width: 400
            height: 300

            ShadcnEmptyTitle {
                objectName: "title"
                text: "Nothing here"
            }
        }
    }

    // 描边：默认（无边框）/ bordered / bordered + dashed:false
    Component {
        id: borderComp
        ShadcnEmpty {
            width: 300
            height: 200
        }
    }

    Component {
        id: dashedComp
        ShadcnEmpty {
            width: 300
            height: 200
            bordered: true

            ShadcnEmptyTitle {
                objectName: "title"
                text: "Empty"
            }
        }
    }

    Component {
        id: solidComp
        ShadcnEmpty {
            width: 300
            height: 200
            bordered: true
            dashed: false
        }
    }

    // 任意固定宽子项：验证 items-center（CSS）对「非 fillWidth 的普通子项」也生效
    Component {
        id: arbitraryChildrenComp
        ShadcnEmpty {
            width: 400
            height: 300

            Rectangle {
                objectName: "blob"
                Layout.preferredWidth: 60
                Layout.preferredHeight: 20
                color: "#ff0000"
            }
            ShadcnEmptyContent {
                objectName: "content"

                Rectangle {
                    objectName: "tinyAction"
                    Layout.preferredWidth: 70
                    Layout.preferredHeight: 20
                    color: "#00ff00"
                }
            }
        }
    }

    // Media 两变体
    Component {
        id: mediaDefaultComp
        ShadcnEmptyMedia {
            objectName: "media"
            iconName: "inbox"
        }
    }

    Component {
        id: mediaIconComp
        ShadcnEmptyMedia {
            objectName: "media"
            variant: ShadcnEmptyMedia.Variant.Icon
            iconName: "inbox"
        }
    }

    // 一行里数「实线段 / 空白段」：返回涂色像素数与每段实线长度
    function scanHorizontalRun(img, y) {
        let painted = 0
        const runs = []
        let run = 0

        for (let x = 0; x < img.width; ++x) {
            // 边框色来自 theme.border（浅色 #e4e4e7 / 深色约 #27272a），
            // 与透明底(255,255,255)的差异用「非纯白」判定，避开具体色值
            const isPainted = !(img.red(x, y) > 250 && img.green(x, y) > 250 && img.blue(x, y) > 250)
            if (isPainted) {
                painted++
                run++
            } else if (run > 0) {
                runs.push(run)
                run = 0
            }
        }
        if (run > 0)
            runs.push(run)

        return { painted: painted, runs: runs }
    }

    TestCase {
        name: "ShadcnEmpty"
        when: windowShown

        // ── 1. 默认居中布局 ──

        // 内容列整体在容器内水平居中：Header 左右留白相等
        function test_content_column_horizontally_centered() {
            const empty = createTemporaryObject(fullEmptyComp, root)
            verify(!!empty, "Component exists")

            const header = findChild(empty, "media").parent
            verify(!!header, "Header exists")

            tryVerify(function() { return header.width > 0 })
            // x 是相对父项（内容列）的，必须映射回 Empty 坐标系再比
            const headerCenter = header.mapToItem(empty, header.width / 2, 0).x
            compare(Math.round(headerCenter), Math.round(empty.width / 2), "Header 水平居中")
        }

        // justify-center：内容列在容器内垂直居中（不是贴顶 padding）
        function test_content_column_vertically_centered() {
            const empty = createTemporaryObject(titleOnlyComp, root)
            verify(!!empty, "Component exists")

            const title = findChild(empty, "title")
            verify(!!title, "Title exists")

            tryVerify(function() { return title.height > 0 })
            // 单个标题：上下留白应相等（padding 24 + 额外居中量）。
            // title.y 相对内容列，先映射到 Empty 坐标
            const topEdge = title.mapToItem(empty, 0, 0).y
            const topSpace = topEdge
            const bottomSpace = empty.height - (topEdge + title.height)
            verify(Math.abs(topSpace - bottomSpace) <= 2,
                   "上下留白应相等，实际 top=" + topSpace + " bottom=" + bottomSpace)
            verify(topSpace >= empty.padding, "不越过 p-6 内边距")
        }

        // 内容高于容器时不越界（居中量取 padding 兜底）
        function test_content_taller_than_container_keeps_padding() {
            const empty = createTemporaryObject(titleOnlyComp, root, { height: 40 })
            verify(!!empty, "Component exists")

            const title = findChild(empty, "title")
            verify(!!title, "Title exists")
            tryVerify(function() { return title.height > 0 })
            const topEdge = title.mapToItem(empty, 0, 0).y
            verify(topEdge >= empty.padding - 0.5, "内容不越出上内边距")
        }

        // ── 2. 各子组件渲染 / 居中 ──

        function test_title_renders_and_is_centered() {
            const empty = createTemporaryObject(titleOnlyComp, root)
            verify(!!empty, "Component exists")

            const title = findChild(empty, "title")
            verify(!!title, "Title exists")
            compare(title.text, "Nothing here")
            compare(title.color.toString(), theme.foreground.toString(), "标题用 foreground token")
            compare(title.font.pixelSize, 14, "text-sm = 14")
            compare(title.font.weight, Font.Medium, "font-medium = 500")
            compare(title.horizontalAlignment, Text.AlignHCenter)

            tryVerify(function() { return title.width > 0 })
            const titleCenter = title.mapToItem(empty, title.width / 2, 0).x
            compare(Math.round(titleCenter), Math.round(empty.width / 2), "标题文本块水平居中")
        }

        function test_description_renders_with_muted_foreground() {
            const empty = createTemporaryObject(fullEmptyComp, root)
            verify(!!empty, "Component exists")

            const desc = findChild(empty, "description")
            verify(!!desc, "Description exists")
            compare(desc.text, "No data found")
            compare(desc.color.toString(), theme.mutedForeground.toString(),
                    "描述用 mutedForeground token")
            compare(desc.font.pixelSize, 14, "text-sm = 14")
            // text-sm/relaxed = 行高 1.625
            compare(desc.lineHeight, 1.625)
            compare(desc.lineHeightMode, Text.ProportionalHeight)
        }

        function test_content_renders_button_centered() {
            const empty = createTemporaryObject(fullEmptyComp, root)
            verify(!!empty, "Component exists")

            const content = findChild(empty, "content")
            verify(!!content, "Content exists")
            const action = findChild(empty, "action")
            verify(!!action, "Action button exists")

            tryVerify(function() { return action.width > 0 && content.width > 0 })
            // 按钮宽度可能是奇数，居中会差 0.5px → 留 1px 容差
            const actionCenter = action.mapToItem(content, action.width / 2, 0).x
            verify(Math.abs(actionCenter - content.width / 2) <= 1,
                   "按钮在 Content 内水平居中，实际偏差 " + (actionCenter - content.width / 2))
            compare(Math.round(content.mapToItem(empty, content.width / 2, 0).x),
                    Math.round(empty.width / 2), "Content 在 Empty 内水平居中")
        }

        // Header 限制到 max-w-sm = 384
        function test_header_max_width_is_384() {
            const empty = createTemporaryObject(fullEmptyComp, root, { width: 600 })
            verify(!!empty, "Component exists")

            const header = findChild(empty, "media").parent
            verify(!!header, "Header exists")
            compare(header.Layout.maximumWidth, 384, "max-w-sm = 384")
            tryVerify(function() { return Math.abs(header.width - 384) <= 1 })
        }

        // CSS items-center 覆盖「用户塞进来的固定宽子项」：ShadcnEmpty 的直接子项
        // 与 ShadcnEmptyContent 内的子项都要水平居中（不依赖子项自己 fillWidth）
        function test_arbitrary_fixed_width_children_are_centered() {
            const empty = createTemporaryObject(arbitraryChildrenComp, root)
            verify(!!empty, "Component exists")

            const blob = findChild(empty, "blob")
            verify(!!blob, "Blob exists")
            tryVerify(function() { return blob.width > 0 })
            const blobCenter = blob.mapToItem(empty, blob.width / 2, 0).x
            verify(Math.abs(blobCenter - empty.width / 2) <= 1,
                   "固定宽子项在 Empty 内居中，实际偏差 " + (blobCenter - empty.width / 2))

            const content = findChild(empty, "content")
            const tiny = findChild(empty, "tinyAction")
            verify(!!content && !!tiny, "Content / tinyAction exist")
            tryVerify(function() { return tiny.width > 0 })
            const tinyCenter = tiny.mapToItem(content, tiny.width / 2, 0).x
            verify(Math.abs(tinyCenter - content.width / 2) <= 1,
                   "固定宽子项在 Content 内居中，实际偏差 " + (tinyCenter - content.width / 2))
        }

        // ── 3. EmptyMedia 两变体 ──

        // default：bg-transparent，无带底色方块
        function test_media_default_variant_has_no_background() {
            const media = createTemporaryObject(mediaDefaultComp, root)
            verify(!!media, "Component exists")

            compare(media.variant, ShadcnEmptyMedia.Variant.Default)
            const box = findChild(media, "mediaBox")
            verify(!!box, "Box exists")
            compare(box.visible, false, "default 变体没有底色方块")

            // 默认变体尺寸跟随内容（lucide 设计尺寸 24），不是 size-8
            tryVerify(function() { return media.width > 0 })
            compare(media.width, 24, "默认变体图标 24px")
        }

        // icon：size-8 = 32 的带底色方块 + rounded-lg + bg-muted
        function test_media_icon_variant_is_32px_tinted_box() {
            const media = createTemporaryObject(mediaIconComp, root)
            verify(!!media, "Component exists")

            compare(media.variant, ShadcnEmptyMedia.Variant.Icon)
            compare(media.width, 32, "size-8 = 32")
            compare(media.height, 32, "size-8 = 32")

            const box = findChild(media, "mediaBox")
            verify(!!box, "Box exists")
            compare(box.visible, true, "icon 变体有底色方块")
            compare(box.color.toString(), theme.muted.toString(), "bg-muted")
            compare(box.radius, theme.radiusLg, "rounded-lg = theme.radiusLg")
        }

        // icon 变体里的 svg 是 size-4 = 16
        function test_media_icon_variant_icon_size_is_16() {
            const media = createTemporaryObject(mediaIconComp, root)
            verify(!!media, "Component exists")

            const icon = findChild(media, "mediaIcon")
            verify(!!icon, "Icon exists")
            tryVerify(function() { return icon.width === 16 })
            compare(icon.name, "inbox")
        }

        // ── 4. 虚线边框 ──

        // 默认（对齐官方：cn-empty 只有 border-dashed 没有宽度）不画描边
        function test_border_absent_by_default() {
            const empty = createTemporaryObject(borderComp, root)
            verify(!!empty, "Component exists")

            compare(empty.bordered, false, "官方默认无可见描边")
            const shape = findChild(empty, "borderShape")
            verify(!!shape, "Border shape exists")
            compare(shape.visible, false)
        }

        // 开描边后 Shape 存在、尺寸贴合容器、走 DashLine + dashPattern
        function test_dashed_border_shape_exists_and_sized() {
            const empty = createTemporaryObject(dashedComp, root)
            verify(!!empty, "Component exists")

            const shape = findChild(empty, "borderShape")
            verify(!!shape, "Border shape exists")
            compare(shape.visible, true)
            compare(Math.round(shape.width), Math.round(empty.width), "描边宽度贴合容器")
            compare(Math.round(shape.height), Math.round(empty.height), "描边高度贴合容器")

            const path = findChild(empty, "borderPath")
            verify(!!path, "ShapePath exists")
            compare(path.strokeStyle, ShapePath.DashLine, "虚线样式")
            compare(path.dashPattern.length, 2, "两段节拍 [实线, 空白]")
            compare(path.strokeColor.toString(), theme.border.toString(), "描边走 border token")
            compare(path.strokeWidth, 1)
        }

        // 像素级：虚线必须真的是断续的（存在多段实线 + 中间的空白）
        // 这是「Rectangle 的实线 border 冒充虚线」无法通过的断言
        function test_dashed_border_pixels_are_really_dashed() {
            const empty = createTemporaryObject(dashedComp, root)
            verify(!!empty, "Component exists")

            waitForRendering(empty)
            const img = grabImage(empty)
            verify(!!img, "Grab image exists")

            // 上边：y = 0（描边内缩半个线宽，1px 线落在第 0 行）
            const top = root.scanHorizontalRun(img, 0)
            verify(top.painted > 0, "上边有描边像素")
            verify(top.runs.length >= 4,
                   "应有多个断续段，实际 " + top.runs.length + " 段")

            // 逐段交替：实线段长度接近 4，段数远多于 1
            const maxRun = Math.max.apply(null, top.runs)
            verify(maxRun <= 6, "单段实线不超过 6px，实际 " + maxRun)

            // 实线总长应显著小于整条边（否则就是实线）
            verify(top.painted < empty.width * 0.75,
                   "实线覆盖率应明显小于 100%，实际 " + top.painted + "/" + empty.width)

            // 同样验证左边（竖边）
            let leftPainted = 0
            for (let y = 0; y < img.height; ++y) {
                if (!(img.red(0, y) > 250 && img.green(0, y) > 250 && img.blue(0, y) > 250))
                    leftPainted++
            }
            verify(leftPainted > 0, "左边有描边像素")
            verify(leftPainted < empty.height * 0.75,
                   "左边也应是虚线，实际 " + leftPainted + "/" + empty.height)
        }

        // 对照组：dashed:false 时是连续实线（证明上面的断言确实在区分两者）
        function test_solid_border_pixels_are_continuous() {
            const empty = createTemporaryObject(solidComp, root)
            verify(!!empty, "Component exists")

            waitForRendering(empty)
            const img = grabImage(empty)
            verify(!!img, "Grab image exists")

            const top = root.scanHorizontalRun(img, 0)
            compare(top.runs.length, 1, "实线只有一整段")
            verify(top.painted > empty.width * 0.9,
                   "实线覆盖率接近满宽，实际 " + top.painted + "/" + empty.width)
        }

        // 描边是圆角矩形（Path* 元素 = 4 边 + 4 圆角）
        function test_border_path_has_four_arcs() {
            const empty = createTemporaryObject(dashedComp, root)
            verify(!!empty, "Component exists")

            const path = findChild(empty, "borderPath")
            verify(!!path, "ShapePath exists")

            let arcCount = 0
            let lineCount = 0
            for (let i = 0; i < path.pathElements.length; ++i) {
                const element = path.pathElements[i]
                if (element instanceof PathArc)
                    arcCount++
                else if (element instanceof PathLine)
                    lineCount++
            }
            compare(arcCount, 4, "四个圆角")
            compare(lineCount, 4, "四条边")
        }

        // 圆角走 theme.radiusXl（rounded-xl），不写死像素
        function test_radius_follows_theme() {
            const empty = createTemporaryObject(borderComp, root)
            verify(!!empty, "Component exists")
            compare(empty.radius, theme.radiusXl, "rounded-xl = radius × 1.4")
        }

        // 间距走 token：p-6 = 24、gap-4 = 16
        function test_padding_and_spacing_follow_tokens() {
            const empty = createTemporaryObject(borderComp, root)
            verify(!!empty, "Component exists")
            compare(empty.padding, 24, "p-6 = 24")
            compare(empty.spacing, 16, "gap-4 = 16")

            const header = createTemporaryObject(fullEmptyComp, root)
            verify(!!header, "Component exists")
            const headerItem = findChild(header, "media").parent
            compare(headerItem.spacing, 8, "cn-empty-header gap-2 = 8")
        }
    }
}
