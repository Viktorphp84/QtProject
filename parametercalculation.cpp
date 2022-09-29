#include "parametercalculation.h"
#include <QtMath>

ParameterCalculation::ParameterCalculation() {

}

//Записть в вектор значений активных нагрузок
void ParameterCalculation::setVecActivLoad(double activLoad) {
    m_vecActivLoad.push_back(activLoad);
}

//Запись в вектор значений коэфф. активных мощностей
void ParameterCalculation::setActivPowerCoefficient(double activPowerCoefficient) {
    m_vecActivPowerCoefficient.push_back(activPowerCoefficient);
}

//Запись в вектор значений длин участков
void ParameterCalculation::setVecLengthSite(double lengthSite) {
    m_vecLengthSite.push_back(lengthSite);
}

//Расчет отличий нагрузок
bool ParameterCalculation::isMoreThenFourTimes(int currentPosition) {

    bool isMoreThenFour;

    QVector<double>::iterator itVecActivLoadBegin = m_vecActivLoad.begin() + currentPosition;
    QVector<double>::iterator itVecActivLoadEnd = m_vecActivLoad.end();
    double maxElement = *std::max_element(itVecActivLoadBegin, itVecActivLoadEnd);
    double minElement = *std::min_element(itVecActivLoadBegin, itVecActivLoadEnd);
    m_Pmax = maxElement;

    if(maxElement / minElement > 4) {
        isMoreThenFour = true;
    } else {
        isMoreThenFour = false;
    }

    return isMoreThenFour;
}

//Расчет нагрузок по участкам
bool ParameterCalculation::calculationOfLoadsBySections() {
    for(int i = 0; i < m_numberOfConsumers; ++i)
    {
        //Если введенная нагрузка более 300кВт выводим сообщение
        if(m_vecActivLoad[i] > 300)
        {
            emit signalToQml();

            return 0;
        }

        if(!isMoreThenFourTimes(i)) {

            //Расчет по коэф. одновременности
            double Psum = 0;//сумма нагрузок
            //Расчет суммы нагрузок
            for(int k = i; k < m_numberOfConsumers; ++k)
            {
               Psum = Psum + m_vecActivLoad[k];
            }

            double coefOfSimultaneity = 0;//коэф. одновременности

            //Поиск коэф. одновременности
            switch(m_indexComboBoxConsum) {

            case 0: coefOfSimultaneity = findingCoefOfSimultaneity(mapCoefficientOfSimultaneity_UpTo_2kW, m_numberOfConsumers - i);
                break;
            case 1: coefOfSimultaneity = findingCoefOfSimultaneity(mapCoefficientOfSimultaneity_Over_2kW, m_numberOfConsumers - i);
                break;
            case 2: coefOfSimultaneity = findingCoefOfSimultaneity(mapCoefficientOfSimultaneity_ElectricStove, m_numberOfConsumers - i);
                break;
            case 3: coefOfSimultaneity = findingCoefOfSimultaneity(mapCoefficientOfSimultaneity_IndustrialConsumers, m_numberOfConsumers - i);
                break;
            }
            Psum *= coefOfSimultaneity;
            m_vecSiteLoads.push_back(Psum);
        } else {
            //Алгоритм расчета по добавкам мощностей
            double Psum = m_Pmax;//сохранение суммарной нагрузки

            for(int j = i; j < m_numberOfConsumers; ++j) {
                if(m_vecActivLoad[j] != m_Pmax) {
                    Psum += findingCoefOfSimultaneity(mapPowerAdditives, m_vecActivLoad[j]);
                }
            }
            m_vecSiteLoads.push_back(Psum);
        }
    }
    return 1;
}

void ParameterCalculation::clearVectors() {
    m_vecActivLoad.clear();
    m_vecLengthSite.clear();
    m_vecActivPowerCoefficient.clear();
    m_vecSiteLoads.clear();
    m_vecWeightedAverageCoefficient.clear();
    m_vecFullPower.clear();
    m_vecEquivalentPower.clear();
    m_vecEquivalentCurrent.clear();
    m_vecResistancePhaseZero.clear();
    m_vecSinglePhaseShortCircuit.clear();
    m_vecVoltageLoss.clear();
    m_vecDesignCurrent.clear();
    m_vecDesignCurrentConsumer.clear();
}

