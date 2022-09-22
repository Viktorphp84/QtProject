import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import ParameterCalculation
import QtCharts

Item {
    id: inputData
    width: widthItem
    height: heightItem

    property int widthItem: 677
    property int heightItem: 360
    property var component

    property var parameterCalculation: parameterCalculation
    property alias numberOfConsumers: parameterCalculation.numberOfConsumers
    property alias transformerResistance: textFieldTransformerResistance.text
    property alias connectionDiagram: textFieldConnectionDiagram.text
    property alias transformerPower: textFieldTransformerPower.text
    property double sumDesignCurrentConsumer: 0
    property double startingCurrentRatio: 0
    property double engineType: 0
    property double startingCurrent: 0
    property int temp: 0 //переменная для сравнения текущего количества потребителей и введенного

    //Соединение с сигналов из класса C++ ParameterCalculation
    /*******************************************************************************************************/
    Connections {
        target: parameterCalculation
        function onSignalToQml() {
            dialogLoadOver_300.visible = true
        }
    }
    /*******************************************************************************************************/

    //Расчет параметров двигателя
    /*******************************************************************************************************/
    function engineCalculation() {
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
            outData.ratedEngineCurrent = String(ratedEngineCurrent)
            let startingCurrent = startingCurrentRatio * ratedEngineCurrent
            inputData.startingCurrent = startingCurrent
            outData.startingCurrent = String(startingCurrent)
            fuseCalculation()
        }
    }
    /*******************************************************************************************************/

    //Расчет предохранителя
    /*******************************************************************************************************/
    function fuseCalculation() {

        let k = numberOfConsumers >= 3 ? 0.9 : 1
        let temp
        if(inputData.engineType) {
            temp = k * inputData.sumDesignCurrentConsumer + inputData.startingCurrent / inputData.engineType
        } else {
            temp = k * inputData.sumDesignCurrentConsumer
        }

        let arrayRatedCurrentFuse = [2, 4, 6.3, 10, 16, 20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160,
                                     200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500]

        let fuseRatingTemp = inputData.sumDesignCurrentConsumer >= temp ? inputData.sumDesignCurrentConsumer : temp
        let fuseRating = 0

        for(let i = 0; i < arrayRatedCurrentFuse.length - 1; ++i) {
            if((fuseRatingTemp > arrayRatedCurrentFuse[i]) && (fuseRatingTemp <= arrayRatedCurrentFuse[i + 1])) {
                fuseRating = arrayRatedCurrentFuse[i + 1]
            }
        }

        if(!fuseRating) {
            dialogWarning.title = "Превышен максимальный номинал предохранителя!"
            dialogWarning.visible = true
        }

        outData.fuseRating = fuseRating
    }
    /*******************************************************************************************************/

    //Расчет секционирующих пунктов
    /*******************************************************************************************************/
    function calculationRecloser() {

    }
    /*******************************************************************************************************/

    //Расчет сопротивления петли фаза-ноль
    /*******************************************************************************************************/
    function  calculationSinglePhaseShortCircuit() {
        parameterCalculation.calculationSinglePhaseShortCircuit(
                    root.componentTransformApp.transformerResistance) //расчет однофазного КЗ
        let vecSinglePhaseShortCircuit = parameterCalculation.getVecSinglePhaseShortCircuit() //запись в вектор

        for (let g = 0; g < numberOfConsumers; ++g) {
            outData.columnScrollOutput_9.children[g].textField = String(
                        vecSinglePhaseShortCircuit[g]) //заполнение строк
        }
    }
    /*******************************************************************************************************/

    //Расчет потерь напряжения и добавление точек на график потерь напряжения
    /*******************************************************************************************************/
    function calculationVoltageLoss() {
        chartComp.lineSeries.append(0, 0)

        let arrayVoltageLoss = []
        let maxValue
        let sumVoltageLoss = 0
        for (let y = 0; y < numberOfConsumers; ++y) {
            let voltageLoss = parameterCalculation.calculationVoltageLoss(
                    columnScroll_4.children[y].currentIndex, y)
            sumVoltageLoss += voltageLoss
            arrayVoltageLoss.push(sumVoltageLoss)
            outData.columnScrollOutput_4.children[y].textField = String(voltageLoss)
            outData.columnScrollOutput_4_1.children[y].textField = String(sumVoltageLoss)
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
    }
    /*******************************************************************************************************/

    //Очистка данных и полей
    /*******************************************************************************************************/
    function dataCleaning() {

        for (let n = outData.columnScrollOutput_1.children.length; n > 0; --n) {
            outData.columnScrollOutput_1.children[n - 1].destroy()
            outData.columnScrollOutput_2.children[n - 1].destroy()
            outData.columnScrollOutput_3.children[n - 1].destroy()
            outData.columnScrollOutput_3_1.children[n - 1].destroy()
            outData.columnScrollOutput_3_2.children[n - 1].destroy()
            outData.columnScrollOutput_4.children[n - 1].destroy()
            outData.columnScrollOutput_4_1.children[n - 1].destroy()
            outData.columnScrollOutput_5.children[n - 1].destroy()
            outData.columnScrollOutput_6.children[n - 1].destroy()
            outData.columnScrollOutput_7.children[n - 1].destroy()
            if(temp != parameterCalculation.numberOfConsumers) {
                outData.columnScrollOutput_8.children[n - 1].destroy()
                outData.columnScrollOutput_9.children[n - 1].destroy()
            }
        }

        outData.fuseRating = ""
        outData.sumDesignCurentConsumer = ""
        chartComp.lineSeries.clear()
    }
    /*******************************************************************************************************/

    //signal signalEconomicSection(real economicSection)


    /*Connections {
        target: inputData
        function onSignalEconomicSection(economicSection) {
            parameterCalculation.setEconomicSection(economicSection)
            //parameterCalculation.getVecEconomicSection()
        }
    }*/
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 3
        verticalOffset: 3
        radius: 5
        color: "#80000000"
    }

    Drag.active: dragMouseArea.drag.active

    ParameterCalculation {
        id: parameterCalculation
    }

    //Диалог с предупреждением о превышении нагрузки
    /*******************************************************************************************************/
    Dialog {
        id: dialogLoadOver_300
        modal: true
        title: qsTr("Введена нагрузка более 300кВт!")
        closePolicy: Popup.CloseOnEscape
        palette.button: "#26972D"
        palette.window: "#67E46F"
        DialogButtonBox {
            anchors.centerIn: parent
            Layout.alignment: Qt.AlignHCenter
            standardButtons: DialogButtonBox.Ok
            onAccepted: {
                dialogLoadOver_300.visible = false
            }
        }

        parent: inputData
        anchors.centerIn: inputData
    }
    /*******************************************************************************************************/

    //Компонент для динамического отображения строк
    /*******************************************************************************************************/
    Component {
        id: componentLine

        Row {
            property alias text: componentLabelLine.text
            property alias textField: componentTextFieldLine.text

            leftPadding: 10
            spacing: 10
            topPadding: 10

            Label {
                id: componentLabelLine
            }
            TextField {
                id: componentTextFieldLine
                width: 110
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

                onAccepted: {
                    let number = listModelComboWire.get(
                            comboBoxWire.currentIndex)
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
            leftPadding: 10
            spacing: 5
            topPadding: 10

            property alias text: labelEconomicSection.text
            property int sectionNumber: 0 //указывает номер участка
            property alias textEconomicSection: textFieldEconomicSection.text

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
                        let resistancePhaseZero = parameterCalculation.calculationResistancePhaseZero(
                                columnScroll_4.children[sectionNumber].currentIndex, sectionNumber)
                        outData.columnScrollOutput_8.children[sectionNumber].textField = String(
                                    parameterCalculation.resistancePhaseZero)
                        /******************************************************************************************/

                        /******************************************************************************************/
                        if (parameterCalculation.checkResistanceVectorPhaseZero()) {//проверка, что заполнены все строки
                            parameterCalculation.calculationSinglePhaseShortCircuit(
                                        root.componentTransformApp.transformerResistance) //расчет однофазного КЗ
                            let vecSinglePhaseShortCircuit = parameterCalculation.getVecSinglePhaseShortCircuit() //запись в вектор

                            for (let i = 0; i < numberOfConsumers; ++i) {
                                outData.columnScrollOutput_9.children[i].textField = String(
                                            vecSinglePhaseShortCircuit[i]) //заполнение строк
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
                                outData.columnScrollOutput_4.children[y].textField = String(voltageLoss)
                                outData.columnScrollOutput_4_1.children[y].textField = String(sumVoltageLoss)
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
                        } else {

                            //выводим сообщение, что для расчета однофазных КЗ нужно ввести все значения экономической плотности
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
            }
        }
    }

    /*******************************************************************************************************/

    //Функция для загрузки строк в колонки ввода данных
    /*******************************************************************************************************/
    function loadLine(string) {
        let n
        for (n = columnScroll_1.children.length; n > 0; --n) {
            columnScroll_1.children[n - 1].destroy()
            columnScroll_2.children[n - 1].destroy()
            columnScroll_3.children[n - 1].destroy()
            columnScroll_4.children[n - 1].destroy()
        }

        let num = parseInt(string, 10)
        let i
        for (i = 0; i < num; ++i) {
            let str = "№" + (i + 1)
            componentLine.createObject(columnScroll_1, {"text": str})
            componentLine.createObject(columnScroll_2, {"text": str})
            componentLine.createObject(columnScroll_3, {"text": str})
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
                            vectorDesignCurrentConsumer) {

        for (let i = 0; i < numberOfConsumers; ++i) {
            let str = "№" + (i + 1)
            componentLine.createObject(outData.columnScrollOutput_1, {
                                           "text": str,
                                           "textField": vectorSiteLoads[i]
                                       })
            componentLine.createObject(outData.columnScrollOutput_2, {
                                           "text": str,
                                           "textField": vectorFullPower[i]
                                       })
            componentLine.createObject(outData.columnScrollOutput_3, {
                                           "text": str,
                                           "textField": vectorWeightedAverage[i]
                                       })
            componentLine.createObject(outData.columnScrollOutput_3_1, {
                                           "text": str,
                                           "textField": vectorDesignCurrent[i]
                                       })
            componentLine.createObject(outData.columnScrollOutput_3_2, {
                                           "text": str,
                                           "textField": vectorDesignCurrentConsumer[i]
                                       })
            componentLine.createObject(outData.columnScrollOutput_4, {
                                           "text": str
                                       })
            componentLine.createObject(outData.columnScrollOutput_4_1, {
                                            "text": str
                                       })
            componentLine.createObject(outData.columnScrollOutput_5, {
                                           "text": str,
                                           "textField": vectorEquivalentPower[i]
                                       })
            componentLine.createObject(outData.columnScrollOutput_6, {
                                           "text": str,
                                           "textField": vectorEquivalentCurrent[i]
                                       })
            componentEconomicSection.createObject(outData.columnScrollOutput_7,
                                                  {
                                                      "text": str,
                                                      "sectionNumber": i
                                                  })
            if(temp != parameterCalculation.numberOfConsumers) {

                componentLine.createObject(outData.columnScrollOutput_8, {"text": str})

                componentLine.createObject(outData.columnScrollOutput_9, {"text": str})
            }
        }
    }

    /*******************************************************************************************************/
    Rectangle {
        id: rectangle
        anchors.fill: parent
        //width: parent.width
        //height: parent.height
        color: "#ffffff"
        radius: 5
        border.color: "#d1d1d1"

        ScrollView {
            id: scrollView
            width: parent.width
            height: parent.height - 10
            visible: true
            clip: true
            hoverEnabled: true
            enabled: true
            contentHeight: 600
            anchors.centerIn: parent

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
            }

            Label {
                id: labelNameWindow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 10
                text: qsTr("Исходные данные")
                font.family: "Arial"
                font.bold: true
                font.pointSize: 20
            }

            //Блок ввода данных
            /**********************************************************************************************************/
            Row {
                id: rowRect
                spacing: 5
                leftPadding: 10
                rightPadding: 20
                anchors.bottom: buttonEnter.top
                anchors.left: parent.left
                anchors.right: parent.right
                bottomPadding: 10

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

            /**********************************************************************************************************/

            //Кнопка "Ввод"
            /**********************************************************************************************************/
            Button {
                id: buttonEnter

                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: 20
                width: 70
                height: 30
                text: qsTr("Ввод")

                onClicked: {

                    //Сброс данных
                    /*******************************************************************************************/

                    parameterCalculation.clearVectors()//обнуление векторов в классе C++
                    dataCleaning()

                    parameterCalculation.fillingResistanceVectorPhaseZero()
                    let arrWire = columnScroll_4.children
                    if(checkBox3.checkState) {
                        for(let j = 0; j < arrWire.length; ++j) {
                            arrWire[j].currentIndex = 0
                        }
                        for(let y = 0; y < numberOfConsumers; ++y) {
                            outData.columnScrollOutput_8.children[y].textField = ""
                            outData.columnScrollOutput_9.children[y].textField = ""
                        }
                    }
                    /*******************************************************************************************/

                    //Заполнение данных
                    /*******************************************************************************************/
                    numberOfConsumers = columnScroll_1.children.length
                    parameterCalculation.indexComboBoxConsum = comboBoxConsum.currentIndex

                    for (let i = 0; i < numberOfConsumers; ++i) {
                        let strActivLoad = columnScroll_1.children[i].textField
                        let strLengthSite = columnScroll_2.children[i].textField
                        let strActivPowerCoef = columnScroll_3.children[i].textField
                        if (strActivLoad === "" || strActivPowerCoef === ""
                                || strLengthSite === ""
                                || (arrWire[i].currentIndex === 0 && checkBox3.checkState === 0)) {
                            dialogWarning.visible = true
                            return
                        }

                        parameterCalculation.setVecActivLoad(parseFloat(
                                                                 strActivLoad))
                        parameterCalculation.setVecLengthSite(
                                    parseFloat(strLengthSite))
                        parameterCalculation.setActivPowerCoefficient(
                                    parseFloat(strActivPowerCoef))
                    }
                    /*******************************************************************************************/

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
                        outData.sumDesignCurentConsumer = String(sumDesignCurrentConsumer)

                        let vectorEquivalentPower = parameterCalculation.getVecEquivalentPower()
                        let vectorEquivalentCurrent = parameterCalculation.getVecEquivalentCurrent()

                        //Построение строк в окне вывода данных
                        loadOutputLine(vectorSiteLoads,
                                       vectorWeightedAverage,
                                       vectorFullPower,
                                       vectorEquivalentPower,
                                       vectorEquivalentCurrent,
                                       vectorDesignCurrent,
                                       vectorDesignCurrentConsumer)

                        //Расчет предохранителя
                        fuseCalculation()

                        if(!checkBox3.checkState) {
                            //Расчет сопротивления петли фаза-ноль
                            /******************************************************************************************/
                            for(let x = 0; x < numberOfConsumers; ++x) {
                                parameterCalculation.calculationResistancePhaseZero(
                                        arrWire[x].currentIndex, x)
                                outData.columnScrollOutput_8.children[x].textField = String(
                                            parameterCalculation.resistancePhaseZero)
                            }
                            /******************************************************************************************/

                            //Расчет однофазного КЗ
                            calculationSinglePhaseShortCircuit()

                            //Расчет потерь напряжения и добавление точек на график потерь напряжения
                            calculationVoltageLoss()
                            temp = parameterCalculation.numberOfConsumers
                        }
                    }
                    /*******************************************************************************************/
                }
            }

            //Диалог о незаполненных полях
            /**********************************************************************************************************/
            Dialog {
                id: dialogWarning
                modal: true
                title: qsTr("Заполнены не все поля!")
                closePolicy: Popup.CloseOnEscape
                palette.button: "#26972D"
                palette.window: "#67E46F"
                DialogButtonBox {
                    anchors.centerIn: parent
                    Layout.alignment: Qt.AlignHCenter
                    standardButtons: DialogButtonBox.Ok
                    onAccepted: {
                        dialogWarning.visible = false
                    }
                }

                parent: inputData
                anchors.centerIn: inputData
            }
            /**********************************************************************************************************/

            //Блок "Линия"
            /**********************************************************************************************************/
            Item {
                id: itemLine
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: 140
                anchors.topMargin: 35
                anchors.leftMargin: 15

                Frame {
                    id: frameLine
                    width: 322
                    height: 122
                    anchors.centerIn: parent
                }

                Label {
                    id: labelLine
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Линия")
                    font.pointSize: 14
                }


                Label {
                    id: labelNumberConsumer
                    anchors.left: parent.left
                    anchors.top: labelLine.bottom
                    anchors.topMargin: 5
                    anchors.leftMargin: 5
                    text: qsTr("Количество потребителей")
                    font.family: "Arial"
                    font.pointSize: 10
                }

                TextField {
                    id: textFieldNumberConsumer
                    anchors.left: labelNumberConsumer.right
                    anchors.verticalCenter: labelNumberConsumer.verticalCenter
                    anchors.leftMargin: 20
                    layer.enabled: false
                    placeholderText: qsTr("0")
                    onAccepted: {
                        parameterCalculation.numberOfConsumers = displayText
                        parameterCalculation.clearVectors()//обнуление векторов в классе C++
                        dataCleaning()
                        loadLine(displayText)

                        chartComp.maxAxisX = parameterCalculation.numberOfConsumers
                        chartComp.tickCountX = parameterCalculation.numberOfConsumers + 1
                        parameterCalculation.fillingResistanceVectorPhaseZero()
                    }
                }

                Label {
                    id: labelLoadType
                    anchors.top: labelNumberConsumer.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 15
                    text: qsTr("Выбор типа нагрузки")
                    font.pointSize: 10
                    font.family: "Arial"
                }

                ComboBox {
                    id: comboBoxConsum
                    anchors.top: labelLoadType.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
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
                }
            }
            /**********************************************************************************************************/

            //Блок "Питающий трансформатор"
            /**********************************************************************************************************/
            Item {
                id: item2
                anchors.top: parent.top
                anchors.left: itemLine.right
                anchors.right: parent.right
                anchors.bottom: parent.verticalCenter
                anchors.leftMargin: 15
                anchors.topMargin: 35
                anchors.bottomMargin: 140

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

                        /*ComboBox {
                            id: comboBox1

                            model: ListModel {
                                id: comboSchemeConnectModel

                                ListElement {
                                    name: "Y/Y0"
                                }
                                ListElement {
                                    name: "Y/Z0"
                                }
                                ListElement {
                                    name: "\u0394/Y0"
                                }
                            }
                        }*/

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
                id: item3
                anchors.top: itemLine.bottom
                anchors.left: parent.left
                anchors.right: parent.horizontalCenter
                anchors.bottom: rowRect.top
                anchors.leftMargin: 15
                anchors.topMargin: 20
                anchors.bottomMargin: 50

                Frame {
                    id: frame2
                    width: 322
                    height: 170
                    anchors.centerIn: parent
                }

                Label {
                    id: label17
                    anchors.top: parent.top
                    anchors.topMargin: -20
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Двигатель")
                    font.pointSize: 14
                }

                /*********************************************************/
                Label {
                    id: labelEnginePower
                    anchors.left: parent.left
                    anchors.top: label17.bottom
                    anchors.topMargin: 10
                    text: qsTr("Мощность двигателя, кВт")
                }

                TextField {
                    id: textFieldEnginePower
                    anchors.right: parent.right
                    anchors.verticalCenter:labelEnginePower.verticalCenter
                    anchors.rightMargin: 5
                    placeholderText: qsTr("0")

                    onTextEdited: {
                        engineCalculation()
                    }
                }

                /*********************************************************/
                Label {
                    id: labelEfficiencyFactor
                    anchors.left: parent.left
                    anchors.top: labelEnginePower.bottom
                    anchors.topMargin: 10
                    text: qsTr("КПД двигателя в ед.")
                }

                TextField {
                    id: textFieldEfficiencyFactor
                    anchors.right: parent.right
                    anchors.verticalCenter: labelEfficiencyFactor.verticalCenter
                    anchors.rightMargin: 5
                    placeholderText: qsTr("0")

                    onTextEdited: {
                        engineCalculation()
                    }
                }

                /*********************************************************/
                Label {
                    id: labelEngineCos
                    anchors.left: parent.left
                    anchors.top: labelEfficiencyFactor.bottom
                    anchors.topMargin: 10
                    text: qsTr("Cos двигателя")
                }

                TextField {
                    id: textFieldEngineCos
                    anchors.right: parent.right
                    anchors.verticalCenter: labelEngineCos.verticalCenter
                    anchors.rightMargin: 5
                    placeholderText: qsTr("0")

                    onTextEdited: {
                        engineCalculation()
                    }
                }

                /*********************************************************/
                Label {
                    id: labelStartingCurrentRatio
                    anchors.left: parent.left
                    anchors.top: labelEngineCos.bottom
                    anchors.topMargin: 10
                    text: qsTr("Кратность пускового тока")
                }

                TextField {
                    id: textFieldStartingCurrentRatio
                    anchors.right: parent.right
                    anchors.verticalCenter: labelStartingCurrentRatio.verticalCenter
                    anchors.rightMargin: 5
                    placeholderText: qsTr("0")

                    onTextEdited: {
                        engineCalculation()
                    }
                }

                /*********************************************************/
                Label {
                    id: labelEngineType
                    anchors.left: parent.left
                    anchors.top: labelStartingCurrentRatio.bottom
                    anchors.topMargin: 10
                    text: qsTr("Тип двигателя")
                }

                ComboBox {
                    id: comboBoxEngineType
                    anchors.right: parent.right
                    anchors.verticalCenter: labelEngineType.verticalCenter
                    anchors.rightMargin: 5
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

                    onActivated: {
                        engineCalculation()
                    }
                }
            }
            /**********************************************************************************************************/

            //Группа checkBox
            /**********************************************************************************************************/
            Item {
                id: item4
                anchors.top: item2.bottom
                anchors.left: item3.right
                anchors.right: parent.right
                anchors.bottom: rowRect.top

                ColumnLayout {
                    anchors.centerIn: parent

                    CheckBox {
                        id: checkBox
                        text: qsTr("Расчет секционирующих пунктов")
                    }

                    CheckBox {
                        id: checkBox1
                        text: qsTr("Расчет отклонения от большего к меньшему")
                    }

                    CheckBox {
                        id: checkBox2
                        text: qsTr("Расчет по максималному отклонению")
                    }

                    CheckBox {
                        id: checkBox3
                        checkState: Qt.Checked
                        text: qsTr("Автоматический расчет сечения")
                    }
                }
            }
            /**********************************************************************************************************/
        }
    }
}
