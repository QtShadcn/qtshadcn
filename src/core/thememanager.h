#pragma once

#include <QJSEngine>
#include <QObject>
#include <QQmlEngine>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

// C++ 能力层：主题引擎
// - 持有 light / dark 两套 Design Token 字典（QVariantMap）
// - mode 切换时整体替换 tokens 并 emit tokensChanged
// - 以 QML singleton 暴露给 QML：import QtShadcn 后直接访问 ThemeManager
class ThemeManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(QVariantMap tokens READ tokens NOTIFY tokensChanged)
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit ThemeManager(QObject *parent = nullptr);
    ~ThemeManager() override;

    // QML singleton 创建入口（引擎调用）
    static ThemeManager *create(QQmlEngine *engine, QJSEngine *jsEngine);

    QString mode() const;
    void setMode(const QString &mode);

    QVariantMap tokens() const;

    // 按名字取单个 token（QML 侧可直接 ThemeManager.tokens["xxx"]）
    Q_INVOKABLE QVariant token(const QString &name) const;

signals:
    void modeChanged();
    void tokensChanged();

private:
    void rebuildTokens();

    QString m_mode = QStringLiteral("light");
    QVariantMap m_tokens;
};
