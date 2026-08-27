// src/core/models/shadcntablemodel.h
#pragma once
#include <QAbstractTableModel>
#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

// C++ 能力层：表格数据模型（M5）
// - rows: QVariantList，元素为 QObject* 或 QVariantMap（每行一条记录）
// - columns: QVariantList of QVariantMap，每项 { key, title, width, align }
//   key = 取数属性名；title = 表头文案；width = 列宽(px)；align = left/center/right
// - 以 QML_ELEMENT 注册，QML 侧 import QtShadcn 后直接 `ShadcnTableModel { ... }`
class ShadcnTableModel : public QAbstractTableModel
{
    Q_OBJECT
    Q_PROPERTY(QVariantList rows READ rows WRITE setRows NOTIFY rowsChanged)
    Q_PROPERTY(QVariantList columns READ columns WRITE setColumns NOTIFY columnsChanged)
    QML_ELEMENT

public:
    explicit ShadcnTableModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QVariantList rows() const;
    void setRows(const QVariantList &rows);

    QVariantList columns() const;
    void setColumns(const QVariantList &columns);

    // QML 便利：直接取单元格值（规避 delegate 内 role 名不可见）
    Q_INVOKABLE QVariant cellData(int row, int column) const;
    // 列元信息（title/align/width），列索引 → map
    Q_INVOKABLE QVariantMap columnMeta(int column) const;
    // 取某行所有属性（业务层/详情用）
    Q_INVOKABLE QVariantMap getRow(int row) const;
    // 更新某行若干字段并刷新对应 view
    Q_INVOKABLE void updateRow(int row, const QVariantMap &values);
    // 点击表头排序：按列 key（QVariant 自动比较 字符串/数字）
    Q_INVOKABLE void sortBy(int column, bool ascending = true);

signals:
    void rowsChanged();
    void columnsChanged();

private:
    static QVariant cellOf(const QVariant &item, const QString &key);

    QVariantList m_rows;
    QVariantList m_columns;
};
