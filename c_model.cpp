#include "c_model.h"

C_Model::C_Model(QObject *parent): QAbstractTableModel(parent) {
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

int C_Model:: rowCount(const QModelIndex&) const  {
    return dataModel.getRow();
}

int C_Model::columnCount(const QModelIndex&) const {
    return dataModel.getColumn();
}

QVariant C_Model::data(const QModelIndex& index, int role) const {
    switch (role) {
        case Qt::DisplayRole: {
            double number = dataModel.Data_C_Model::getData(index.column(), index.row());
            return QString("%1").arg(number);
        }

        break;

    }
    return QVariant();
}

QModelIndex C_Model::index(int row, int column, const QModelIndex &parent) const {
    Q_UNUSED( parent)
    return C_Model::createIndex(row, column);
}

QHash<int, QByteArray> C_Model::roleNames() const {
    return { {Qt::DisplayRole, "display"},
             {Qt::UserRole,    "userRole"}};
}

void C_Model::addColumn() {
    beginInsertColumns(QModelIndex(), columnCount(), columnCount());

    dataModel.setColumn();
    insertColumn(dataModel.getColumn(), QModelIndex());

    endInsertColumns();
}

void C_Model::deleteColumn(int index) {
    beginRemoveColumns(QModelIndex(), int(index / 4), int(index / 4));

    dataModel.deleteData(int(index / 4));
    removeColumn(int(index / 4), QModelIndex());

    endRemoveColumns();
}

void C_Model::writeData(int index, QString str) {
    int column = index / 4;
    int row = index - 4 * column;
    if(column < dataModel.getColumn()) {
        dataModel.write(column, row, str);
    }
    if(saveFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream writeStream(&saveFile);
        for(int i = 0; i < C_Model::rowCount(); ++i) {
            for(int n = 0; n < C_Model::columnCount(); ++n) {
                writeStream << dataModel.getData(n, i) << " ";
            }
            writeStream << "\n";
        }
        saveFile.close();
    }
}

void C_Model::rewriteData() {
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

void C_Model::setDefaultModel() {
    beginResetModel();
    dataModel.setDefault();
    endResetModel();
}

