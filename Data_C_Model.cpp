#include "Data_C_Model.h"

double Data_C_Model::getData(int column, int row) const {
    return vecResist[row][column];
}

int Data_C_Model::getRow() const {
    return vecResist.size();
}

int Data_C_Model::getColumn() const {
    return vecResist[0].size();
}

void Data_C_Model::setColumn() {
    vecResist[0].append(0);
    vecResist[1].append(0);
    vecResist[2].append(0);
    vecResist[3].append(0);
}

void Data_C_Model::deleteData(int column) {
    vecResist[0].removeAt(column);
    vecResist[1].removeAt(column);
    vecResist[2].removeAt(column);
    vecResist[3].removeAt(column);
}

void Data_C_Model::write(int column, int row, QString str) {
    vecResist[row][column] = str.toDouble();
}

void Data_C_Model::setData(int row, double data) {
    vecResist[row].push_back(data);
}

void Data_C_Model::cleanData() {
    for(int i = 0; i < 4; ++i) {
        vecResist[i].clear();
    }
}

void Data_C_Model::setDefault() {
    vecResist.clear();
    vecResist = vecResistDefault;
}
