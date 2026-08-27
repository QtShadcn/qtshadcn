// tests/model/shadcntablemodel_test.cpp
#include <QTest>
#include <QObject>
#include "shadcntablemodel.h"

class ShadcnTableModelTest : public QObject
{
    Q_OBJECT
private slots:
    void rowColumnCount();
    void cellDataAndMeta();
    void updateRowRefreshes();
    void sortByAscendingDescending();
};

void ShadcnTableModelTest::rowColumnCount()
{
    ShadcnTableModel m;
    m.setColumns(QVariantList() << QVariantMap{{"key", "name"}} << QVariantMap{{"key", "age"}});
    m.setRows(QVariantList() << QVariantMap{{"name", "A"}, {"age", 30}}
                                << QVariantMap{{"name", "B"}, {"age", 25}});
    QCOMPARE(m.rowCount(), 2);
    QCOMPARE(m.columnCount(), 2);
}

void ShadcnTableModelTest::cellDataAndMeta()
{
    ShadcnTableModel m;
    m.setColumns(QVariantList() << QVariantMap{{"key", "name"}, {"title", "姓名"}, {"align", "left"}});
    m.setRows(QVariantList() << QVariantMap{{"name", "Alice"}});
    QCOMPARE(m.cellData(0, 0).toString(), QString("Alice"));
    QCOMPARE(m.columnMeta(0).value("title").toString(), QString("姓名"));
    QCOMPARE(m.getRow(0).value("name").toString(), QString("Alice"));
}

void ShadcnTableModelTest::updateRowRefreshes()
{
    ShadcnTableModel m;
    m.setColumns(QVariantList() << QVariantMap{{"key", "name"}});
    m.setRows(QVariantList() << QVariantMap{{"name", "Old"}});
    bool changed = false;
    connect(&m, &ShadcnTableModel::dataChanged, [&]() { changed = true; });
    m.updateRow(0, QVariantMap{{"name", "New"}});
    QCOMPARE(m.cellData(0, 0).toString(), QString("New"));
    QVERIFY(changed);
}

void ShadcnTableModelTest::sortByAscendingDescending()
{
    ShadcnTableModel m;
    m.setColumns(QVariantList() << QVariantMap{{"key", "age"}});
    m.setRows(QVariantList() << QVariantMap{{"age", 30}} << QVariantMap{{"age", 10}} << QVariantMap{{"age", 20}});
    m.sortBy(0, true);
    QCOMPARE(m.cellData(0, 0).toInt(), 10);
    QCOMPARE(m.cellData(2, 0).toInt(), 30);
    m.sortBy(0, false);
    QCOMPARE(m.cellData(0, 0).toInt(), 30);
    QCOMPARE(m.cellData(2, 0).toInt(), 10);
}

QTEST_MAIN(ShadcnTableModelTest)
#include "shadcntablemodel_test.moc"
