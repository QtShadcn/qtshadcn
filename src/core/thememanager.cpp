#include "thememanager.h"

#include <QColor>

ThemeManager::ThemeManager(QObject *parent)
    : QObject(parent)
{
    rebuildTokens();
}

ThemeManager::~ThemeManager() = default;

ThemeManager *ThemeManager::create(QQmlEngine *, QJSEngine *)
{
    return new ThemeManager;
}

QString ThemeManager::mode() const
{
    return m_mode;
}

void ThemeManager::setMode(const QString &mode)
{
    const QString normalized = (mode == QStringLiteral("dark")) ? QStringLiteral("dark")
                                                                : QStringLiteral("light");
    if (m_mode == normalized)
        return;
    m_mode = normalized;
    rebuildTokens();
    emit modeChanged();
}

QString ThemeManager::primary() const
{
    return m_primary;
}

void ThemeManager::setPrimary(const QString &color)
{
    if (m_primary == color)
        return;
    m_primary = color;
    rebuildTokens();
    emit primaryChanged();
}

QVariantMap ThemeManager::tokens() const
{
    return m_tokens;
}

QVariant ThemeManager::token(const QString &name) const
{
    return m_tokens.value(name);
}

// 语义对齐 shadcn/ui 默认主题：
// light  https://ui.shadcn.com/themes 默认值
// dark   同源 dark 默认值
void ThemeManager::rebuildTokens()
{
    // 主色覆盖：空 = 内置默认（light 深色 / dark 浅色）；设置后统一用该色
    const QString primaryColor = m_primary.isEmpty()
        ? (m_mode == QStringLiteral("dark") ? QStringLiteral("#fafafa")
                                            : QStringLiteral("#18181b"))
        : m_primary;
    // 前景自动对比色：感知亮度 > 0.5 → 深色文字，否则白字（shadcn: text-primary-foreground）
    const QColor pc(primaryColor);
    const double lum = 0.299 * pc.redF() + 0.587 * pc.greenF() + 0.114 * pc.blueF();
    const QString primaryFg = lum > 0.5 ? QStringLiteral("#18181b") : QStringLiteral("#fafafa");

    if (m_mode == QStringLiteral("dark")) {
        m_tokens = {
            // 颜色语义
            { QStringLiteral("background"),            QStringLiteral("#09090b") },
            { QStringLiteral("foreground"),            QStringLiteral("#fafafa") },
            { QStringLiteral("primary"),               primaryColor },
            { QStringLiteral("primaryForeground"),     primaryFg },
            { QStringLiteral("secondary"),             QStringLiteral("#27272a") },
            { QStringLiteral("secondaryForeground"),   QStringLiteral("#fafafa") },
            { QStringLiteral("muted"),                 QStringLiteral("#27272a") },
            { QStringLiteral("mutedForeground"),       QStringLiteral("#a1a1aa") },
            { QStringLiteral("accent"),                QStringLiteral("#27272a") },
            { QStringLiteral("accentForeground"),      QStringLiteral("#fafafa") },
            { QStringLiteral("destructive"),           QStringLiteral("#7f1d1d") },
            { QStringLiteral("destructiveForeground"), QStringLiteral("#fafafa") },
            { QStringLiteral("border"),                QStringLiteral("#27272a") },
            { QStringLiteral("ring"),                  QStringLiteral("#fafafa") },
            // M3: card / input / popover 系列（值对齐 shadcn 默认，= 背景/边框体系）
            { QStringLiteral("card"),                  QStringLiteral("#09090b") },
            { QStringLiteral("cardForeground"),        QStringLiteral("#fafafa") },
            { QStringLiteral("input"),                 QStringLiteral("#27272a") },
            { QStringLiteral("popover"),               QStringLiteral("#09090b") },
            { QStringLiteral("popoverForeground"),     QStringLiteral("#fafafa") },
            // 形状与间距
            { QStringLiteral("radius"),                8 },
            { QStringLiteral("spacingXs"),             4 },
            { QStringLiteral("spacingSm"),             8 },
            { QStringLiteral("spacingMd"),             12 },
            { QStringLiteral("spacingLg"),             16 },
            { QStringLiteral("spacingXl"),             24 },
        };
    } else {
        m_tokens = {
            // 颜色语义
            { QStringLiteral("background"),            QStringLiteral("#ffffff") },
            { QStringLiteral("foreground"),            QStringLiteral("#09090b") },
            { QStringLiteral("primary"),               primaryColor },
            { QStringLiteral("primaryForeground"),     primaryFg },
            { QStringLiteral("secondary"),             QStringLiteral("#f4f4f5") },
            { QStringLiteral("secondaryForeground"),   QStringLiteral("#18181b") },
            { QStringLiteral("muted"),                 QStringLiteral("#f4f4f5") },
            { QStringLiteral("mutedForeground"),       QStringLiteral("#71717a") },
            { QStringLiteral("accent"),                QStringLiteral("#f4f4f5") },
            // accentForeground 需与 foreground(#09090b) 有可见差异（outline/ghost hover 文字切换反馈）；
            // #3f3f46 在 accent 背景上对比度 ~9:1 可读（zinc-700）
            { QStringLiteral("accentForeground"),      QStringLiteral("#3f3f46") },
            { QStringLiteral("destructive"),           QStringLiteral("#ef4444") },
            { QStringLiteral("destructiveForeground"), QStringLiteral("#fafafa") },
            { QStringLiteral("border"),                QStringLiteral("#e4e4e7") },
            { QStringLiteral("ring"),                  QStringLiteral("#18181b") },
            // M3: card / input / popover 系列（值对齐 shadcn 默认，= 背景/边框体系）
            { QStringLiteral("card"),                  QStringLiteral("#ffffff") },
            { QStringLiteral("cardForeground"),        QStringLiteral("#09090b") },
            { QStringLiteral("input"),                 QStringLiteral("#e4e4e7") },
            { QStringLiteral("popover"),               QStringLiteral("#ffffff") },
            { QStringLiteral("popoverForeground"),     QStringLiteral("#09090b") },
            // 形状与间距
            { QStringLiteral("radius"),                8 },
            { QStringLiteral("spacingXs"),             4 },
            { QStringLiteral("spacingSm"),             8 },
            { QStringLiteral("spacingMd"),             12 },
            { QStringLiteral("spacingLg"),             16 },
            { QStringLiteral("spacingXl"),             24 },
        };
    }
    emit tokensChanged();
}
