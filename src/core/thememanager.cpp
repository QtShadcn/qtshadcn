#include "thememanager.h"

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
    if (m_mode == QStringLiteral("dark")) {
        m_tokens = {
            // 颜色语义
            { QStringLiteral("background"),            QStringLiteral("#09090b") },
            { QStringLiteral("foreground"),            QStringLiteral("#fafafa") },
            { QStringLiteral("primary"),               QStringLiteral("#fafafa") },
            { QStringLiteral("primaryForeground"),     QStringLiteral("#18181b") },
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
            { QStringLiteral("primary"),               QStringLiteral("#18181b") },
            { QStringLiteral("primaryForeground"),     QStringLiteral("#fafafa") },
            { QStringLiteral("secondary"),             QStringLiteral("#f4f4f5") },
            { QStringLiteral("secondaryForeground"),   QStringLiteral("#18181b") },
            { QStringLiteral("muted"),                 QStringLiteral("#f4f4f5") },
            { QStringLiteral("mutedForeground"),       QStringLiteral("#71717a") },
            { QStringLiteral("accent"),                QStringLiteral("#f4f4f5") },
            { QStringLiteral("accentForeground"),      QStringLiteral("#18181b") },
            { QStringLiteral("destructive"),           QStringLiteral("#ef4444") },
            { QStringLiteral("destructiveForeground"), QStringLiteral("#fafafa") },
            { QStringLiteral("border"),                QStringLiteral("#e4e4e7") },
            { QStringLiteral("ring"),                  QStringLiteral("#18181b") },
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
