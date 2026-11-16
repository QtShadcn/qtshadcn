import QtQuick

// variant → Design Token 的规格类型（VariantTokens 的元素类型）
//
// 为什么要有这个具名类型：VariantTokens 里若用内联 QtObject 声明元素，
// 静态分析只能看到 QObject，于是 vt.button[i].bg、vt.checkedOverride.fg
// 这类访问全部被判成 missing-property（误报），且字段名拼错也发现不了。
// 用具名类型后静态可解析，字段拼错会变成阻塞级错误。
//
// 字段语义：
//   bg          背景 token 名；"" = 透明背景
//   fg          前景（文字/图标）token 名
//   border      是否需要 1px 描边
//   hoverMix    hover 时按钮色向页面背景混合的比例
//               （对齐 shadcn hover:bg-*/90 → 0.1；secondary 是 /80 → 0.2）
//   bgAlpha     背景透明度（Badge destructive 用 0.10 做透明底红字）
//   borderToken 描边色 token 名
QtObject {
    property string bg: ""
    property string fg: ""
    property bool border: false
    property real hoverMix: 0.1
    property real bgAlpha: 1.0
    property string borderToken: "border"
}
