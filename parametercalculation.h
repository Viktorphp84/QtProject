#ifndef PARAMETERCALCULATION_H
#define PARAMETERCALCULATION_H

#include <QObject>
#include <QVector>
#include <QMap>

class ParameterCalculation : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int numberOfConsumers MEMBER m_numberOfConsumers)
    Q_PROPERTY(int indexComboBoxConsum MEMBER m_indexComboBoxConsum)
    Q_PROPERTY(double economicSection MEMBER m_economicSection)
    Q_PROPERTY(double resistancePhaseZero MEMBER m_resistancePhaseZero)

    QVector<double> m_vecActivLoad;//вектор активных нагрузок
    QVector<double> m_vecLengthSite;//вектор длин участков
    QVector<double> m_vecActivPowerCoefficient;//вектор коэф. активных мощностей
    QVector<double> m_vecSiteLoads;//вектор нагрузок по участкам
    QVector<double> m_vecWeightedAverageCoefficient;//вектор средневзвешенных коэф. на участках
    QVector<double> m_vecFullPower;//вектор полных мощностей
    QVector<double> m_vecEquivalentPower;//вектор эквивалентных мощностей
    QVector<double> m_vecEquivalentCurrent;//вектор эквивалентных токов
    QVector<double> m_vecResistancePhaseZero;//вектор сопротивлений фаза-ноль
    QVector<double> m_vecSinglePhaseShortCircuit;//вектор однофазных КЗ по участкам

    int m_numberOfConsumers = 0;
    double m_Pmax = 0;
    int m_indexComboBoxConsum = 0;
    double m_economicSection = 0;
    double m_resistancePhaseZero = 0;
    //double m_singlePhaseShortCircuit = 0;

    //Сопротивления провода
    struct resistanceWire {
        double activResistancePhase = 0;
        double activResistanceZero = 0;
        double reactancePhase = 0;
        double reactanceZero = 0;
    };

    //Вектор сопротивлений проводов
    QVector<resistanceWire> m_vecResistanceWire = {
        {0, 0, 0, 0},                   //0
        {2.448, 1.770, 0.0865, 0.0739}, //1-16
        {1.540, 1.770, 0.0827, 0.0703}, //2-25
        {1.111, 1.262, 0.0802, 0.0691}, //3-35
        {0.822, 0.632, 0.0799, 0.0685}, //4-50
        {0.568, 0.527, 0.0789, 0.0669}, //5-70
        {0.411, 0.527, 0.0762, 0.0656}, //6-95
        {0.325, 0.527, 0.0745, 0.0650}, //7-120
        {0.265, 0.527, 0.0730, 0.0647}, //8-150
        {0.211, 0.527, 0.0723, 0.0649}, //9-185
        {0.162, 0.527, 0.0705, 0.0647}  //10-240
    };


    //Коэффициенты одновременности для жилых домов с нагрузкой до 2 кВт
    QMap <int, double> mapCoefficientOfSimultaneity_UpTo_2kW = {
                                                                     {1, 1},     //1
                                                                     {2, 0.76},  //2
                                                                     {3, 0.66},  //2
                                                                     {5, 0.55},  //4
                                                                     {10, 0.44}, //5
                                                                     {20, 0.37}, //6
                                                                     {50, 0.30}, //7
                                                                     {100, 0.26},//8
                                                                     {200, 0.24},//9
                                                                     {500, 0.22},//10
                                                                    };

    //Коэффициенты одновременности для жилых домов с нагрузкой свыше 2 кВт
    QMap <int, double> mapCoefficientOfSimultaneity_Over_2kW = {
                                                                     {1, 1},     //1
                                                                     {2, 0.75},  //2
                                                                     {3, 0.64},  //3
                                                                     {5, 0.53},  //4
                                                                     {10, 0.42}, //5
                                                                     {20, 0.34}, //6
                                                                     {50, 0.27}, //7
                                                                     {100, 0.24},//8
                                                                     {200, 0.20},//9
                                                                     {500, 0.18},//10
                                                                    };

    //Коэффициенты одновременности для жилых домов с электроплитами
    QMap <int, double> mapCoefficientOfSimultaneity_ElectricStove = {
                                                                     {1, 1},     //1
                                                                     {2, 0.73},  //2
                                                                     {3, 0.62},  //3
                                                                     {5, 0.50},  //4
                                                                     {10, 0.38}, //5
                                                                     {20, 0.29}, //6
                                                                     {50, 0.22}, //7
                                                                     {100, 0.17},//8
                                                                     {200, 0.15},//9
                                                                     {500, 0.12},//10
                                                                    };

    //Коэффициенты одновременности для производственных потребителей
    QMap <int, double> mapCoefficientOfSimultaneity_IndustrialConsumers = {
                                                                     {1, 1},     //1
                                                                     {2, 0.85},  //2
                                                                     {3, 0.80},  //3
                                                                     {5, 0.75},  //4
                                                                     {10, 0.65}, //5
                                                                     {20, 0.55}, //6
                                                                     {50, 0.47}, //7
                                                                     {100, 0.40},//8
                                                                     {200, 0.35},//9
                                                                     {500, 0.30},//10
                                                                    };
    //Добавки к мощностям
    QMap <double, double> mapPowerAdditives = {
                                                   {0, 0},       //0
                                                   {0.2,0.2},    //1
                                                   {0.4,0.3},    //2
                                                   {0.6,0.4},    //3
                                                   {0.8,0.5},    //4
                                                   {1.0,0.6},    //5
                                                   {2.0,1.2},    //6
                                                   {3.0,1.8},    //7
                                                   {4.0,2.4},    //8
                                                   {5.0,3.0},    //9
                                                   {6.0,3.6},    //10
                                                   {7.0,4.2},    //11
                                                   {8.0,4.8},    //12
                                                   {9.0,5.4},    //13
                                                   {10.0,6.0},   //14
                                                   {12.0,7.3},   //15
                                                   {14.0,8.5},   //16
                                                   {16.0,9.8},   //17
                                                   {18.0,11.2},  //18
                                                   {20.0,12.5},  //19
                                                   {22.0,13.8},  //20
                                                   {24.0,15.0},  //21
                                                   {26.0,16.4},  //22
                                                   {28.0,17.7},  //23
                                                   {30.0,19.0},  //24
                                                   {32.0,20.4},  //25
                                                   {35.0,22.8},  //26
                                                   {40.0,26.5},  //27
                                                   {45.0,30.2},  //28
                                                   {50.0,34.0},  //29
                                                   {55.0,37.5},  //30
                                                   {60.0,41.0},  //31
                                                   {65.0,44.5},  //32
                                                   {70.0,48.0},  //33
                                                   {80.0,55.0},  //34
                                                   {90.0,62.0},  //35
                                                   {100.0,69.0}, //36
                                                   {110.0,76.0}, //37
                                                   {120.0,84.0}, //38
                                                   {130.0,92.0}, //39
                                                   {140.0,100.0},//40
                                                   {150.0,108.0},//41
                                                   {160.0,116.0},//42
                                                   {170.0,123.0},//43
                                                   {180.0,130.0},//44
                                                   {190.0,140.0},//45
                                                   {200.0,150.0},//46
                                                   {210.0,158.0},//47
                                                   {220.0,166.0},//48
                                                   {230.0,174.0},//49
                                                   {240.0,182.0},//50
                                                   {250.0,190.0},//51
                                                   {260.0,198.0},//52
                                                   {270.0,206.0},//53
                                                   {280.0,214.0},//54
                                                   {290.0,222.0},//55
                                                   {300.0,230.0} //56
                                                  };

