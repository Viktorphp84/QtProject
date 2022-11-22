#include "c_model.h"

CppModel::CppModel(QObject *parent): QAbstractTableModel(parent) {
    saveFile.setFileName("savaData.txt");
    if(saveFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&saveFile);
        QString line = in.readLine();
        if(line.isEmpty()) {
           dataModel.setDefault();
           saveFile.close();
        } else {
            saveFile.close();
            rewriteData();
        }
    }
}

int CppModel:: rowCount(const QModelIndex&) const  {
    return dataModel.getRow();
}

int CppModel::columnCount(const QModelIndex&) const {
    return dataModel.getColumn();
}

QVariant CppModel::data(const QModelIndex& index, int role) const {
    switch (role) {
        case Qt::DisplayRole: {
            double number = dataModel.Data_C_Model::getData(index.column(), index.row());
            return QString("%1").arg(number);
        }

        break;

    }
    return QVariant();
}

QModelIndex CppModel::index(int row, int column, const QModelIndex &parent) const {
    Q_UNUSED( parent)
    return CppModel::createIndex(row, column);
}

QHash<int, QByteArray> CppModel::roleNames() const {
    return { {Qt::DisplayRole, "display"},
             {Qt::UserRole,    "userRole"}};
}

void CppModel::addColumn() {
    beginInsertColumns(QModelIndex(), columnCount(), columnCount());

    dataModel.setColumn();
    insertColumn(dataModel.getColumn(), QModelIndex());

    endInsertColumns();
}

void CppModel::deleteColumn(int index) {
    beginRemoveColumns(QModelIndex(), int(index / 4), int(index / 4));

    dataModel.deleteData(int(index / 4));
    removeColumn(int(index / 4), QModelIndex());

    endRemoveColumns();
}

void CppModel::writeData(int index, QString str) {
    int column = index / 4;
    int row = index - 4 * column;
    if(column < dataModel.getColumn()) {
        dataModel.write(column, row, str);
    }
    if(saveFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream writeStream(&saveFile);
        for(int i = 0; i < CppModel::rowCount(); ++i) {
            for(int n = 0; n < CppModel::columnCount(); ++n) {
                writeStream << dataModel.getData(n, i) << " ";
            }
            writeStream << "\n";
        }
        saveFile.close();
    }
}

void CppModel::rewriteData() {
    if(saveFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&saveFile);
        dataModel.cleanData();
        int count = 0;
        while(!in.atEnd()) {
            QString line = in.readLine();
            QString num = "";
            for(int i = 0; i < line.size(); ++i) {
                if(line[i] != ' ') {
                    num = num + line[i];
                }
                else {
                    dataModel.setData(count, num.toDouble());
                    num = "";
                }
            }
            /*dataModel.setData(count, num.toDouble());
            num = "";*/
            ++count;
        }
        saveFile.close();
    }
}

void CppModel::setDefaultModel() {
    beginResetModel();
    dataModel.setDefault();
    endResetModel();
}

double CppModel::getTransformerPower(int index) {
    int column = qFloor(index / 4);
    return dataModel.Data_C_Model::getData(column, 0);
}
