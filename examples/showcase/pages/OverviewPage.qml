import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

Item {
    id: root

    signal navigateTo(string page)

    // ============================================================
    // Theme
    // ============================================================

    QtShadcnTheme {
        id: theme
    }

    // ============================================================
    // Component Group
    // ============================================================

    component ComponentGroup: Column {
        id: group

        property string title: ""
        property var items: []

        width: parent.width

        spacing: 10

        // --------------------------------------------------------
        // Group title
        // --------------------------------------------------------

        Text {
            text: group.title

            color: theme.foreground
            font.pixelSize: 14
            font.bold: true
        }

        // --------------------------------------------------------
        // Component cards
        // --------------------------------------------------------

        GridLayout {
            width: parent.width

            columns: width >= 1100 ? 4 : width >= 800 ? 3 : width >= 550 ? 2 : 1

            columnSpacing: 8
            rowSpacing: 8

            Repeater {
                model: group.items

                delegate: Rectangle {
                    id: card

                    Layout.fillWidth: true
                    Layout.preferredHeight: 68

                    radius: 8

                    color: modelData.available ? (mouseArea.containsMouse ? theme.accent : theme.background) : theme.background

                    border.width: 1
                    border.color: theme.border

                    opacity: modelData.available ? 1.0 : 0.55

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    // ------------------------------------------------
                    // Content
                    // ------------------------------------------------

                    Column {
                        anchors.left: parent.left
                        anchors.right: arrow.left
                        anchors.verticalCenter: parent.verticalCenter

                        anchors.leftMargin: 12
                        anchors.rightMargin: 8

                        spacing: 3

                        Text {
                            width: parent.width

                            text: modelData.name

                            color: theme.foreground
                            font.pixelSize: 13
                            font.bold: true

                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width

                            text: modelData.description

                            color: theme.mutedForeground
                            font.pixelSize: 11

                            elide: Text.ElideRight
                        }
                    }

                    // ------------------------------------------------
                    // Arrow
                    // ------------------------------------------------

                    Text {
                        id: arrow

                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter

                        text: modelData.available ? "›" : ""

                        color: theme.mutedForeground
                        font.pixelSize: 18
                    }

                    // ------------------------------------------------
                    // Click
                    // ------------------------------------------------

                    MouseArea {
                        id: mouseArea

                        anchors.fill: parent

                        enabled: modelData.available

                        hoverEnabled: enabled

                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: {
                            root.navigateTo(modelData.page);
                        }
                    }
                }
            }
        }
    }

    // ============================================================
    // Main Content
    // ============================================================

    // 标题区（固定，不随内容滚动）
    Column {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40

        spacing: theme.spacingLg

        // ========================================================
        // Header
        // ========================================================

        Text {
            text: qsTr("QtShadcn — Showcase")

            color: theme.foreground

            font.pixelSize: 22
            font.bold: true
        }

        // --------------------------------------------------------
        // Description
        // --------------------------------------------------------

        Text {
            width: parent.width

            wrapMode: Text.WordWrap

            text: qsTr("Qt 6 / QML 可组合 UI 组件库，对齐 shadcn/ui 设计哲学：Design Token → Component → Composition → Theme。左侧菜单按组件浏览，右上角可切换主题色与明暗模式（全局生效）。")

            color: theme.mutedForeground

            font.pixelSize: 13
        }
    }

    // ========================================================
    // Component List（内容区：放不下才滚）
    // ========================================================

    ScrollView {
        id: scrollView

        anchors.top: header.bottom
        anchors.topMargin: 20
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 24
        anchors.rightMargin: 24

        clip: true

        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Column {
            id: content

            width: scrollView.availableWidth

            spacing: 24

            // ==================================================
            // M2
            // General
            // ==================================================

            ComponentGroup {
                title: qsTr("M2 · General")

                items: [
                    {
                        name: "Button",
                        description: "按钮",
                        page: "ButtonPage.qml",
                        available: true
                    },
                    {
                        name: "Button Group",
                        description: "按钮组",
                        page: "ButtonGroupPage.qml",
                        available: true
                    },
                    {
                        name: "Toggle",
                        description: "切换按钮",
                        page: "TogglePage.qml",
                        available: true
                    },
                    {
                        name: "Toggle Group",
                        description: "切换按钮组",
                        page: "TogglePage.qml"   // ToggleGroup 展示在 TogglePage 内（无独立页）
                        ,
                        available: true
                    },
                    {
                        name: "Spinner",
                        description: "加载指示器",
                        page: "SpinnerPage.qml",
                        available: true
                    }
                ]
            }

            // ==================================================
            // M3 #2
            // Form
            // ==================================================

            ComponentGroup {
                title: qsTr("M3 · Form")

                items: [
                    {
                        name: "Input",
                        description: "输入框",
                        page: "InputPage.qml",
                        available: true
                    },
                    {
                        name: "Input Group",
                        description: "输入框前后缀组合",
                        page: "InputGroupPage.qml",
                        available: true
                    },
                    {
                        name: "Textarea",
                        description: "多行文本输入",
                        page: "TextareaPage.qml",
                        available: true
                    },
                    {
                        name: "Checkbox",
                        description: "复选框",
                        page: "CheckboxPage.qml",
                        available: true
                    },
                    {
                        name: "Radio Group",
                        description: "单选按钮组",
                        page: "RadioPage.qml",
                        available: true
                    },
                    {
                        name: "Switch",
                        description: "开关",
                        page: "SwitchPage.qml",
                        available: true
                    },
                    {
                        name: "Slider",
                        description: "滑块",
                        page: "SliderPage.qml",
                        available: true
                    },
                    {
                        name: "Progress",
                        description: "进度条",
                        page: "ProgressPage.qml",
                        available: true
                    },
                    {
                        name: "Select",
                        description: "选择器",
                        page: "SelectPage.qml",
                        available: true
                    },
                    {
                        name: "Form",
                        description: "组合表单示例",
                        page: "FormPage.qml",
                        available: true
                    }
                ]
            }

            // ==================================================
            // M3 #3
            // Layout & Feedback
            // ==================================================

            ComponentGroup {
                title: qsTr("M3 · Layout & Feedback")

                items: [
                    {
                        name: "Card",
                        description: "Header / Content / Footer",
                        page: "CardPage.qml",
                        available: true
                    },
                    {
                        name: "Alert",
                        description: "四色提示框",
                        page: "AlertPage.qml",
                        available: false
                    },
                    {
                        name: "Dialog",
                        description: "对话框",
                        page: "DialogPage.qml",
                        available: true
                    },
                    {
                        name: "Drawer",
                        description: "抽屉",
                        page: "DrawerPage.qml",
                        available: false
                    },
                    {
                        name: "Sheet",
                        description: "侧边面板",
                        page: "SheetPage.qml",
                        available: false
                    },
                    {
                        name: "Toast",
                        description: "消息提示",
                        page: "ToastPage.qml",
                        available: false
                    },
                    {
                        name: "Skeleton",
                        description: "骨架屏",
                        page: "SkeletonPage.qml",
                        available: false
                    },
                    {
                        name: "Badge",
                        description: "状态标签",
                        page: "BadgePage.qml",
                        available: true
                    },
                    {
                        name: "Label",
                        description: "文本标签",
                        page: "LabelPage.qml",
                        available: false
                    },
                    {
                        name: "Separator",
                        description: "分隔线",
                        page: "SeparatorPage.qml",
                        available: false
                    },
                    {
                        name: "Typography",
                        description: "排版系统",
                        page: "TypographyPage.qml",
                        available: false
                    }
                ]
            }

            // ==================================================
            // M3 #4
            // Navigation & Menu
            // ==================================================

            ComponentGroup {
                title: qsTr("M3 · Navigation & Menu")

                items: [
                    {
                        name: "Tabs",
                        description: "标签页",
                        page: "TabsPage.qml",
                        available: true
                    },
                    {
                        name: "Breadcrumb",
                        description: "面包屑导航",
                        page: "BreadcrumbPage.qml",
                        available: false
                    },
                    {
                        name: "Pagination",
                        description: "分页",
                        page: "PaginationPage.qml",
                        available: false
                    },
                    {
                        name: "Context Menu",
                        description: "上下文菜单",
                        page: "ContextMenuPage.qml",
                        available: false
                    },
                    {
                        name: "Dropdown Menu",
                        description: "下拉菜单",
                        page: "DropdownMenuPage.qml",
                        available: false
                    },
                    {
                        name: "Menubar",
                        description: "菜单栏",
                        page: "MenubarPage.qml",
                        available: false
                    },
                    {
                        name: "Sidebar",
                        description: "可折叠侧边栏",
                        page: "SidebarPage.qml",
                        available: false
                    },
                    {
                        name: "Scroll Area",
                        description: "滚动区域",
                        page: "ScrollAreaPage.qml",
                        available: false
                    },
                    {
                        name: "Resizable",
                        description: "可调整大小 / SplitView",
                        page: "ResizablePage.qml",
                        available: false
                    }
                ]
            }

            // ==================================================
            // M4 #5
            // Composition
            // ==================================================

            ComponentGroup {
                title: qsTr("M4 · Composition")

                items: [
                    {
                        name: "Accordion",
                        description: "手风琴",
                        page: "AccordionPage.qml",
                        available: false
                    },
                    {
                        name: "Collapsible",
                        description: "可折叠内容",
                        page: "CollapsiblePage.qml",
                        available: false
                    },
                    {
                        name: "Popover",
                        description: "弹出层",
                        page: "PopoverPage.qml",
                        available: false
                    },
                    {
                        name: "Hover Card",
                        description: "悬浮卡片",
                        page: "HoverCardPage.qml",
                        available: false
                    },
                    {
                        name: "Command",
                        description: "⌘K 命令面板",
                        page: "CommandPage.qml",
                        available: false
                    },
                    {
                        name: "Input OTP",
                        description: "验证码输入",
                        page: "InputOTPPage.qml",
                        available: false
                    },
                    {
                        name: "Field",
                        description: "表单字段",
                        page: "FieldPage.qml",
                        available: false
                    },
                    {
                        name: "Empty",
                        description: "空状态",
                        page: "EmptyPage.qml",
                        available: false
                    }
                ]
            }

            // ==================================================
            // M4 #6
            // Icon + Animations
            // ==================================================

            ComponentGroup {
                title: qsTr("M4 · Icon + Animations")

                items: [
                    {
                        name: "Icon",
                        description: "IconRegistry / SVG",
                        page: "IconPage.qml",
                        available: true
                    },
                    {
                        name: "Animations",
                        description: "动画封装",
                        page: "AnimationsPage.qml",
                        available: false
                    }
                ]
            }

            // ==================================================
            // M4 #7
            // Content
            // ==================================================

            ComponentGroup {
                title: qsTr("M4 · Content")

                items: [
                    {
                        name: "Avatar",
                        description: "头像（图片/图标/首字母 + 状态点）",
                        page: "AvatarPage.qml",
                        available: true
                    },
                    {
                        name: "Status Dot",
                        description: "语义色状态圆点",
                        page: "StatusDotPage.qml",
                        available: true
                    },
                    {
                        name: "Carousel",
                        description: "轮播",
                        page: "CarouselPage.qml",
                        available: false
                    },
                    {
                        name: "Kbd",
                        description: "键盘快捷键",
                        page: "KbdPage.qml",
                        available: false
                    },
                    {
                        name: "Tooltip",
                        description: "提示信息",
                        page: "TooltipPage.qml",
                        available: false
                    },
                    {
                        name: "Message",
                        description: "消息",
                        page: "MessagePage.qml",
                        available: false
                    },
                    {
                        name: "Bubble",
                        description: "气泡消息",
                        page: "BubblePage.qml",
                        available: false
                    },
                    {
                        name: "Attachment",
                        description: "附件",
                        page: "AttachmentPage.qml",
                        available: false
                    },
                    {
                        name: "Item",
                        description: "通用列表项",
                        page: "ItemPage.qml",
                        available: false
                    }
                ]
            }

            // ==================================================
            // M5 #8
            // C++ Capability / Data
            // ==================================================

            ComponentGroup {
                title: qsTr("M5 · C++ Capability & Data")

                items: [
                    {
                        name: "Calendar",
                        description: "日历",
                        page: "CalendarPage.qml",
                        available: false
                    },
                    {
                        name: "Date Picker",
                        description: "日期选择器",
                        page: "DatePickerPage.qml",
                        available: false
                    },
                    {
                        name: "Table",
                        description: "数据表格",
                        page: "TablePage.qml",
                        available: true
                    },
                    {
                        name: "Data Table",
                        description: "排序 / 筛选 / 分页",
                        page: "DataTablePage.qml",
                        available: false
                    },
                    {
                        name: "Chart",
                        description: "QtCharts 图表",
                        page: "ChartPage.qml",
                        available: false
                    },
                    {
                        name: "Models",
                        description: "C++ Models 基类",
                        page: "ModelsPage.qml",
                        available: false
                    }
                ]
            }

            // ==================================================
            // Bottom spacing
            // ==================================================

            Item {
                width: 1
                height: 24
            }
        }
    }
}
