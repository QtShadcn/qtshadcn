// src/core/models/shadcntablemodel.cpp
#include "shadcntablemodel.h"
#include <QObject>
#include <algorithm>

ShadcnTableModel::ShadcnTableModel(QObject *parent)
    : QAbstractTableModel(parent) {}

int ShadcnTableModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_rows.size();
}

int ShadcnTableModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_columns.size();
}

QHash<int, QByteArray> ShadcnTableModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    for (int i = 0; i < m_columns.size(); ++i) {
        const QString key = m_columns.at(i).toMap().value("key").toString();
        roles[Qt::UserRole + i] = key.toUtf8();
    }
    return roles;
}

QVariant ShadcnTableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || role < Qt::UserRole)
        return QVariant();
    const int col = role - Qt::UserRole;
    if (col < 0 || col >= m_columns.size())
        return QVariant();
    return cellData(index.row(), col);
}

QVariant ShadcnTableModel::cellOf(const QVariant &item, const QString &key)
{
    if (item.canConvert<QObject *>()) {
        QObject *obj = item.value<QObject *>();
        return obj ? obj->property(key.toUtf8().constData()) : QVariant();
    }
    return item.toMap().value(key);
}

QVariant ShadcnTableModel::cellData(int row, int column) const
{
    if (row < 0 || row >= m_rows.size()) return QVariant();
    if (column < 0 || column >= m_columns.size()) return QVariant();
    const QString key = m_columns.at(column).toMap().value("key").toString();
    return cellOf(m_rows.at(row), key);
}

QVariantMap ShadcnTableModel::columnMeta(int column) const
{
    if (column < 0 || column >= m_columns.size()) return QVariantMap();
    return m_columns.at(column).toMap();
}

QVariantMap ShadcnTableModel::getRow(int row) const
{
    QVariantMap out;
    if (row < 0 || row >= m_rows.size()) return out;
    const QVariant item = m_rows.at(row);
    if (item.canConvert<QObject *>()) {
        QObject *obj = item.value<QObject *>();
        if (!obj) return out;
        for (const QByteArray &p : obj->dynamicPropertyNames())
            out[QString::fromUtf8(p)] = obj->property(p.constData());
    } else {
        out = item.toMap();
    }
    return out;
}

void ShadcnTableModel::updateRow(int row, const QVariantMap &values)
{
    if (row < 0 || row >= m_rows.size()) return;
    QVariant item = m_rows.at(row);
    if (item.canConvert<QObject *>()) {
        QObject *obj = item.value<QObject *>();
        if (obj) {
            for (auto it = values.begin(); it != values.end(); ++it)
                obj->setProperty(it.key().toUtf8().constData(), it.value());
        }
    } else {
        QVariantMap map = item.toMap();
        for (auto it = values.begin(); it != values.end(); ++it)
            map[it.key()] = it.value();
        m_rows[row] = map;
    }
    emit dataChanged(index(row, 0), index(row, columnCount() - 1));
}

void ShadcnTableModel::sortBy(int column, bool ascending)
{
    if (column < 0 || column >= m_columns.size() || m_rows.isEmpty()) return;
    const QString key = m_columns.at(column).toMap().value("key").toString();
    std::sort(m_rows.begin(), m_rows.end(), [&](const QVariant &a, const QVariant &b) {
        // Qt 6 移除了 QVariant::operator<，改用静态 QVariant::compare 返回 QPartialOrdering
        const bool less = QVariant::compare(cellOf(a, key), cellOf(b, key)) == QPartialOrdering::Less;
        return ascending ? less : !less;
    });
    emit dataChanged(index(0, 0), index(rowCount() - 1, columnCount() - 1));
}

QVariantList ShadcnTableModel::rows() const { return m_rows; }
void ShadcnTableModel::setRows(const QVariantList &rows)
{
    beginResetModel();
    m_rows = rows;
    endResetModel();
    emit rowsChanged();
}

QVariantList ShadcnTableModel::columns() const { return m_columns; }
void ShadcnTableModel::setColumns(const QVariantList &columns)
{
    beginResetModel();
    m_columns = columns;
    endResetModel();
    emit columnsChanged();
}
