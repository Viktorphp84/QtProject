#ifndef DATA_C_MODEL_H
#define DATA_C_MODEL_H

#include <QVector>
#include <QPair>

class Data_C_Model {

    QVector<QVector<double>>vecResistDefault =
    {{25,   40,    63,    100,   160,   250,   400,   630},
     {3.11, 1.949, 1.237, 0.779, 0.487, 0.312, 0.195, 0.129},
     {0.9,  0.57,  0.36,  0.225, 0.15,  0.09,  0.066, 0.042},
     {0,    0,     0,     0.225, 0.141, 0.084, 0.054, 0.042}};

    QVector<QVector<double>> vecResist = {{}, {}, {}, {}};

public:
    double getData(int, int) const;
    int getRow() const;
    int getColumn() const;
    void setColumn();
    void deleteData(int);
    void write(int, int, QString);
    void setData(int, double);
    void cleanData();
    void setDefault();
};
#endif // DATA_C_MODEL_H
