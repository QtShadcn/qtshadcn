#include "iconregistry.h"

#include <QColor>
#include <QDir>
#include <QFile>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QUrl>

// ── IconRegistry ─────────────────────────────────────────────────────

IconRegistry::IconRegistry(QObject *parent)
    : QObject(parent)
{
    load();
    loadDiskCache();
}

IconRegistry *IconRegistry::create(QQmlEngine * /*engine*/, QJSEngine * /*jsEngine*/)
{
    // Qt 6.5+ qmlRegisterTypesAndRevisions 下此工厂不一定被调用（引擎可能直接默认构造）。
    // 本类不依赖 create 做任何初始化，仅保留以兼容旧式注册路径。
    return new IconRegistry;
}

void IconRegistry::load()
{
    // 从 qrc 枚举 :/icons/*.svg，文件名即图标名（lucide 命名）
    static const QRegularExpression commentRe(QStringLiteral("<!--[\\s\\S]*?-->"));
    const QDir dir(QStringLiteral(":/icons"));
    const QStringList files = dir.entryList({QStringLiteral("*.svg")}, QDir::Files, QDir::Name);
    for (const QString &file : files) {
        QFile f(QStringLiteral(":/icons/%1").arg(file));
        if (!f.open(QIODevice::ReadOnly))
            continue;
        QString svg = QString::fromUtf8(f.readAll());
        svg.remove(commentRe);                       // 去掉 lucide-static 的 license 注释
        const QString name = file.left(file.size() - 4);  // 去 ".svg"
        m_icons.insert(name, svg.trimmed());
    }
}

void IconRegistry::loadDiskCache()
{
    // 启动时把磁盘缓存的远程图标读进内存（拉过一次后续离线可用）
    const QDir dir(cacheDir());
    if (!dir.exists())
        return;
    const QStringList files = dir.entryList({QStringLiteral("*.svg")}, QDir::Files, QDir::Name);
    for (const QString &file : files) {
        QFile f(dir.filePath(file));
        if (!f.open(QIODevice::ReadOnly))
            continue;
        const QString name = file.left(file.size() - 4);
        m_remoteCache.insert(name, QString::fromUtf8(f.readAll()).trimmed());
    }
}

QString IconRegistry::cacheDir() const
{
    const QString base = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    return base.isEmpty() ? QStringLiteral("/tmp/qtshadcn-icons")
                          : base + QStringLiteral("/icons");
}

QStringList IconRegistry::names() const
{
    QStringList list = m_icons.keys();
    list.sort(Qt::CaseInsensitive);
    return list;
}

bool IconRegistry::has(const QString &name) const
{
    return m_icons.contains(name);
}

QString IconRegistry::dataUrl(const QString &name, const QString &color) const
{
    QString svgStr = m_icons.contains(name) ? m_icons.value(name) : QString();
    if (svgStr.isEmpty()) {
        if (m_remoteCache.contains(name))
            svgStr = m_remoteCache.value(name);
        else
            const_cast<IconRegistry *>(this)->requestRemote(name);   // 未命中 → 触发下载
    }
    if (svgStr.isEmpty())
        return QString();

    QColor col(color.isEmpty() ? QStringLiteral("#000000") : color);
    const QString hex = col.isValid() ? col.name(QColor::HexRgb) : QStringLiteral("#000000");
    svgStr.replace(QStringLiteral("currentColor"), hex);
    const QByteArray b64 = svgStr.toUtf8().toBase64();
    return QStringLiteral("data:image/svg+xml;base64,%1").arg(QString::fromLatin1(b64));
}

bool IconRegistry::remoteEnabled() const
{
    return m_remoteEnabled;
}

void IconRegistry::setRemoteEnabled(bool on)
{
    if (m_remoteEnabled == on)
        return;
    m_remoteEnabled = on;
    emit remoteEnabledChanged();
}

QString IconRegistry::svg(const QString &name) const
{
    // 保留内部取原始 svg 的便捷入口（当前仅 dataUrl 使用）
    if (m_icons.contains(name))
        return m_icons.value(name);
    return m_remoteCache.value(name);
}

void IconRegistry::requestRemote(const QString &name)
{
    if (!m_remoteEnabled || name.isEmpty())
        return;
    if (m_remoteCache.contains(name) || m_downloading.contains(name))
        return;

    // 防御：lucide 图标名只允许小写字母/数字/连字符，防止 URL 注入
    static const QRegularExpression safeRe(QStringLiteral("^[a-z0-9-]+$"));
    if (!safeRe.match(name).hasMatch())
        return;

    m_downloading.insert(name);
    if (!m_nam)
        m_nam = new QNetworkAccessManager(this);

    QNetworkRequest request(QUrl(QStringLiteral("https://unpkg.com/lucide-static@latest/icons/%1.svg").arg(name)));
    request.setTransferTimeout(15000);   // 15s 超时
    QNetworkReply *reply = m_nam->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, name] {
        onReplyFinished(reply, name);
    });
}

void IconRegistry::onReplyFinished(QNetworkReply *reply, const QString &name)
{
    m_downloading.remove(name);
    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError) {
        qWarning("IconRegistry: 远程图标 %s 下载失败: %s",
                 qPrintable(name), qPrintable(reply->errorString()));
        return;
    }

    QString svg = QString::fromUtf8(reply->readAll());
    static const QRegularExpression commentRe(QStringLiteral("<!--[\\s\\S]*?-->"));
    svg.remove(commentRe);
    svg = svg.trimmed();
    if (svg.isEmpty())
        return;

    m_remoteCache.insert(name, svg);

    // 磁盘缓存（拉过一次后续离线可用）
    QDir().mkpath(cacheDir());
    QFile f(cacheDir() + QStringLiteral("/%1.svg").arg(name));
    if (f.open(QIODevice::WriteOnly | QIODevice::Truncate))
        f.write(svg.toUtf8());

    emit iconReady(name);
}
