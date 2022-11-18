import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import ParameterCalculation
import QtCharts

Item {
    id: inputData
    width: 677
    height: 360

    property var component

    property int toFixed: 6 //указывает до скольки знаков будут округляться результаты расчетов при выводе в строки

    property var parameterCalculation: parameterCalculation
    property alias numberOfConsumers: parameterCalculation.numberOfConsumers
    property alias transformerResistance: textFieldTransformerResistance.text
    property alias connectionDiagram: textFieldConnectionDiagram.text
    property alias transformerPower: textFieldTransformerPower.text
    property double sumDesignCurrentConsumer: 0 //суммарный расчетный ток потребителей

    property var arrayLengthSite: [] //массив длин участков
    property var arrayActivePower: [] //масив активных мощностей
    property var arrSinglePhaseShortCircuit: [] //массив КЗ

    //Двигатель
    property double startingCurrentRatio: 0 //кратность пускового тока
    property double engineType: 0           //тип двигателя
    property double startingCurrent: 0      //пусковой ток
    property double ratedEngineCurrent: 0   //номинальный ток электродвигателя


    property int temp: 0 //переменная для сравнения текущего количества потребителей и введенного
    property bool checkBox3CheckState: true //дополнительная переменная для снятия ограничения на выбор элементов в comboBoxFire
    property double thermalRelease: 0
    property var vectorResistancePhaseZero: [] //массив для сохранения сопротивлений петель фаза-ноль по участкам

    //Перерасчет сечений
    property bool isFirstSession: true //переменная показывает вызывалась ли функция перерасчета сечения раньше
    property bool needRecalculate: false //нужен перерасчет сечений или нет
    property alias percentageLoss: textFieldCheckBox2.text

    //СП
    property var arrayRecloserLength: [] //массив для сохранения расстояний до СП
    property double sensitivityConditionLength: 0 //расстояние до СП
    property int numberOfReclosers: 0 //количество СП
    property int siteNumber: 0 //номер участка

    //Переменные для сохранения позиции и размера окна при развертываниии на весь экран
    property int inputDataX: 0
    property int inputDataY: 0
    property int inputDataHeigth: 0

    property alias columnScroll_4: columnScroll_4

    DropShadow {
        anchors.fill: rectangleInputData
        source: rectangleInputData
        transparentBorder: true
        horizontalOffset: 3
        verticalOffset: 3
        radius: 5
        color: "#80000000"
    }

    //Соединение с сигналов из класса C++ ParameterCalculation
    /*******************************************************************************************************/
    Connections {
        target: parameterCalculation
        function onSignalToQml() {
            dialogWarning.title = "Введена нагрузка более 300 кВт!"
            dialogWarning.visible = true
        }
    }
    /*******************************************************************************************************/

    //Проверка, что все поля заполнены
    /*******************************************************************************************************/
    function checkField(target) {

        numberOfConsumers = columnScroll_1.children.length

        for (let r = 0; r < numberOfConsumers; ++r) {
            let strActivLoad = columnScroll_1.children[r].textField
            let strLengthSite = columnScroll_2.children[r].textField
            let strActivPowerCoef = columnScroll_3.children[r].textField
            if (strActivLoad === "" ||
                strActivPowerCoef === "" ||
                strLengthSite === "" ||
                (columnScroll_4.children[r].currentIndex === 0 && checkBox3.checkState === 0) ||
                    checkBox2.checkState && inputData.percentageLoss === "") {

                if(target === "for calculating") {
                    dialogWarning.title = "Заполнены не все поля!"
                    dialogWarning.visible = true
                }

                return 0
            } else {
                //Заполнение данных
                parameterCalculation.setVecActivLoad(parseFloat(strActivLoad))
                inputData.arrayActivePower.push(strActivLoad) //массив мощностей для отображения на схеме
                parameterCalculation.setVecLengthSite(parseFloat(strLengthSite))
                parameterCalculation.setActivPowerCoefficient(parseFloat(strActivPowerCoef))
            }
        }
        return 1
    }
    /*******************************************************************************************************/

    //Расчет параметров линии
    /*******************************************************************************************************/
    function calculateParametrs() {

        numberOfConsumers = columnScroll_1.children.length
        parameterCalculation.indexComboBoxConsum = comboBoxConsum.currentIndex

        let arrWire = columnScroll_4.children

        //Сброс данных
        /*******************************************************************************************/
        parameterCalculation.clearVectors()//обнуление векторов в классе C++
        clearData()
        parameterCalculation.fillingResistanceVectorPhaseZero()
        /*******************************************************************************************/

        if(!checkField("for calculating")) {
            return 0
        }

        inputData.arrayLengthSite = parameterCalculation.getVecLengthSite()//сохранение вектора длин участков в массив
                                                                           //для отображения на схеме

        //Расчет параметров
        /*******************************************************************************************/
        if(parameterCalculation.parameterCalculation(comboBoxConsum.currentIndex)) {
            let vectorSiteLoads = parameterCalculation.getVecSiteLoads()
            let vectorWeightedAverage = parameterCalculation.getVecWeightedAverage()
            let vectorFullPower = parameterCalculation.getVecFullPower()
            let vectorDesignCurrent = parameterCalculation.getVecDesignCurrent()

            let vectorDesignCurrentConsumer = parameterCalculation.getVecDesignCurrentConsumer()
            let sumDesignCurrentConsumer = vectorDesignCurrentConsumer.reduce((sum, current)=>sum + current, 0)
            inputData.sumDesignCurrentConsumer = sumDesignCurrentConsumer
            outData.sumDesignCurentConsumer = String(sumDesignCurrentConsumer.toFixed(inputData.toFixed))

            let vectorEquivalentPower = parameterCalculation.getVecEquivalentPower()
            let vectorEquivalentCurrent = parameterCalculation.getVecEquivalentCurrent()

            //Расчет параметров двигателя
            calculateEngin()
            //Расчет предохранителя
            calculateFuse()
            //Расчет теплового расцепителя
            calculateThermalRelease(0)
            //Расчет электромагнитного расцепителя
            calculateElectromagneticRelease(0)

            let vectorResistancePhaseZero = []
            let vectorVoltageLoss = []
            let vectorVoltageLossPercent = []
            let vectorVoltageLossSum = []
            let vectorVoltageLossSumPercent = []
            let vectorSinglePhaseShortCircuit = []
            let resistancePhaseZeroSum = 0

            if(!checkBox3.checkState) {
                //Расчет сопротивления петли фаза-ноль
                /******************************************************************************************/

                for(let x = 0; x < numberOfConsumers; ++x) {
                    parameterCalculation.calculateResistancePhaseZero(arrWire[x].currentIndex, x)
                    vectorResistancePhaseZero.push(parameterCalculation.resistancePhaseZero)
                }
                resistancePhaseZeroSum = vectorResistancePhaseZero.reduce((sum, current) => sum + current, 0)
                outData.resistancePhaseZeroSum = String(resistancePhaseZeroSum.toFixed(inputData.toFixed))
                /******************************************************************************************/

                //Расчет однофазного КЗ
                inputData.arrSinglePhaseShortCircuit = []
                vectorSinglePhaseShortCircuit = inputData.arrSinglePhaseShortCircuit = calculateSinglePhaseShortCircuit()

                //Расчет потерь напряжения и добавление точек на график потерь напряжения
                calculateVoltageLoss(vectorVoltageLoss, vectorVoltageLossPercent,
                                     vectorVoltageLossSum, vectorVoltageLossSumPercent)
            }

            //Построение строк в окне вывода данных
            loadOutputLine(vectorSiteLoads,
                           vectorWeightedAverage,
                           vectorFullPower,
                           vectorEquivalentPower,
                           vectorEquivalentCurrent,
                           vectorDesignCurrent,
                           vectorDesignCurrentConsumer,
                           vectorResistancePhaseZero,
                           vectorVoltageLoss,
                           vectorVoltageLossPercent,
                           vectorVoltageLossSum,
                           vectorVoltageLossSumPercent,
                           vectorSinglePhaseShortCircuit)

        }

        return 1
        /*******************************************************************************************/
    }
    /*******************************************************************************************************/

    //Расчет параметров двигателя
    /*******************************************************************************************************/
    function calculateEngin() {
        let enginePower = Number(textFieldEnginePower.text)
        let efficiencyFactor = Number(textFieldEfficiencyFactor.text)
        let engineCos = Number(textFieldEngineCos.text)
        let startingCurrentRatio = Number(textFieldStartingCurrentRatio.text)
        inputData.startingCurrentRatio = startingCurrentRatio
        let engineType = Number(comboBoxEngineType.currentIndex)

        switch(engineType) {
        case 0: engineType = 2.5
            break
        case 1: engineType = 1.6
            break
        case 2: engineType = 0.9
            break
        default: engineType = 0
        }

        inputData.engineType = engineType

        if(enginePower && efficiencyFactor && engineCos && startingCurrentRatio) {
            let ratedEngineCurrent = enginePower / (Math.sqrt(3) * engineCos * 0.38 * efficiencyFactor)
            inputData.ratedEngineCurrent = ratedEngineCurrent
            outData.ratedEngineCurrent = String(ratedEngineCurrent.toFixed(inputData.toFixed))
            let startingCurrent = startingCurrentRatio * ratedEngineCurrent
            inputData.startingCurrent = startingCurrent
            outData.startingCurrent = String(startingCurrent.toFixed(inputData.toFixed))
            calculateFuse()
            calculateThermalRelease(0)
            calculateElectromagneticRelease(0)
        }
    }
    /*******************************************************************************************************/

    //Расчет предохранителя
    /*******************************************************************************************************/
    function calculateFuse() {

        let k = numberOfConsumers >= 3 ? 0.9 : 1
        let temp
        if(inputData.engineType) {
            temp = k * inputData.sumDesignCurrentConsumer + inputData.startingCurrent / inputData.engineType
        } else {
            temp = k * inputData.sumDesignCurrentConsumer
        }

        let arrayRatedCurrentFuse = [2, 4, 6.3, 10, 16, 20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160,
                                     200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500]

        //let fuseRatingTemp = inputData.sumDesignCurrentConsumer >= temp ? inputData.sumDesignCurrentConsumer : temp
        let fuseRating = 0

        for(let i = 0; i < arrayRatedCurrentFuse.length - 1; ++i) {
            if((temp > arrayRatedCurrentFuse[i]) && (temp <= arrayRatedCurrentFuse[i + 1])) {
                fuseRating = arrayRatedCurrentFuse[i + 1]
            }
        }

        if(!fuseRating) {
            dialogWarning.title = "Превышен максимальный номинал предохранителя!"
            dialogWarning.visible = true
        }

        outData.fuseRating = String(fuseRating.toFixed(inputData.toFixed))
    }
    /*******************************************************************************************************/

    //Расчет теплового расцепителя
    /*******************************************************************************************************/
    function calculateThermalRelease(siteNumberRelease) {
        let arrThermalRelease = [0, 1, 2, 4, 5, 6, 8, 10, 13, 16, 20, 25, 32, 35, 40, 50, 63, 80, 100, 125, 160
                                 , 180, 200, 225, 250, 320, 400, 500, 630, 800, 1000, 1600, 2500, 4000, 6300]

        let arrDesignCurrent = parameterCalculation.getVecDesignCurrent()
        let designSiteCurrent = arrDesignCurrent[siteNumberRelease]
        let designCurrentRatingTemp =
            1.1 * (designSiteCurrent - inputData.ratedEngineCurrent + 0.4 * inputData.startingCurrent)
        let designCurrentRating = 0
        for(let n = 0; n < arrThermalRelease.length - 1; ++n) {
            if((designCurrentRatingTemp > arrThermalRelease[n]) && (designCurrentRatingTemp <= arrThermalRelease[n + 1])) {
                designCurrentRating = arrThermalRelease[n + 1]
            }
        }

        if(!designCurrentRating) {
            dialogWarning.title = "Превышен максимальный номинал теплового расцепителя!"
            dialogWarning.visible = true
        }

        if(siteNumber === 0) {
            inputData.thermalRelease = designCurrentRating
            outData.thermalRelease = String(designCurrentRating.toFixed(inputData.toFixed))
        }

        return designCurrentRating
    }
    /*******************************************************************************************************/

    //Расчет электромагнитного расцепителя
    /*******************************************************************************************************/
    function calculateElectromagneticRelease(siteNumberRelease) {
        let arrThermalRelease = [1, 2, 4, 5, 6, 8, 10, 13, 16, 20, 25, 32, 35, 40, 50, 63, 80, 100, 125, 160
                                 , 180, 200, 225, 250, 320, 400, 500, 630, 800, 1000, 1600, 2500, 4000, 6300]
        let arrDesignCurrent = parameterCalculation.getVecDesignCurrent()
        let designSiteCurrent = arrDesignCurrent[siteNumberRelease]
        let designCurrentRatingTemp =
            1.2 * (designSiteCurrent + inputData.startingCurrent)
        let designCurrentRating = 0
        for(let n = 0; n < arrThermalRelease.length - 1; ++n) {
            if((designCurrentRatingTemp > arrThermalRelease[n]) && (designCurrentRatingTemp <= arrThermalRelease[n + 1])) {
                designCurrentRating = arrThermalRelease[n + 1]
            }
        }

        if(!designCurrentRating) {
            dialogWarning.title = "Превышен максимальный номинал электромагнитного расцепителя расцепителя!"
            dialogWarning.visible = true
        }

        if(siteNumber === 0) {
            outData.electromagneticRelease = String(designCurrentRating.toFixed(inputData.toFixed))

        }

        return designCurrentRating
    }
    /*******************************************************************************************************/

    //Поиск участка, на котором расположен СП по расстоянию до него
    /*******************************************************************************************************/
    function findSite(length) {
        let arrayLength = parameterCalculation.getVecLengthSite()
        let arrayLengthSum = []

        let sum = 0
        for(let item of arrayLength) {
            sum = sum + item
            arrayLengthSum.push(sum)
        }

        for(let i = 0; i < arrayLengthSum.length; ++i) {
            if(length <= arrayLengthSum[i]) {
                return (i)
            }
        }
    }
    /*******************************************************************************************************/

    //Расчет секционирующих пунктов
    /*******************************************************************************************************/
    function calculateRecloser() {

        inputData.arrSinglePhaseShortCircuit = parameterCalculation.getVecSinglePhaseShortCircuit()

        let sensitivityCondition = (arrSinglePhaseShortCircuit[inputData.numberOfConsumers - 1] / 3 >=
            outData.thermalRelease) ? true : false

        let arraySiteLength = parameterCalculation.getVecLengthSite()

        let arraySiteLengthSum = []
        let sum = 0
        for(let item of arraySiteLength) {
            sum = sum + item
            arraySiteLengthSum.push(sum)
        }

        let activeResistanceSum = 0
        let reactanceSum = 0

        //Расчет средних удельных значений активного и реактивного сопротивлений для всей линии
        for(let t = 0; t < numberOfConsumers; ++t) {
            let arrResistance = parameterCalculation.getResistancePhaseZero(columnScroll_4.children[t].currentIndex)
            activeResistanceSum += ( (arrResistance[0] + arrResistance[1]) * arraySiteLength[t] )
            reactanceSum = +(arrResistance[2] + arrResistance[3]) * arraySiteLength[t]
        }

        activeResistanceSum /= arraySiteLengthSum[inputData.numberOfConsumers - 1]
        reactanceSum /= arraySiteLengthSum[inputData.numberOfConsumers - 1]

        let flag = false
        let tr = 0 //переменная для сохранения номинала теплового расцепителя для последнего СП

        if(!sensitivityCondition) {

            function internalFunction() {

                let thermalRelease = calculateThermalRelease(inputData.siteNumber)

                let sensitivityConditionLength = parameterCalculation.calculationRecloser(
                                                         root.componentTransformApp.transformerResistance,
                                                         activeResistanceSum,
                                                         reactanceSum,
                                                         thermalRelease)

                sensitivityConditionLength = Math.abs(sensitivityConditionLength)

                if((inputData.sensitivityConditionLength + sensitivityConditionLength)
                        <= arraySiteLengthSum[inputData.siteNumber]) {

                    if(switchRecloser.checked) {
                        flag = oneIterationOfSectionRecalculation()
                    }

                    if(flag) {                                //перерасчет сечения
                        inputData.siteNumber = 0              //обнуление номера участка
                        inputData.arrayRecloserLength = []    //обнуление массива расстояний до СП
                        calculateParametrs()                  //расчет параметров
                        internalFunction()                    //расчет СП
                    } else {
                        dialogWarning.title = "Невозможно соблюсти условие чувствительности!"
                        dialogWarning.visible = true

                        return
                    }

                } else {
                    //Расчет следующего СП

                    if((inputData.sensitivityConditionLength + sensitivityConditionLength) < arraySiteLengthSum[arraySiteLengthSum.length - 1]) {

                        inputData.sensitivityConditionLength += sensitivityConditionLength

                        inputData.arrayRecloserLength.push(inputData.sensitivityConditionLength) //добавление в массив длин СП

                        ++inputData.numberOfReclosers //запись количества СП

                        inputData.siteNumber = findSite(inputData.sensitivityConditionLength)

                        internalFunction()

                    } else {

                        if(inputData.arrayRecloserLength.length != 0) {

                            for(let elem = 0; elem < inputData.arrayRecloserLength.length; ++elem) {
                                //Определение участка, на котором будет СП
                                let siteNumber = findSite(inputData.arrayRecloserLength[elem])

                                //Рассчет для каждого СП параметров защиты
                                let thermalRelease = calculateThermalRelease(siteNumber).toFixed(inputData.toFixed)
                                tr = thermalRelease
                                let electricalRelease = calculateElectromagneticRelease(siteNumber).toFixed(inputData.toFixed)

                                componentRecloser.createObject(outData.columnScrollOutput_10, {
                                                               "text": "№" + (elem + 1),
                                                               "length": inputData.arrayRecloserLength[elem].toFixed(inputData.toFixed),
                                                               "thermalRelease": thermalRelease,
                                                               "electricalRelease": electricalRelease,
                                                               "siteNumber": siteNumber + 1
                                                           })
                            }

                            if(Number(tr) <= inputData.arrSinglePhaseShortCircuit[inputData.numberOfConsumers - 1] / 3) {

                                return

                            } else {

                                if(switchRecloser.checked) {

                                    if(oneIterationOfSectionRecalculation()) {      //перерасчет сечения
                                        inputData.siteNumber = 0                    //обнуление номера участка
                                        inputData.arrayRecloserLength = []          //обнуление массива расстояний до СП
                                        calculateParametrs()                        //расчет параметров
                                        internalFunction()                          //расчет СП
                                    } else {
                                        dialogWarning.title = "Невозможно соблюсти условие чувствительности!"
                                        dialogWarning.visible = true

                                        return
                                    }

                                } else {
                                    dialogWarning.title = "Невозможно соблюсти условие чувствительности!"
                                    dialogWarning.visible = true

                                    return
                                }


                            }

                        } else {
                            dialogWarning.title = "Установка СП не требуется!"
                            dialogWarning.visible = true

                            return
                        }
                    }
                }
            }

            internalFunction()

        } else {
            //Сообщение, что расчет не требуется
            dialogWarning.title = "Установка СП не требуется!"
            dialogWarning.visible = true

            return
        }
     }
    /*******************************************************************************************************/

    //Уточнение результата расчета сечения
    /*******************************************************************************************************/
    function refineLosses() {

        if(!inputData.needRecalculate) {
            return
        }

        let hasBeenIncreased = false
        for(let g = numberOfConsumers - 1; g >= 0; --g) {
            if(columnScroll_4.children[g].currentIndex > 1) {
                columnScroll_4.children[g].currentIndex -= 1
                calculateParametrs()
                let maxLoss =
                    Number(
                        outData.columnScrollOutput_4_2.children[outData.columnScrollOutput_4_2.children.length - 1].textField
                        )
                if(maxLoss > Number(inputData.percentageLoss)) {
                    columnScroll_4.children[g].currentIndex += 1
                    calculateParametrs()
                    break
                } else {
                    hasBeenIncreased = true
                }
            }
        }

        //Если в цикле ни в одном проходе не было увеличено сечение участка, то выходим из рекурсии
        if(!hasBeenIncreased) {
            return
        }

        refineLosses()
    }
    /*******************************************************************************************************/

    //Одна итерация перерасчета сечения
    /*******************************************************************************************************/
    function oneIterationOfSectionRecalculation() {

        //Находим участок с максимальными потерями
        let maxLoss = 0
        let numberSiteMaxLoss = 0
        for(let i = 0; i < numberOfConsumers; ++i) {
            if(Number(outData.columnScrollOutput_4_0.children[i].textField) > maxLoss) {
                maxLoss = Number(outData.columnScrollOutput_4_0.children[i].textField)
                numberSiteMaxLoss = i
            }
        }

        // При первом входе в функцию перерасчета сечений скидываем сечения после участка с максимальными
        // потерями в минимальные значения
        if(inputData.isFirstSession) {
            for(let n = numberSiteMaxLoss + 1; n < numberOfConsumers; ++n) {
                columnScroll_4.children[n].currentIndex = 1;
            }
            inputData.isFirstSession = false
        }

        //Поднимаем сечения до участка с наибольшими потерями до сечения равного этому участку
        let state = false //переменная указывает были ли изменено сечение хотя бы на одном участке
        for(let x = 0; x < numberSiteMaxLoss; ++x) {
            if(columnScroll_4.children[x].currentIndex < columnScroll_4.children[numberSiteMaxLoss].currentIndex) {
                 columnScroll_4.children[x].currentIndex = columnScroll_4.children[numberSiteMaxLoss].currentIndex
                state = true
            }
        }

        // Если сечения не были изменены, то поднимаем наименьшее сечение участка с наибольшим индексом, но не выше
        // сечения первого участка
        let minSection = 100
        let numberSiteMinSection = 0
        if(!state) {
            //Находим минимальное сечение и номер участка с этим сечением
            for(let y = 0; y < numberSiteMaxLoss; ++y) {
                if(columnScroll_4.children[y].currentIndex < minSection) {
                    minSection = columnScroll_4.children[y].currentIndex
                    numberSiteMinSection = y
                }
            }
            if((columnScroll_4.children[numberSiteMinSection].currentIndex + 1)
                    < columnScroll_4.children[0].currentIndex
                    && columnScroll_4.children[numberSiteMinSection].currentIndex < 10) {
                columnScroll_4.children[numberSiteMinSection].currentIndex += 1
                state = true
            }
        }

        // Если до участка с макс. потерями все сечения выровнены по этому участку, то поднимаем сечения участков за
        // ним, но не более сечения этого участка
        minSection = 100
        numberSiteMinSection = 0
        if(!state) {
            //Находим минимальное сечение и номер участка с этим сечением
            for(let t = numberSiteMaxLoss + 1; t < numberOfConsumers; ++t) {
                if(columnScroll_4.children[t].currentIndex < minSection) {
                    minSection = columnScroll_4.children[t].currentIndex
                    numberSiteMinSection = t
                }
            }
            if((columnScroll_4.children[numberSiteMinSection].currentIndex + 1)
                    < columnScroll_4.children[numberSiteMaxLoss].currentIndex
                    && columnScroll_4.children[numberSiteMinSection].currentIndex < 10) {
                columnScroll_4.children[numberSiteMinSection].currentIndex += 1
                state = true
            }
        }

        // Если все сечения до и после участка с максимальными потерями выровнены по нему,
        // то поднимаем сечения на всей линии
        minSection = 100
        numberSiteMinSection = 0
        if(!state) {
            for(let f = 0; f < numberOfConsumers; ++f) {
                if(columnScroll_4.children[f].currentIndex < minSection) {
                    minSection = columnScroll_4.children[f].currentIndex
                    numberSiteMinSection = f
                }
            }
            if(columnScroll_4.children[numberSiteMinSection].currentIndex < 10) {
                columnScroll_4.children[numberSiteMinSection].currentIndex += 1
            } else {
                return 0
            }
        }

        return 1
    }
    /*******************************************************************************************************/

    //Перерасчет сечений
    /*******************************************************************************************************/
    function recalculateSection() {

        //Суммарные потери на последнем участке
        let maxVoltageLossPercent =
            outData.columnScrollOutput_4_2.children[outData.columnScrollOutput_4_2.children.length - 1].textField

        if(Number(maxVoltageLossPercent) > Number(inputData.percentageLoss)) {

            if(oneIterationOfSectionRecalculation()) {
                //Перерасчет параметров линии
                calculateParametrs()
                recalculateSection()
                inputData.needRecalculate = true
            } else {
                dialogWarning.title = "Достигнуто максимально возможное сечение провода!"
                dialogWarning.visible = true
                return
            }
        } else {
            if(inputData.isFirstSession) {
                dialogWarning.title = "Не требуется перерасчет сечения!"
                dialogWarning.visible = true
                inputData.needRecalculate = false
            }
        }
    }
    /*******************************************************************************************************/

    //Расчет сопротивления петли фаза-ноль
    /*******************************************************************************************************/
    function  calculateSinglePhaseShortCircuit() {
        parameterCalculation.calculationSinglePhaseShortCircuit(
                    root.componentTransformApp.transformerResistance) //расчет однофазного КЗ
        let vecSinglePhaseShortCircuit = parameterCalculation.getVecSinglePhaseShortCircuit() //запись в вектор

        return vecSinglePhaseShortCircuit
    }
    /*******************************************************************************************************/

    //Расчет потерь напряжения и добавление точек на график потерь напряжения
    /*******************************************************************************************************/
    function calculateVoltageLoss(vectorVoltageLoss, vectorVoltageLossPercent,
                                  vectorVoltageLossSum, vectorVoltageLossSumPercent) {
        chartComp.lineSeries.append(0, 0)

        let maxValue
        let sumVoltageLoss = 0
        for (let y = 0; y < numberOfConsumers; ++y) {
            let voltageLoss = parameterCalculation.calculationVoltageLoss(columnScroll_4.children[y].currentIndex, y)
            vectorVoltageLoss.push(voltageLoss)
            sumVoltageLoss += voltageLoss
            vectorVoltageLossSum.push(sumVoltageLoss)
            vectorVoltageLossPercent.push(voltageLoss * 100 / 380)
            vectorVoltageLossSumPercent.push(sumVoltageLoss * 100 / 380)
            chartComp.lineSeries.append(y + 1, sumVoltageLoss)
        }
        maxValue = Math.max(...vectorVoltageLossSum)
        let axisY = Math.ceil(maxValue)

        let k = Math.ceil(axisY / 20)
        let tickY = Math.ceil(axisY / k)
        while(true) {
            if(axisY % tickY == 0) {
                break
            } else {
                axisY += 1
            }
        }
        tickY += 1

        chartComp.maxAxisY = axisY
        chartComp.tickCountY = tickY
    }
    /*******************************************************************************************************/

    //Очистка данных и полей
    /*******************************************************************************************************/
    function clearData() {

        for (let n = 0; n < outData.columnScrollOutput_1.children.length; ++n) {
            outData.columnScrollOutput_1.children[n].destroy()
            outData.columnScrollOutput_2.children[n].destroy()
            outData.columnScrollOutput_3.children[n].destroy()
            outData.columnScrollOutput_3_1.children[n].destroy()
            outData.columnScrollOutput_3_2.children[n].destroy()
            outData.columnScrollOutput_5.children[n].destroy()
            outData.columnScrollOutput_6.children[n].destroy()
            outData.columnScrollOutput_7.children[n].destroy()
            outData.columnScrollOutput_4.children[n].destroy()
            outData.columnScrollOutput_4_0.children[n].destroy()
            outData.columnScrollOutput_4_1.children[n].destroy()
            outData.columnScrollOutput_4_2.children[n].destroy()
            outData.columnScrollOutput_8.children[n].destroy()
            outData.columnScrollOutput_9.children[n].destroy()
        }

        for(let x = 0; x < outData.columnScrollOutput_10.children.length; ++x) {
            outData.columnScrollOutput_10.children[x].destroy()
        }

        outData.fuseRating = ""
        outData.sumDesignCurentConsumer = ""
        outData.thermalRelease = ""
        outData.electromagneticRelease = ""
        outData.resistancePhaseZeroSum = ""
        outData.ratedEngineCurrent = ""
        outData.startingCurrent = ""
        chartComp.lineSeries.clear()

        inputData.startingCurrentRatio = 0          //кратность пускового тока
        inputData.startingCurrent = 0               //пусковой ток
        inputData.engineType = 0                    //тип двигателя
        inputData.ratedEngineCurrent = 0            //номинальный ток электродвигателя

        inputData.arrayRecloserLength = []          //массив для сохранения расстояний до СП
        inputData.sensitivityConditionLength = 0    //расстояние до СП
        inputData.numberOfReclosers = 0             //количество СП
        inputData.siteNumber = 0                    //номер участка для СП
    }
    /*******************************************************************************************************/

    Drag.active: dragMouseArea.drag.active

    ParameterCalculation {
        id: parameterCalculation
    }

    //Компонент для динамического отображения данных СП
    /*******************************************************************************************************/
    Component {
        id: componentRecloser

        Column {

            topPadding: 10
            spacing: 10

            property alias text: componentLabelRecloser.text
            property alias length: componentTextFieldLength.text
            property alias thermalRelease: componentTextFieldThermalRelease.text
            property alias electricalRelease: componentTextFieldElectricalRelease.text
            property alias siteNumber:  componentTextFieldSiteNumber.text

            /***********************************************************************************************/
            Label {
                id: componentLabelRecloser
                anchors.horizontalCenter: parent.horizontalCenter
            }
            /***********************************************************************************************/

            /***********************************************************************************************/
            Row {

                /***********************************************************************************************/
                Column {

                    leftPadding: 10
                    spacing: 10

                    Label {
                        text: "Расстояние до СП"
                    }
                    Label {
                        text: "Номер участка"
                    }
                    Label {
                        text: "Тепловой расцепитель"
                    }
                    Label {
                        text: "Электромагнитный расцепитель"
                    }
                }
                /***********************************************************************************************/

                /***********************************************************************************************/
                Column {

                    leftPadding: 10
                    spacing: 5

                    TextField {
                        id: componentTextFieldLength
                        width: 70
                        placeholderText: "0"
                    }
                    TextField {
                        id: componentTextFieldSiteNumber
                        width: 70
                        placeholderText: "0"
                    }
                    TextField {
                        id: componentTextFieldThermalRelease
                        width: 70
                        placeholderText: "0"
                    }
                    TextField {
                        id: componentTextFieldElectricalRelease
                        width: 70
                        placeholderText: "0"
                    }   
                }
                /***********************************************************************************************/
            }
            /***********************************************************************************************/
        }
    }
    /*******************************************************************************************************/

    //Компонент для динамического отображения строк
    /*******************************************************************************************************/
    Component {
        id: componentLine

        Row {
            property alias text: componentLabelLine.text
            property alias textField: componentTextFieldLine.text
            property alias validator: componentTextFieldLine.validator
            property alias readOnly: componentTextFieldLine.readOnly

            leftPadding: 10
            spacing: 10
            topPadding: 10

            Label {
                id: componentLabelLine
            }

            TextField {
                id: componentTextFieldLine
                width: scrollView1.width - componentLabelLine.width - 45
                placeholderText: "0"
            }
        }
    }
    /*******************************************************************************************************/

    //Компонент для динамического отображения сечений проводов
    /*******************************************************************************************************/
    Component {
        id: componentWire

        Row {
            id: rowComboBoxWire
            property alias text: componentLabelWire.text
            property alias currentIndex: comboBoxWire.currentIndex

            leftPadding: 10
            spacing: 10
            topPadding: 10

            Label {
                id: componentLabelWire
            }

            ComboBox {
                id: comboBoxWire
                textRole: "name"
                Layout.leftMargin: 0
                width: scrollView1.width - componentLabelWire.width - 45

                onCurrentIndexChanged: {
                    if(checkBox3.checkState && checkBox3CheckState) {
                        currentIndex = 0
                    }
                }

                model: ListModel {

                    id: listModelComboWire

                    ListElement {
                        name: "неизвестно"
                        activResistancePhase: 0
                        activResistanceZero: 0
                        reactancePhase: 0
                        reactanceZero: 0
                        numberWire: -1
                    }

                    ListElement {
                        name: "3x16 + 1x25"
                        activResistancePhase: 2.448
                        activResistanceZero: 1.770
                        reactancePhase: 0.0865
                        reactanceZero: 0.0739
                        numberWire: 0
                    }
                    ListElement {
                        name: "3x25 + 1x35"
                        activResistancePhase: 2.448
                        activResistanceZero: 1.770
                        reactancePhase: 0.0865
                        reactanceZero: 0.0739
                        numberWire: 0
                    }
                    ListElement {
                        name: "3x35 + 1x50"
                        activResistancePhase: 2.448
                        activResistanceZero: 1.770
                        reactancePhase: 0.0865
                        reactanceZero: 0.0739
                        numberWire: 0
                    }
                    ListElement {
                        name: "3x50 + 1x70"
                        activResistancePhase: 2.448
                        activResistanceZero: 1.770
                        reactancePhase: 0.0865
                        reactanceZero: 0.0739
                        numberWire: 0
                    }
                    ListElement {
                        name: "3x70 + 1x95"
                        activResistancePhase: 2.448
                        activResistanceZero: 1.770
                        reactancePhase: 0.0865
                        reactanceZero: 0.0739
                        numberWire: 0
                    }
                    ListElement {
                        name: "3x95 + 1x95"
                        activResistancePhase: 2.448
                        activResistanceZero: 1.770
                        reactancePhase: 0.0865
                        reactanceZero: 0.0739
                        numberWire: 0
                    }
                    ListElement {
                        name: "3x120 + 1x95"
                        activResistancePhase: 2.448
                        activResistanceZero: 1.770
                        reactancePhase: 0.0865
                        reactanceZero: 0.0739
                        numberWire: 0
                    }
                    ListElement {
                        name: "3x150 + 1x95"
                        activResistancePhase: 2.448
                        activResistanceZero: 1.770
                        reactancePhase: 0.0865
                        reactanceZero: 0.0739
                        numberWire: 0
                    }
                    ListElement {
                        name: "3x185 + 1x95"
                        activResistancePhase: 2.448
                        activResistanceZero: 1.770
                        reactancePhase: 0.0865
                        reactanceZero: 0.0739
                        numberWire: 0
                    }
                    ListElement {
                        name: "3x240 + 1x95"
                        activResistancePhase: 2.448
                        activResistanceZero: 1.770
                        reactancePhase: 0.0865
                        reactanceZero: 0.0739
                        numberWire: 0
                    }
                }
            }
        }
    }

    /*******************************************************************************************************/

    //Компонент для динамического отображения строк для расчета экономического сечения
    /*******************************************************************************************************/
    Component {
        id: componentEconomicSection

        Column {
            id: columnEconomicSection
            leftPadding: 10
            spacing: 5
            topPadding: 10

            property alias text: labelEconomicSection.text
            property int sectionNumber: 0 //указывает номер участка
            property alias textEconomicSection: textFieldEconomicSection.text
            property alias enabled: columnEconomicSection.enabled

            Label {
                id: labelEconomicSection
            }

            Label {
                text: qsTr("Эконом. плотность тока")
            }

            TextField {
                id: textFieldEconomicCurrent
                width: 70
                placeholderText: "0"

                onAccepted: {

                    if(checkBox3.checkState) {
                        //Расчет экономического сечения
                        parameterCalculation.calculationEconomicSection(Number(textFieldEconomicCurrent.text),
                                                                        parent.sectionNumber)
                        let economicSection = parameterCalculation.economicSection
                        textFieldEconomicSection.text = economicSection

                        //Расчет стандартного сечения
                        let section = [0, 16, 25, 35, 50, 70, 95, 120, 150, 185, 240]
                        checkBox3CheckState = false
                        for (let n = 0; n < section.length - 1; ++n) {
                            if (economicSection > section[n]
                                    && economicSection <= section[n + 1]) {
                                columnScroll_4.children[sectionNumber].currentIndex = n + 1
                            } else if (economicSection > section[section.length - 1]) {
                                root.visibleDialogOver_240 = true
                            }
                        }

                        //Расчет сопротивления петли фаза-ноль
                        /******************************************************************************************/
                        parameterCalculation.calculateResistancePhaseZero(
                                columnScroll_4.children[sectionNumber].currentIndex, sectionNumber)
                        outData.columnScrollOutput_8.children[sectionNumber].textField = String(
                                    parameterCalculation.resistancePhaseZero.toFixed(inputData.toFixed))
                        inputData.vectorResistancePhaseZero.push(parameterCalculation.resistancePhaseZero)
                        /******************************************************************************************/

                        /******************************************************************************************/
                        if (parameterCalculation.checkResistanceVectorPhaseZero()) {//проверка, что заполнены все строки

                            //Очистка графика
                            chartComp.lineSeries.clear()

                            //Расчет полного сопротивления петли фаза-ноль
                            outData.resistancePhaseZeroSum =
                                    vectorResistancePhaseZero.reduce((sum, current) => sum + current, 0)

                            //Расчет однофазного КЗ
                            parameterCalculation.calculationSinglePhaseShortCircuit(
                                        root.componentTransformApp.transformerResistance)

                            //Запись в вектор
                            let vecSinglePhaseShortCircuit = parameterCalculation.getVecSinglePhaseShortCircuit()

                            for (let i = 0; i < numberOfConsumers; ++i) {
                                outData.columnScrollOutput_9.children[i].textField = String(
                                            vecSinglePhaseShortCircuit[i].toFixed(inputData.toFixed)) //заполнение строк
                            }

                            //Расчет потерь напряжения и добавление точек на график потерь напряжения
                            chartComp.lineSeries.append(0, 0)

                            let arrayVoltageLoss = []
                            let maxValue
                            let sumVoltageLoss = 0
                            for (let y = 0; y < numberOfConsumers; ++y) {
                                let voltageLoss = parameterCalculation.calculationVoltageLoss(
                                        columnScroll_4.children[y].currentIndex, y)
                                sumVoltageLoss += voltageLoss
                                arrayVoltageLoss.push(sumVoltageLoss)
                                outData.columnScrollOutput_4.children[y].textField = String(voltageLoss.toFixed(inputData.toFixed))
                                outData.columnScrollOutput_4_0.children[y].textField = String((voltageLoss * 100 / 380).toFixed(inputData.toFixed))
                                outData.columnScrollOutput_4_1.children[y].textField = String(sumVoltageLoss.toFixed(inputData.toFixed))
                                outData.columnScrollOutput_4_2.children[y].textField = String((sumVoltageLoss * 100 / 380).toFixed(inputData.toFixed))
                                chartComp.lineSeries.append(y + 1, sumVoltageLoss)
                            }
                            maxValue = Math.max(...arrayVoltageLoss)
                            let axisY = Math.ceil(maxValue)

                            let k = Math.ceil(axisY / 20)
                            let tickY = Math.ceil(axisY / k)
                            while(true) {
                                if(axisY % tickY == 0) {
                                    break
                                } else {
                                    axisY += 1
                                }
                            }
                            tickY += 1

                            chartComp.maxAxisY = axisY
                            chartComp.tickCountY = tickY
                            inputData.vectorResistancePhaseZero = []
                        }
                        /******************************************************************************************/
                    }
                }
            }

            Label {
                text: qsTr("Эконом. сечение")
            }

            TextField {
                id: textFieldEconomicSection
                placeholderText: "0"
                readOnly: true
            }
        }
    }

    /*******************************************************************************************************/

    //Функция для загрузки строк в колонки ввода данных
    /*******************************************************************************************************/
    function loadLine(string) {

        for (let n = columnScroll_1.children.length; n > 0; --n) {
            columnScroll_1.children[n - 1].destroy()
            columnScroll_2.children[n - 1].destroy()
            columnScroll_3.children[n - 1].destroy()
            columnScroll_4.children[n - 1].destroy()
        }

        let num = parseInt(string, 10)

        for (let i = 0; i < num; ++i) {
            let str = "№" + (i + 1)
            componentLine.createObject(columnScroll_1, {
                                           "text": str,
                                           "validator": comboBoxConsum.currentIndex? validatorOver2kW : validatorUpTo2kW
                                       })
            componentLine.createObject(columnScroll_2, {
                                           "text": str,
                                           "validator": validatorLength
                                       })
            componentLine.createObject(columnScroll_3, {
                                           "text": str,
                                           "validator": validatorCos
                                       })
            componentWire.createObject(columnScroll_4, {"text": str})
        }
    }
    /*******************************************************************************************************/

    //Функция для загрузки строк в колонки отображения результатов
    /*******************************************************************************************************/
    function loadOutputLine(vectorSiteLoads,
                            vectorWeightedAverage,
                            vectorFullPower,
                            vectorEquivalentPower,
                            vectorEquivalentCurrent,
                            vectorDesignCurrent,
                            vectorDesignCurrentConsumer,
                            vectorResistancePhaseZero,
                            vectorVoltageLoss,
                            vectorVoltageLossPercent,
                            vectorVoltageLossSum,
                            vectorVoltageLossSumPercent,
                            vectorSinglePhaseShortCircuit) {

        for (let i = 0; i < numberOfConsumers; ++i) {
            let str = "№" + (i + 1)
            componentLine.createObject(outData.columnScrollOutput_1, {
                                           "text": str,
                                           "textField": vectorSiteLoads[i].toFixed(inputData.toFixed),
                                           "readOnly": true
                                       })
            componentLine.createObject(outData.columnScrollOutput_2, {
                                           "text": str,
                                           "textField": vectorFullPower[i].toFixed(inputData.toFixed),
                                           "readOnly": true
                                       })
            componentLine.createObject(outData.columnScrollOutput_3, {
                                           "text": str,
                                           "textField": vectorWeightedAverage[i].toFixed(inputData.toFixed),
                                           "readOnly": true
                                       })
            componentLine.createObject(outData.columnScrollOutput_3_1, {
                                           "text": str,
                                           "textField": vectorDesignCurrent[i].toFixed(inputData.toFixed),
                                           "readOnly": true
                                       })
            componentLine.createObject(outData.columnScrollOutput_3_2, {
                                           "text": str,
                                           "textField": vectorDesignCurrentConsumer[i].toFixed(inputData.toFixed),
                                           "readOnly": true
                                       })

            componentLine.createObject(outData.columnScrollOutput_5, {
                                           "text": str,
                                           "textField": vectorEquivalentPower[i].toFixed(inputData.toFixed),
                                           "readOnly": true
                                       })
            componentLine.createObject(outData.columnScrollOutput_6, {
                                           "text": str,
                                           "textField": vectorEquivalentCurrent[i].toFixed(inputData.toFixed),
                                           "readOnly": true
                                       })
            componentEconomicSection.createObject(outData.columnScrollOutput_7,
                                                  {
                                                      "text": str,
                                                      "sectionNumber": i,
                                                      "enabled": checkBox3.checkState
                                                  })

            function functionVoltageLoss(checkBoxState, number) {
                let objectComponent = {}
                if(checkBoxState) {
                    objectComponent.text = str
                    objectComponent.textField = ""
                } else {
                    objectComponent.text = str
                    objectComponent.textField = number.toFixed(inputData.toFixed)
                }
                return objectComponent
            }

            let objectComponent = functionVoltageLoss(checkBox3.checkState, vectorVoltageLoss[i])
            componentLine.createObject(outData.columnScrollOutput_4, objectComponent
                                           //"text": str,
                                           //"textField": vectorVoltageLoss[i]
                                       )

            objectComponent = {}
            objectComponent = functionVoltageLoss(checkBox3.checkState, vectorVoltageLossPercent[i])
            componentLine.createObject(outData.columnScrollOutput_4_0, objectComponent
                                           //"text": str,
                                           //"textField": vectorVoltageLossPercent[i]
                                       )

            objectComponent = {}
            objectComponent = functionVoltageLoss(checkBox3.checkState, vectorVoltageLossSum[i])
            componentLine.createObject(outData.columnScrollOutput_4_1, objectComponent
                                            //"text": str,
                                            //"textField": vectorVoltageLossSum[i]
                                       )

            objectComponent = {}
            objectComponent = functionVoltageLoss(checkBox3.checkState, vectorVoltageLossSumPercent[i])
            componentLine.createObject(outData.columnScrollOutput_4_2, objectComponent
                                           //"text": str,
                                           //"textField": vectorVoltageLossSumPercent[i]
                                       )

            objectComponent = {}
            objectComponent = functionVoltageLoss(checkBox3.checkState, vectorResistancePhaseZero[i])
            componentLine.createObject(outData.columnScrollOutput_8, objectComponent
                                           //"text": str,
                                           //"textField": vectorResistancePhaseZero[i]
                                       )

            objectComponent = {}
            objectComponent = functionVoltageLoss(checkBox3.checkState, vectorSinglePhaseShortCircuit[i])
            componentLine.createObject(outData.columnScrollOutput_9, objectComponent
                                           //"text": str,
                                           //"textField": vectorSinglePhaseShortCircuit[i]
                                       )
        }
    }

    /*******************************************************************************************************/
    Rectangle {
        id: rectangleInputData
        anchors.fill: parent
        color: "#ffffff"
        radius: 5
        border.color: "#d1d1d1"
        border.width: 2

        property bool activeFocusOnWindow: {inpData.z > chartComp.z &&
                                            inpData.z > outData.z &&
                                            inpData.z > canvCard.z}


        Flickable {
            id: scrollView

            clip: true
            contentHeight: 640
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 20
            anchors.topMargin: 7
            anchors.bottomMargin: 7

            ScrollBar.vertical: ScrollBar {
                parent: scrollView.parent
                anchors.left: scrollView.right
                anchors.top: scrollView.top
                anchors.bottom: scrollView.bottom
                contentItem.opacity: 1
            }

            MouseArea {
                id: dragMouseArea
                anchors.fill: parent
                drag {
                    target: inputData
                    minimumX: 0
                    minimumY: 0
                    maximumX: backgroundRectangle.width - inputData.width
                    maximumY: backgroundRectangle.height - inputData.height
                }
                onContainsMouseChanged: {
                    inpData.z = outData.z + chartComp.z + canvCard.z + 1
                }

                onDoubleClicked: {
                    if(rectangleInputData.height == backgroundRectangle.height) {
                        inputData.height = inputData.inputDataHeigth
                        inputData.y = inputData.inputDataY
                    } else {
                        inputData.inputDataX = inputData.x
                        inputData.inputDataY = inputData.y
                        inputData.inputDataHeigth = inputData.height
                        inputData.height = backgroundRectangle.height
                        inputData.y = 0
                    }
                }
            }

            Label {
                id: labelNameWindow
                anchors.left: parent.left
                anchors.leftMargin: 338.5 - labelNameWindow.width / 2
                anchors.topMargin: 10
                text: qsTr("Исходные данные")
                font.family: "Arial"
                font.bold: true
                font.pointSize: 20
            }

            //Блок "Линия"
            /**********************************************************************************************************/
            Item {
                id: itemLine
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: 110
                anchors.topMargin: 5
                anchors.leftMargin: 170

                Frame {
                    id: frameLine
                    width: 322
                    height: 122
                    anchors.centerIn: parent
                }

                Label {
                    id: labelLine
                    anchors.top: frameLine.top
                    anchors.horizontalCenter: frameLine.horizontalCenter
                    text: qsTr("Линия")
                    font.pointSize: 14
                    font.bold: true
                }


                Label {
                    id: labelNumberConsumer
                    anchors.left: frameLine.left
                    anchors.top: labelLine.bottom
                    anchors.topMargin: 5
                    anchors.leftMargin: 5
                    text: qsTr("Количество потребителей")
                    font.family: "Arial"
                    font.pointSize: 10
                }

                //Ось X для графика
                Component {
                    id: componentCategoryRange
                    CategoryRange {

                    }
                }

                TextField {
                    id: textFieldNumberConsumer
                    anchors.left: labelNumberConsumer.right
                    anchors.verticalCenter: labelNumberConsumer.verticalCenter
                    anchors.leftMargin: 20
                    layer.enabled: false
                    placeholderText: qsTr("0")
                    validator: RegularExpressionValidator {
                        regularExpression: /([1-9]{1,2})|([0]{1})|([1-9]{1}[0]{0,1})/
                    }

                    onAccepted: {
                        parameterCalculation.numberOfConsumers = displayText
                        parameterCalculation.clearVectors()//обнуление векторов в классе C++
                        clearData()
                        loadLine(displayText)

                        for(let i = 1; i <= 10; ++i) {
                            chartComp.categoryAxis.remove(String(i))
                        }

                        chartComp.maxAxisX = numberOfConsumers

                        for(let f = 1; f <= numberOfConsumers; ++f) {
                            chartComp.categoryAxis.append(String(f), f)
                        }

                        parameterCalculation.fillingResistanceVectorPhaseZero()
                        canvCard.canvas.requestPaint()
                    }
                }

                Label {
                    id: labelLoadType
                    anchors.top: labelNumberConsumer.bottom
                    anchors.horizontalCenter: frameLine.horizontalCenter
                    anchors.topMargin: 15
                    text: qsTr("Выбор типа нагрузки")
                    font.pointSize: 10
                    font.family: "Arial"
                }

                /**************************************************************************************/
                RegularExpressionValidator {
                    id: validatorUpTo2kW
                    regularExpression: /([1]{1}[.][0-9]{0,6})|([0-2]{1})|([0]{1}[.][0-9]{0,6})/
                }

                RegularExpressionValidator {
                    id: validatorOver2kW
                    regularExpression: /([1-9]{1,3}[0]{0,2}[.][0-9]{0,6})|([0]{0,1}[.][0-9]{0,6})/
                }

                RegularExpressionValidator {
                    id: validatorLength
                    regularExpression: /([1-9]{1,2}[0]{0,1}[.][0-9]{0,6})|([0]{0,1}[.][0-9]{0,6})/
                }

                RegularExpressionValidator {
                    id: validatorCos
                    regularExpression: /([0]{1}[.][0-9]{0,6})|([1]{1})/
                }

                /**************************************************************************************/

                ComboBox {
                    id: comboBoxConsum
                    anchors.top: labelLoadType.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: frameLine.horizontalCenter
                    width: 230
                    objectName: "comboBoxConsum"
                    textRole: ""
                    Layout.leftMargin: -50

                    model: ListModel {
                        id: listModelComboConsum
                        ListElement {
                            name: "Жилые дома с нагрузкой до 2кВт"
                        }
                        ListElement {
                            name: "Жилые дома с нагрузкой свыше 2кВт"
                        }
                        ListElement {
                            name: "Жилые дома с электоплитами"
                        }
                        ListElement {
                            name: "Производственные потребители"
                        }
                    }

                    delegate: ItemDelegate {
                        width: comboBoxConsum.width
                        Text {
                            text: modelData
                        }
                    }

                    onActivated: {
                        if(currentIndex == 0) {
                            for(let i = 0; i < numberOfConsumers; ++i) {
                                columnScroll_1.children[i].validator = validatorUpTo2kW
                            }
                        } else {
                            for(let x = 0; x < numberOfConsumers; ++x) {
                                columnScroll_1.children[x].validator = validatorOver2kW
                            }
                        }
                    }
                }
            }
            /**********************************************************************************************************/

            //Блок "Питающий трансформатор"
            /**********************************************************************************************************/
            Item {
                id: itemTransformer
                anchors.top: parent.top
                anchors.left: itemLine.right
                anchors.bottom: parent.verticalCenter
                anchors.leftMargin: 330
                anchors.topMargin: 5
                anchors.bottomMargin: 110

                Frame {
                    id: frame1
                    width: 309
                    height: 122
                    anchors.centerIn: parent

                    Label {
                        id: labelPowerTransformer
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Питающий трансформатор")
                        font.pointSize: 14
                        font.bold: true
                    }

                    GridLayout {
                        anchors.top: labelPowerTransformer.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        rows: 2
                        columns: 2

                        Label {
                            id: labelConnectionDiagram
                            text: qsTr("Схема соединения обмоток")
                        }

                        TextField {
                            id: textFieldConnectionDiagram
                            placeholderText: qsTr("Y/Y0")
                            Layout.maximumWidth: 80
                            readOnly: true
                        }

                        Label {
                            id: labelTransformerResistance
                            text: qsTr("Сопротивление трансформатора, Ом")
                        }

                        TextField {
                            id: textFieldTransformerResistance
                            placeholderText: qsTr("0")
                            Layout.maximumWidth: 80
                            readOnly: true
                        }

                        Label {
                            id: labelTransformerPower
                            text: qsTr("Мощность трансформатора, кВа")
                        }

                        TextField {
                            id: textFieldTransformerPower
                            placeholderText: qsTr("0")
                            Layout.maximumWidth: 80
                            readOnly: true
                        }
                    }
                }               
            }
            /**********************************************************************************************************/

            //Блок "Двигатель"
            /**********************************************************************************************************/
            Item {
                id: itemEngine
                anchors.top: itemLine.bottom
                anchors.left: parent.left
                anchors.leftMargin: 170
                anchors.bottom: parent.verticalCenter

                Frame {
                    id: frameEngine
                    width: 322
                    height: 170
                    anchors.centerIn: parent

                    Label {
                        id: labelEngine
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Двигатель")
                        font.pointSize: 14
                        font.bold: true
                    }

                    /*********************************************************/
                    Label {
                        id: labelEnginePower
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.top: labelEngine.bottom
                        anchors.topMargin: 10
                        text: qsTr("Мощность двигателя, кВт")
                    }

                    TextField {
                        id: textFieldEnginePower
                        anchors.right: parent.right
                        anchors.verticalCenter:labelEnginePower.verticalCenter
                        placeholderText: qsTr("0")
                    }

                    /*********************************************************/
                    Label {
                        id: labelEfficiencyFactor
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.top: labelEnginePower.bottom
                        anchors.topMargin: 10
                        text: qsTr("КПД двигателя в ед.")
                    }

                    TextField {
                        id: textFieldEfficiencyFactor
                        anchors.right: parent.right
                        anchors.verticalCenter: labelEfficiencyFactor.verticalCenter
                        placeholderText: qsTr("0")
                    }

                    /*********************************************************/
                    Label {
                        id: labelEngineCos
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.top: labelEfficiencyFactor.bottom
                        anchors.topMargin: 10
                        text: qsTr("Cos двигателя")
                    }

                    TextField {
                        id: textFieldEngineCos
                        anchors.right: parent.right
                        anchors.verticalCenter: labelEngineCos.verticalCenter
                        placeholderText: qsTr("0")
                    }

                    /*********************************************************/
                    Label {
                        id: labelStartingCurrentRatio
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.top: labelEngineCos.bottom
                        anchors.topMargin: 10
                        text: qsTr("Кратность пускового тока")
                    }

                    TextField {
                        id: textFieldStartingCurrentRatio
                        anchors.right: parent.right
                        anchors.verticalCenter: labelStartingCurrentRatio.verticalCenter
                        placeholderText: qsTr("0")
                    }

                    /*********************************************************/
                    Label {
                        id: labelEngineType
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.top: labelStartingCurrentRatio.bottom
                        anchors.topMargin: 10
                        text: qsTr("Тип двигателя")
                    }

                    ComboBox {
                        id: comboBoxEngineType
                        anchors.right: parent.right
                        anchors.verticalCenter: labelEngineType.verticalCenter
                        width: 220

                        model: [
                            qsTr("Короткозамкнутый ротор, до 5с"),
                            qsTr("Короткозамкнутый ротор, более 10с"),
                            qsTr("Фазный ротор")
                        ]

                        delegate: ItemDelegate {
                            width: comboBoxEngineType.width
                            Text {
                                text: modelData
                            }
                        }
                    }
                }
            }
            /**********************************************************************************************************/

            //Группа checkBox
            /**********************************************************************************************************/
            Item {
                id: itemCheckBox
                anchors.top: itemTransformer.bottom
                anchors.left: itemEngine.right
                anchors.bottom: parent.verticalCenter
                anchors.leftMargin: 330

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 15

                    /******************************************************************************************/
                    RowLayout {
                        spacing: 30
                        Layout.bottomMargin: -5

                        CheckBox {
                            id: checkBox1
                            text: qsTr("Расчет секционирующих пунктов")

                            onCheckStateChanged: {
                                if(checkBox1.checkState > 0) {
                                    checkBox2.checkState = 0
                                    checkBox3.checkState = 0
                                    textFieldCheckBox2.text = ""
                                    textFieldCheckBox2.enabled = false
                                    switchRecloser.enabled = true
                                }
                            }
                        }

                        ColumnLayout {

                            Layout.topMargin: -13

                            Text {
                                text: "Перерасчет сечения"
                                font.pointSize: 7
                                Layout.leftMargin: -10
                            }

                            Switch {
                                id: switchRecloser
                                enabled: false
                            }
                        }
                    }

                    /******************************************************************************************/

                    RowLayout {
                        spacing: 5

                        CheckBox {
                            id: checkBox2
                            text: qsTr("Расчет по максимальному отклонению")

                            onCheckStateChanged: {
                                if(checkBox2.checkState > 0) {
                                    checkBox1.checkState = 0
                                    checkBox3.checkState = 0
                                    textFieldCheckBox2.enabled = true
                                    switchRecloser.enabled = false
                                    switchRecloser.checked = false
                                }
                            }
                        }

                        Label {
                            text: "  "
                        }

                        TextField {
                            id: textFieldCheckBox2
                            Layout.maximumWidth: 30
                            placeholderText: qsTr("0")
                            enabled: false
                        }

                        Label {
                            text: "%"
                        }
                    }

                    /******************************************************************************************/

                    CheckBox {
                        id: checkBox3
                        //checkState: Qt.Checked
                        text: qsTr("Расчет по экономической плотности тока")
                        onCheckStateChanged: {
                            if(checkBox3.checkState > 0) {
                                checkBox2.checkState = 0
                                checkBox1.checkState = 0
                                textFieldCheckBox2.text = ""
                                textFieldCheckBox2.enabled = false
                                switchRecloser.enabled = false
                                switchRecloser.checked = false
                            }

                            //Сброс данных
                            /*******************************************************************************************/
                            if(checkState) {
                                //parameterCalculation.clearVectors()//обнуление векторов в классе C++
                                //clearData()

                                parameterCalculation.fillingResistanceVectorPhaseZero()

                                if(checkBox3.checkState) {
                                    for(let a = 0; a < columnScroll_4.children.length; ++a) {
                                        columnScroll_4.children[a].currentIndex = 0
                                    }
                                }
                            }
                            /*******************************************************************************************/
                            if(checkState) {
                                for(let j = 0; j < columnScroll_4.children.length; ++j) {
                                    columnScroll_4.children[j].currentIndex = 0
                                    checkBox3CheckState = true
                                }
                            } else {
                                checkBox3CheckState = false
                            }
                        }
                    }
                }
            }
            /**********************************************************************************************************/

            //Блок ввода данных
            /**********************************************************************************************************/
            Row {
                id: rowRect
                spacing: 5
                leftPadding: 10
                rightPadding: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 50

                //Активная нагрузка
                /*************************************************************************************************/
                Rectangle {
                    id: rectangleActivPower
                    width: 158
                    height: 200
                    color: "#e4e4e4"
                    radius: 5
                    border.color: "#e4e4e4"

                    Label {
                        id: label3
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 10
                        text: qsTr("Активная нагрузка, кВт")
                    }

                    ScrollView {
                        id: scrollView1
                        x: 0
                        y: 0
                        width: 158
                        height: 200

                        Column {
                            id: columnScroll_1
                        }
                    }
                }
                /*************************************************************************************************/

                //Длина участка
                /*************************************************************************************************/
                Rectangle {
                    id: rectangleLengthSite
                    width: 158
                    height: 200
                    color: "#e4e4e4"
                    radius: 5
                    border.color: "#e4e4e4"

                    Label {
                        id: label4
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 10
                        text: qsTr("Длина участка, км")
                    }

                    ScrollView {
                        id: scrollView2
                        x: 0
                        y: 0
                        width: 158
                        height: 200

                        Column {
                            id: columnScroll_2
                        }
                    }
                }
                /*************************************************************************************************/

                //Коэф. активной мощности
                /*************************************************************************************************/
                Rectangle {
                    id: rectangleCoefActivPower
                    width: 158
                    height: 200
                    color: "#e4e4e4"
                    radius: 5
                    border.color: "#e4e4e4"

                    Label {
                        id: label5
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 10
                        text: qsTr("Коэфф. активной мощности")
                    }

                    ScrollView {
                        id: scrollView3
                        x: 0
                        y: 0
                        width: 158
                        height: 200

                        Column {
                            id: columnScroll_3
                        }
                    }
                }
                /*************************************************************************************************/

                //Сечение провода
                /*************************************************************************************************/
                Rectangle {
                    id: rectangleWire
                    width: 158
                    height: 200
                    color: "#e4e4e4"
                    radius: 5
                    border.color: "#e4e4e4"

                    Label {
                        id: label6
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 10
                        textFormat: Text.RichText
                        text: qsTr("Сечение провода, мм <sup>2</sup>")
                    }

                    ScrollView {
                        id: scrollView4
                        x: 0
                        y: 0
                        width: 158
                        height: 200

                        Column {
                            id: columnScroll_4
                        }
                    }
                }
                /*************************************************************************************************/
            }

            //Кнопка "Рассчитать"
            /**********************************************************************************************************/
            Button {
                id: buttonEnter

                anchors.top: rowRect.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                width: 90
                text: qsTr("Рассчитать")
                font.bold: true

                onClicked: {

                    if(calculateParametrs()) {
                        //Перерасчет сечения по максимальному отклонению, если поставлен флаг в checkBox2
                        if(checkBox2.checkState) {
                            recalculateSection()
                            refineLosses()
                        }

                        //Рассчет расстояний до СП
                        if(checkBox1.checkState) {
                            calculateRecloser()
                        }

                        canvCard.canvas.requestPaint()
                    }                
                }
            }
            /**********************************************************************************************************/
        }

        //Нижняя область для изменения размера
        /**********************************************************************************************************/
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 7
            anchors.leftMargin: 7
            height: 5
            anchors.bottomMargin: 2

            MouseArea {
                id: bottomMouseScopeInp
                anchors.fill: parent
                cursorShape: rectangleInputData.activeFocusOnWindow ? Qt.SizeVerCursor : Qt.ArrowCursor
                property double clickPosBottom

                onPressed: {
                    if(rectangleInputData.activeFocusOnWindow) {
                        clickPosBottom = bottomMouseScopeInp.mouseY
                    }
                }

                onPositionChanged: {

                    if(rectangleInputData.activeFocusOnWindow) {

                        let delta = bottomMouseScopeInp.mouseY - clickPosBottom
                        if(delta > 0) {

                            if(delta < (backgroundRectangle.height - (inputData.height + inputData.y))) {
                                inputData.height += delta

                            } else {
                                delta = (backgroundRectangle.height - inputData.y) - inputData.height
                                inputData.height += delta
                            }

                        } else if(delta < 0) {

                            if((inputData.height + delta) > 360) {
                                inputData.height += delta
                            } else {
                                delta = 360 - inputData.height
                                inputData.height += delta
                            }
                        }
                    }
                }
            }
        }
        /**********************************************************************************************************/

        //Верхняя область для изменения размера
        /**********************************************************************************************************/
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 7
            anchors.leftMargin: 7
            height: 5
            anchors.topMargin: 2

            MouseArea {
                id: topMouseScopeInp
                anchors.fill: parent
                cursorShape: rectangleInputData.activeFocusOnWindow ? Qt.SizeVerCursor : Qt.ArrowCursor
                property double clickPosTop

                onPressed: {
                    if(rectangleInputData.activeFocusOnWindow) {
                        clickPosTop = topMouseScopeInp.mouseY
                    }
                }

                onPositionChanged: {
                    if(rectangleInputData.activeFocusOnWindow) {

                        let delta = topMouseScopeInp.mouseY - clickPosTop

                        if(delta > 0) {
                            if((inputData.height - delta) > 360) {
                                inputData.height -= delta
                                inputData.y += delta
                            } else {
                                delta = inputData.height - 360
                                inputData.height -= delta
                                inputData.y += delta
                            }
                        } else if(delta < 0) {
                            if(-delta < inputData.y) {
                                inputData.height -= delta
                                inputData.y += delta
                            } else {
                                delta = inputData.y
                                inputData.height += delta
                                inputData.y -= delta
                            }
                        }
                    }
                }
            }
        }
        /**********************************************************************************************************/
    }
}