void ParameterCalculation::calculationWeightedAverage() {
    double Pcos = 0;//сумма произведений активной мощности потребителя на косинус
    double weightedAverageCoefficient = 0;//средневзвешенный косинус
    double Psum = 0;//сумма активных мощностей

    for(int i = 0; i < m_numberOfConsumers - 1; ++i)
    {
        for(int j  = i; j < m_numberOfConsumers; ++j)
        {
            Pcos = Pcos + m_vecActivLoad[j]
                    * m_vecActivPowerCoefficient[j];
            Psum = Psum + m_vecActivLoad[j];
        }
        weightedAverageCoefficient = Pcos / Psum;
        m_vecWeightedAverageCoefficient.push_back(weightedAverageCoefficient);
    }
    m_vecWeightedAverageCoefficient.push_back(m_vecActivPowerCoefficient[m_numberOfConsumers - 1]);
}

bool ParameterCalculation::parameterCalculation(int index) {
    m_indexComboBoxConsum = index;
    calculationWeightedAverage();
    if(calculationOfLoadsBySections()) {
        calculationFullPower();
        calculationDesignCurrent();
        calculationDesignCurrentConsumer();
        calculationEquivalentPower();
        calculationEquivalentCurrent();
        return 1;
    }
    return 0;
}

/*В функцию передается словарь для расчета коэф. одновременности или добавок
 *по мощностям и либо кол-во потребителей
 *либо нагрузка, по которой расчитывают добавку*/
template<typename type>
double ParameterCalculation::findingCoefOfSimultaneity(QMap<type, double> map, type key) {
    typename QMap<type, double>::iterator it = map.begin();
    for(; it != map.end(); ++it) {
        if(it.key() <= key && (++it).key() > key) {
            double member2_key = it.key();
            double member2_value = it.value();
            --it;
            double delta = key - it.key();
            double member1_key = it.key();
            double member1_value = it.value();
            double deltaMemberKey = member2_key - member1_key;
            double deltaMemberValue = member2_value - member1_value;
            double coef = (delta * deltaMemberValue) / deltaMemberKey;
            return member1_value + coef;
        }
        --it;
    }
    return -1;
}

QVector<double> ParameterCalculation::getVecSiteLoads() const {
    return m_vecSiteLoads;
}

QVector<double> ParameterCalculation::getVecWeightedAverage() const {
    return m_vecWeightedAverageCoefficient;
}

void ParameterCalculation::calculationFullPower() {
    for(int i = 0; i < m_numberOfConsumers; ++i) {
        m_vecFullPower.push_back(m_vecSiteLoads[i] / m_vecWeightedAverageCoefficient[i]);
    }
}

QVector<double> ParameterCalculation::getVecFullPower() const {
    return m_vecFullPower;
}

QVector<double> ParameterCalculation::getVecEquivalentPower() const {
    return m_vecEquivalentPower;
}

QVector<double> ParameterCalculation::getVecEquivalentCurrent() const {
    return m_vecEquivalentCurrent;
}

QVector<double> ParameterCalculation::getVecSinglePhaseShortCircuit() const {
    return m_vecSinglePhaseShortCircuit;
}

void ParameterCalculation::calculationEquivalentPower() {
    for(int i = 0; i < m_numberOfConsumers; ++i) {
        double sumLength = 0;
        double sumSquare = 0;
        double equivalentPower = 0;
        for(int j = i; j < m_numberOfConsumers; ++j) {
            sumLength += m_vecLengthSite[j];
            sumSquare += m_vecFullPower[j] * m_vecFullPower[j] * m_vecLengthSite[j];
        }
        equivalentPower = qSqrt(sumSquare / sumLength);
        m_vecEquivalentPower.push_back(equivalentPower);
    }
}

void ParameterCalculation::calculationEquivalentCurrent() {
    for(int i = 0; i < m_numberOfConsumers; ++i) {
        double equivalentCurrent = m_vecEquivalentPower[i] / (qSqrt(3) * 0.38);
        m_vecEquivalentCurrent.push_back(equivalentCurrent);
    }
}

void ParameterCalculation::calculationEconomicSection(const double economicCurrent, const int sectionNumber) {
    double economicSection = m_vecEquivalentCurrent[sectionNumber] / economicCurrent;
    m_economicSection = economicSection;
}