public:
    ParameterCalculation();

    Q_INVOKABLE void setVecActivLoad(double);//добавление значения в вектор нагрузок
    Q_INVOKABLE void setVecLengthSite(double);//добавление занчения в вектор длин участков
    Q_INVOKABLE void setActivPowerCoefficient(double);//добавление заначения в вектор коэф. активной мощности
    Q_INVOKABLE void clearVectors();//очистка всех векторов
    Q_INVOKABLE void parameterCalculation();//основная функция из которой расчитываются все параметры сети
    Q_INVOKABLE QVector<double> getVecSiteLoads() const;//получить вектор m_vecSiteLoad
    Q_INVOKABLE QVector<double> getVecWeightedAverage() const;//получить вектор средневзвешенных косинусов
    Q_INVOKABLE QVector<double> getVecFullPower() const;//получить вектор полных мощностей
    Q_INVOKABLE QVector<double> getVecEquivalentPower() const;//получить вектор эквивалентных мощностей
    Q_INVOKABLE QVector<double> getVecEquivalentCurrent() const;//получить вектор эквивалентных токов
    Q_INVOKABLE QVector<double> getVecSinglePhaseShortCircuit() const;//получить вектор однофазных КЗ
    Q_INVOKABLE void calculationEconomicSection(const double, const int);//расчет экономического сечения
    Q_INVOKABLE void calculationResistancePhaseZero(const int, const int);/* метод принимает
    значения активного и реактивного сопротивлений фазного и нулевго проводов и рассчитывае сопротивление петли фаза-ноль*/
    Q_INVOKABLE void calculationSinglePhaseShortCircuit(const double);//расчет однофазных КЗ
    Q_INVOKABLE void fillingResistanceVectorPhaseZero();//заполнение вектора сопротивления петли фаза-ноль значением -1
    Q_INVOKABLE bool checkResistanceVectorPhaseZero();//проверка вектора сопротивления петли фаза-ноль на наличие значения -1

    bool isMoreThenFourTimes(int);//определение отличия нагрузок
    void calculationWeightedAverage();//расчет средневзвешенных косинусов по участкам
    void calculationOfLoadsBySections();//расчет нагрузок по участкам
    void calculationFullPower();//расчет полной мощности
    void calculationEquivalentPower();//расчет эквивалентной мощности
    void calculationEquivalentCurrent();//расчет эквивалентных токов


    template<typename type>
    double findingCoefOfSimultaneity(QMap<type, double>, type);

signals:
    void signalToQml();//сигнал вывода сообщения о вводе мощности потребителя более 300кВт
};

#endif // PARAMETERCALCULATION_H
