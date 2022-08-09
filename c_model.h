#ifndef C_MODEL_H
#define C_MODEL_H

#include <QObject>
#include <QtQml/qqml.h>
#include <QAbstractTableModel>
#include <QVariant>
#include "Data_C_Model.h"
#include <QFile>
#include <QTextStream>


class C_Model : public QAbstractTableModel
{
    Q_OBJECT
    QML_ELEMENT

    Data_C_Model dataModel;
    QFile saveFile;

public:
    explicit C_Model(QObject *parent = nullptr);

    int rowCount(const QModelIndex& = QModelIndex()) const override;
    int columnCount(const QModelIndex& = QModelIndex()) const override;

    QVariant data(const QModelIndex& index, int role) const override;
    QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void rewriteData();
    Q_INVOKABLE void addColumn();
    Q_INVOKABLE void deleteColumn(int);
    Q_INVOKABLE void writeData(int, QString);
    Q_INVOKABLE void setDefaultModel();
};

#endif // C_MODEL_H