void ParameterCalculation::calculateResistancePhaseZero(const int currentIndex, const int sectionNumber) {
    double squareActivResistance = qPow((m_vecResistanceWire[currentIndex].activResistancePhase
                                         + m_vecResistanceWire[currentIndex].activResistanceZero), 2);
    double squareReactance = qPow((m_vecResistanceWire[currentIndex].reactancePhase
                                 + m_vecResistanceWire[currentIndex].reactanceZero), 2);
    m_resistancePhaseZero = m_vecLengthSite[sectionNumber] * qSqrt(squareActivResistance + squareReactance);
    m_vecResistancePhaseZero[sectionNumber] = m_resistancePhaseZero;
}

void ParameterCalculation::calculationSinglePhaseShortCircuit(const double transformerResistance) {
    if(!m_vecResistancePhaseZero.isEmpty()) {
        double sumResistancePhaseZero = 0;
        m_vecSinglePhaseShortCircuit.clear();
        for(int i = 0; i < m_numberOfConsumers; ++i) {
            sumResistancePhaseZero += m_vecResistancePhaseZero[i];
            m_vecSinglePhaseShortCircuit.push_back(220 / (transformerResistance / 3 + sumResistancePhaseZero));
        }
    }
}

void ParameterCalculation::fillingResistanceVectorPhaseZero() {
    m_vecResistancePhaseZero.clear();
    for(int i = 0; i < m_numberOfConsumers; ++i) {
        m_vecResistancePhaseZero.push_back(-1);
    }
}

bool ParameterCalculation::checkResistanceVectorPhaseZero() {
    QVector<double>::iterator begin = m_vecResistancePhaseZero.begin();
    QVector<double>::iterator end = m_vecResistancePhaseZero.end();
    QVector<double>::iterator it;
    it = std::find(begin, end, -1);
    bool result = (it == end) ? true : false;
    return result;
}

double ParameterCalculation::calculationVoltageLoss(const int currentIndex, const int numberSection) {
    double sin = qSqrt(1 - qPow(m_vecWeightedAverageCoefficient[numberSection], 2));
    double voltageLoss = (m_vecFullPower[numberSection]
                          * (m_vecResistanceWire[currentIndex].activResistancePhase
                             * m_vecWeightedAverageCoefficient[numberSection]
                             + m_vecResistanceWire[currentIndex].reactancePhase * sin)
                          * m_vecLengthSite[numberSection]) / 0.38;
    return voltageLoss;
}

void ParameterCalculation::calculationDesignCurrent() {
    for(int i = 0; i < m_numberOfConsumers; ++i) {
        double designCurrent = m_vecFullPower[i] / (qSqrt(3) * 0.38);
        m_vecDesignCurrent.push_back(designCurrent);
    }
}

QVector<double> ParameterCalculation::getVecDesignCurrent() const {
    return m_vecDesignCurrent;
}

void ParameterCalculation::calculationDesignCurrentConsumer() {
    for(int i = 0; i < m_numberOfConsumers; ++i) {
        double designCurrentConsumer = m_vecActivLoad[i] / (qSqrt(3) * 0.38 * m_vecWeightedAverageCoefficient[i]);
        m_vecDesignCurrentConsumer.push_back(designCurrentConsumer);
    }
}

QVector<double> ParameterCalculation::getVecDesignCurrentConsumer() const {
    return m_vecDesignCurrentConsumer;
}

double ParameterCalculation::calculationRecloser(double transformerResistance,
                                                 double activResistanceSum,
                                                 double ReactanceSum,
                                                 double thermalRelease) {
    double sensitivityConditionLength = (220 / (3 * thermalRelease) - transformerResistance / 3) /
            qSqrt((qPow(activResistanceSum, 2) + qPow(ReactanceSum, 2)));

}

QVector<double> ParameterCalculation::getResistancePhaseZero(int index) {
    QVector<double> resistance;
    resistance.push_back(m_vecResistanceWire[index].activResistancePhase);
    resistance.push_back(m_vecResistanceWire[index].activResistanceZero);
    resistance.push_back(m_vecResistanceWire[index].reactancePhase);
    resistance.push_back(m_vecResistanceWire[index].reactanceZero);
    return resistance;
}
