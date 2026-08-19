#pragma once

#include <QHash>
#include <QJSEngine>
#include <QObject>
#include <QQmlEngine>
#include <QSet>
#include <QStringList>
#include <QtQml/qqmlregistration.h>

class QNetworkAccessManager;
class QNetworkReply;

// C++ 能力层：图标注册表（M4）
// - 本地内置：.qrc（:/icons/*.svg，lucide 风格精选集），零延迟 / 离线可用 / 随主题变色
// - 远程兜底：本地没有的名字按需从 lucide CDN（unpkg）异步拉取 → 内存 + 磁盘缓存
//   （QStandardPaths::CacheLocation/icons，拉过一次后续离线可用），下载完成发 iconReady
// - 渲染：dataUrl(name, color) 返回「替换好 currentColor 的 svg → base64 data URL」，
//   QML 侧 ShadcnIcon 直接当 Image.source 用（无需 QQuickImageProvider，跨工程开箱即用）
// - 以 QML singleton 暴露：import QtShadcn 后直接 IconRegistry.names / .dataUrl(...)
class IconRegistry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList names READ names NOTIFY iconsChanged)
    Q_PROPERTY(bool remoteEnabled READ remoteEnabled WRITE setRemoteEnabled NOTIFY remoteEnabledChanged)
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit IconRegistry(QObject *parent = nullptr);

    // QML singleton 创建入口（Qt 6.5+ qmlRegisterTypesAndRevisions 下不一定被调，
    // 引擎可能直接默认构造；本类不依赖 create 做初始化）
    static IconRegistry *create(QQmlEngine *engine, QJSEngine *jsEngine);

    // 已注册图标名列表（本地内置，无 .svg 后缀）
    QStringList names() const;

    Q_INVOKABLE bool has(const QString &name) const;

    // 生成 Image 可直接使用的 data URL：svg 替换 currentColor 为请求颜色后 base64。
    // 本地图标立即返回；远程图标首次返回空（触发异步下载），iconReady 后重取即有值。
    Q_INVOKABLE QString dataUrl(const QString &name, const QString &color = QString()) const;

    // 远程兜底开关（默认 true；企业内网等场景可关）
    bool remoteEnabled() const;
    void setRemoteEnabled(bool on);

signals:
    void iconsChanged();
    void remoteEnabledChanged();
    // 远程图标下载完成（QML 侧 ShadcnIcon 监听后重新取 dataUrl）
    void iconReady(const QString &name);

private:
    void load();
    void loadDiskCache();
    void requestRemote(const QString &name);
    void onReplyFinished(QNetworkReply *reply, const QString &name);
    QString cacheDir() const;
    QString svg(const QString &name) const;

    QHash<QString, QString> m_icons;        // 本地内置（qrc）
    QHash<QString, QString> m_remoteCache;  // 远程已加载（内存，值 = 原始 svg）
    QSet<QString> m_downloading;            // 下载中（避免重复请求）
    bool m_remoteEnabled = true;
    QNetworkAccessManager *m_nam = nullptr;
};
