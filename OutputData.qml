import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls

Item {
    id: outputData

    property var columnScrollOutput_1: columnScrollOutput_1     //активная мощность
    property var columnScrollOutput_2: columnScrollOutput_2     //полная мощность
    property var columnScrollOutput_3: columnScrollOutput_3     //косинус средневзвешенный
    property var columnScrollOutput_3_1: columnScrollOutput_3_1 //расчетный ток участков
    property var columnScrollOutput_3_2: columnScrollOutput_3_2 //расчетный ток нагрузок
    property var columnScrollOutput_4: columnScrollOutput_4     //потеря напряжения
    property var columnScrollOutput_4_0: columnScrollOutput_4_0 //потеря напряжения в процентах
    property var columnScrollOutput_4_1: columnScrollOutput_4_1 //потеря напряжения суммарная
    property var columnScrollOutput_4_2: columnScrollOutput_4_2 //потеря напряжения суммарная в процентах
    property var columnScrollOutput_5: columnScrollOutput_5     //эквивалентная мощность
    property var columnScrollOutput_6: columnScrollOutput_6     //эквивалентный ток
    property var columnScrollOutput_7: columnScrollOutput_7     //экономическое сечение
    property var columnScrollOutput_8: columnScrollOutput_8     //сопротивление петли-фаза ноль
    property var columnScrollOutput_9: columnScrollOutput_9     //однофазное КЗ
    property var columnScrollOutput_10: columnScrollOutput_10   //расстояние до СП

    property alias fuseRating: textFieldFuse.text
    property alias ratedEngineCurrent: textFieldEngine.text
    property alias startingCurrent: textFieldStartingCurrent.text
    property alias sumDesignCurentConsumer: textFieldDesignCurrentConsumerSum.text
    property alias enginCurrent: textFieldEngine.text
    property alias thermalRelease: textFieldThermalRelease.text
    property alias electromagneticRelease: textFieldElectromagneticRelease.text
    property alias resistancePhaseZeroSum: textFieldResistancePhaseZeroSum.text

    property int outputDataX: 0
    property int outputDataY: 0
    property int outputDataWidth: 0
    property int outputDataHeight: 0

    width: 677
    height: 360

    DropShadow {
        anchors.fill: rectangleOutData
        source: rectangleOutData
        transparentBorder: true
        horizontalOffset: 3
        verticalOffset: 3
        radius: 5
        color: "#80000000"
    }

    Drag.active: mousAreaOutput.drag.active

    Rectangle {
        id: rectangleOutData
        color: "#ffffff"
        radius: 5
        border.color: "#d1d1d1"
        border.width: 2
        anchors.fill: parent

        property bool activeFocusOnWindow: {outData.z > chartComp.z &&
                                            outData.z > inpData.z &&
                                            outData.z > canvCard.z}

        Flickable {
            id: flickableView

            clip: true
            width: parent.width - 14
            height: parent.height - 14
            contentHeight: 600
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 20
            anchors.topMargin: 7
            anchors.bottomMargin: 7

            ScrollBar.vertical: ScrollBar {
                parent: flickableView.parent
                anchors.left: flickableView.right
                anchors.top: flickableView.top
                anchors.bottom: flickableView.bottom
                contentItem.opacity: 1
            }

            MouseArea {
                id: mousAreaOutput
                anchors.fill: parent
                drag {
                    target: outputData
                    minimumX: 0
                    minimumY: 0
                    maximumX: backgroundRectangle.width - outputData.width
                    maximumY: backgroundRectangle.height - outputData.height
                }

                onContainsMouseChanged: {
                    outData.z = inpData.z + chartComp.z + canvCard.z + 1
                }

                onDoubleClicked: {
                    if (outputData.width == backgroundRectangle.width
                            && outputData.height == backgroundRectangle.height) {
                        outputData.width = outputData.outputDataWidth
                        outputData.height = outputData.outputDataHeight
                        outputData.x = outputData.outputDataX
                        outputData.y = outputData.outputDataY
                    } else {
                        outputData.outputDataX = outputData.x
                        outputData.outputDataY = outputData.y
                        outputData.outputDataWidth = outputData.width
                        outputData.outputDataHeight = outputData.height
                        outputData.width = backgroundRectangle.width
                        outputData.height = backgroundRectangle.height
                        outputData.x = 0
                        outputData.y = 0
                    }
                }
            }

            Label {
                id: labelOutputData
                anchors.left: parent.left
                anchors.leftMargin: 120
                anchors.top: parent.top
                anchors.topMargin: 10
                height: 36
                text: qsTr("Расчетные параметры на участках")
                font.bold: true
                font.pointSize: 20
            }

            ScrollView {
                id: scrollViewOutput
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: labelOutputData.bottom
                anchors.leftMargin: 5

                Row {
                    id: row
                    anchors.fill: parent
                    spacing: 5
                    leftPadding: 10
                    rightPadding: 10
                    bottomPadding: 5

                    //Колонка активной мощности
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelActivPower
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Активная мощность, кВт")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelActivPower.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                id: scrollViewOutput_1
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_1
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка полной мощности
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelFullPower
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Полная мощность, кВА")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelFullPower.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_2
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка средневзвешенных косинусов
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelWeightedAverage
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Косинус средневзвешенный")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelWeightedAverage.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_3
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка расчетных токов на учасках
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelDesignCurrent
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Расчетный ток участка, А")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelDesignCurrent.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_3_1
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка расчетных токов нагрузок
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelDesignCurrentConsumer
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Расчетный ток нагрузки, А")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelDesignCurrentConsumer.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_3_2
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка потерь напряжения
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelVoltageLoss
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Потеря напряжения, В")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelVoltageLoss.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_4
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка потерь напряжения в процентах
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelVoltageLossPercent
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Потеря напряжения, %")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelVoltageLossPercent.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_4_0
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка суммарных потерь напряжения
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelVoltageLossSum
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Потеря напр. суммарная, В")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelVoltageLossSum.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_4_1
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка суммарных потерь напряжения в процентах
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelVoltageLossSumPercent
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Потеря напр. суммарная, %")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelVoltageLossSumPercent.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_4_2
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка эквивалентной мощности
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelEquivalentPower
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Эквивалентная мощность, кВА")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelEquivalentPower.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_5
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка эквивалентного тока
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelEquivalentCurrent
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Эквивалентный ток, А")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelEquivalentCurrent.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_6
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка экономического сечения
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelEconomicSection
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            textFormat: Text.RichText
                            text: qsTr("Экономическое сечение, мм <sup>2</sup>")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelEconomicSection.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_7
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка сопротивлений петель фаза-ноль
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelPhaseZero
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Сопр. петли фаза-ноль, Ом")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelPhaseZero.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_8
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка однофазных КЗ
                    /*******************************************************************************************/
                    Item {
                        width: 158
                        height: 220

                        Label {
                            id: labelSinglePhaseShortCircuit
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Однофазное КЗ, А")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelSinglePhaseShortCircuit.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 158
                                height: 200

                                Column {
                                    id: columnScrollOutput_9
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/

                    //Колонка расстояний до СП
                    /*******************************************************************************************/
                    Item {
                        width: 290
                        height: 220

                        Label {
                            id: labelRecloserLength
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            anchors.bottomMargin: 10
                            text: qsTr("Расстояние до СП, км")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: labelRecloserLength.bottom
                            color: "#e4e4e4"
                            radius: 5

                            ScrollView {
                                x: 0
                                y: 0
                                width: 290
                                height: 200

                                Column {
                                    id: columnScrollOutput_10
                                }
                            }
                        }
                    }
                    /*******************************************************************************************/
                }
            }

            /*******************************************************************/
            Label {
                id: labelProtectionDevice
                anchors.left: parent.left
                anchors.leftMargin: 120
                anchors.top: scrollViewOutput.bottom
                anchors.topMargin: 15
                text: qsTr("Аппараты защиты и двигатель")
                font.bold: true
                font.pointSize: 20
            }
            /*******************************************************************/

            Label {
                id: labelFuse
                anchors.top: labelProtectionDevice.bottom
                anchors.left: parent.left
                anchors.topMargin: 20
                anchors.leftMargin: 20
                text: qsTr("Номинальный ток предохранителя на ТП, А")
            }

            TextField {
                id: textFieldFuse
                anchors.verticalCenter: labelFuse.verticalCenter
                anchors.left: labelFuse.right
                anchors.topMargin: 10
                anchors.leftMargin: 100
                readOnly: true
            }
            /*******************************************************************/

            Label {
                id: labelThermalRelease
                anchors.top: labelFuse.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 20
                text: qsTr("Номинальный ток теплового расцепителя на ТП, А")
            }

            TextField {
                id: textFieldThermalRelease
                anchors.verticalCenter: labelThermalRelease.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
                readOnly: true
            }
            /*******************************************************************/

            Label {
                id: labelElectromagneticRelease
                anchors.top: labelThermalRelease.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 20
                text: qsTr("Номинальный ток электромагнитного расцепителя на ТП, А")
            }

            TextField {
                id: textFieldElectromagneticRelease
                anchors.verticalCenter: labelElectromagneticRelease.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
                readOnly: true
            }
            /*******************************************************************/

            Label {
                id: labelEngine
                anchors.top: labelElectromagneticRelease.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 20
                text: qsTr("Номинальный ток электродвигателя, А")
            }

            TextField {
                id: textFieldEngine
                anchors.verticalCenter: labelEngine.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
                readOnly: true
            }
            /*******************************************************************/

            Label {
                id: labelStartingCurrent
                anchors.top: labelEngine.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 20
                text: qsTr("Пусковой ток электродвигателя, А")
            }

            TextField {
                id: textFieldStartingCurrent
                anchors.verticalCenter: labelStartingCurrent.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
                readOnly: true
            }

            /*******************************************************************/

            Label {
                id: labelDesignCurrentConsumerSum
                anchors.top: labelStartingCurrent.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 20
                text: qsTr("Суммарный расчетный ток нагрузок, А")
            }

            TextField {
                id: textFieldDesignCurrentConsumerSum
                anchors.verticalCenter: labelDesignCurrentConsumerSum.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
                readOnly: true
            }

            /*******************************************************************/

            Label {
                id: labelResistancePhaseZeroSum
                anchors.top: labelDesignCurrentConsumerSum.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 20
                text: qsTr("Суммарное сопротивление петли фаза-ноль, Ом")
            }

            TextField {
                id: textFieldResistancePhaseZeroSum
                anchors.verticalCenter: labelResistancePhaseZeroSum.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
                readOnly: true
            }
        }

        //Нижняя область для изменения размера
        /**********************************************************************************************************/
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            anchors.rightMargin: 7
            anchors.leftMargin: 7
            height: 5

            MouseArea {
                id: bottomMouseScopeOut
                anchors.fill: parent
                cursorShape: rectangleOutData.activeFocusOnWindow ? Qt.SizeVerCursor : Qt.ArrowCursor
                property double clickPosBottom

                onPressed: {
                    if(rectangleOutData.activeFocusOnWindow) {
                        clickPosBottom = bottomMouseScopeOut.mouseY
                    }
                }

                onPositionChanged: {

                    if(rectangleOutData.activeFocusOnWindow) {

                        let delta = bottomMouseScopeOut.mouseY - clickPosBottom
                        if(delta > 0) {

                            if(delta < (backgroundRectangle.height - (outputData.height + outputData.y))) {
                                outputData.height += delta

                            } else {
                                delta = (backgroundRectangle.height - outputData.y) - outputData.height
                                outputData.height += delta
                            }

                        } else if(delta < 0) {

                            if((outputData.height + delta) > 360) {
                                outputData.height += delta
                            } else {
                                delta = 360 - outputData.height
                                outputData.height += delta
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
            anchors.topMargin: 2
            anchors.rightMargin: 7
            anchors.leftMargin: 7
            height: 5

            MouseArea {
                id: topMouseScopeOut
                anchors.fill: parent
                cursorShape: rectangleOutData.activeFocusOnWindow ? Qt.SizeVerCursor : Qt.ArrowCursor
                property double clickPosTop

                onPressed: {
                    if(rectangleOutData.activeFocusOnWindow) {
                        clickPosTop = topMouseScopeOut.mouseY
                    }
                }

                onPositionChanged: {
                    if(rectangleOutData.activeFocusOnWindow) {

                        let delta = topMouseScopeOut.mouseY - clickPosTop

                        if(delta > 0) {
                            if((outputData.height - delta) > 360) {
                                outputData.height -= delta
                                outputData.y += delta
                            } else {
                                delta = outputData.height - 360
                                outputData.height -= delta
                                outputData.y += delta
                            }
                        } else if(delta < 0) {
                            if(-delta < outputData.y) {
                                outputData.height -= delta
                                outputData.y += delta
                            } else {
                                delta = outputData.y
                                outputData.height += delta
                                outputData.y -= delta
                            }
                        }
                    }
                }
            }
        }
        /**********************************************************************************************************/

        //Правая область для изменения размера
        /**********************************************************************************************************/
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.topMargin: 7
            anchors.bottomMargin: 7
            width: 5

            MouseArea {
                id: rightMouseScopeOut
                anchors.fill: parent
                cursorShape: rectangleOutData.activeFocusOnWindow ? Qt.SizeHorCursor : Qt.ArrowCursor
                property double clickPosRight

                onPressed: {
                    if(rectangleOutData.activeFocusOnWindow) {
                        clickPosRight = rightMouseScopeOut.mouseX
                    }
                }

                onPositionChanged: {
                    if(rectangleOutData.activeFocusOnWindow) {

                        let delta = rightMouseScopeOut.mouseX - clickPosRight

                        if(delta > 0) {
                            if(delta < (backgroundRectangle.width - outputData.x - outputData.width)) {
                                outputData.width += delta
                            } else {
                                delta = backgroundRectangle.width - outputData.x - outputData.width
                                outputData.width += delta
                            }
                        } else if (delta < 0) {
                            if((outputData.width + delta) > 677) {
                                outputData.width += delta
                            } else {
                                delta = 677 - outputData.width
                                outputData.width += delta
                            }
                        }
                    }
                }
            }
        }
        /**********************************************************************************************************/

        //Левая область для изменения размера
        /**********************************************************************************************************/
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.topMargin: 7
            anchors.bottomMargin: 7
            width: 5

            MouseArea {
                id: leftMouseScopeOut
                anchors.fill: parent
                cursorShape: rectangleOutData.activeFocusOnWindow ? Qt.SizeHorCursor : Qt.ArrowCursor
                property double clickPosLeft

                onPressed: {
                    if(rectangleOutData.activeFocusOnWindow) {
                        clickPosLeft = leftMouseScopeOut.mouseX
                    }
                }

                onPositionChanged: {
                    if(rectangleOutData.activeFocusOnWindow) {

                        let delta = leftMouseScopeOut.mouseX - clickPosLeft

                        if(delta > 0) {
                            if((outputData.width - delta) > 677) {
                                outputData.width -= delta
                                outputData.x += delta
                            } else {
                                delta = outputData.width - 677
                                outputData.width -= delta
                                outputData.x += delta
                            }
                        } else if(delta < 0) {
                            if(-delta < outputData.x) {
                                outputData.width -= delta
                                outputData.x += delta
                            } else {
                                delta = outputData.x
                                outputData.width += delta
                                outputData.x -= delta
                            }
                        }
                    }
                }
            }
        }
        /**********************************************************************************************************/

        //Верхний левый угол для изменения размера
        /**********************************************************************************************************/
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 2
            anchors.topMargin: 2
            radius: 2
            width: 7
            height: 7

            MouseArea {
                id: topLeftMouseScopeOut
                anchors.fill: parent
                cursorShape: rectangleOutData.activeFocusOnWindow ? Qt.SizeFDiagCursor : Qt.ArrowCursor
                property double clickPosTop
                property double clickPosLeft

                onPressed: {
                    if(rectangleOutData.activeFocusOnWindow) {
                        clickPosLeft = topLeftMouseScopeOut.mouseX
                        clickPosTop = topLeftMouseScopeOut.mouseY
                    }
                }

                onPositionChanged: {
                    if(rectangleOutData.activeFocusOnWindow) {
                        let deltaY = topLeftMouseScopeOut.mouseY - clickPosTop

                        if(deltaY > 0) {
                            if((outputData.height - deltaY) > 360) {
                                outputData.height -= deltaY
                                outputData.y += deltaY
                            } else {
                                deltaY = outputData.height - 360
                                outputData.height -= deltaY
                                outputData.y += deltaY
                            }
                        } else if(deltaY < 0) {
                            if(-deltaY < outputData.y) {
                                outputData.height -= deltaY
                                outputData.y += deltaY
                            } else {
                                deltaY = outputData.y
                                outputData.height += deltaY
                                outputData.y -= deltaY
                            }
                        }

                        let deltaX = topLeftMouseScopeOut.mouseX - clickPosLeft

                        if(deltaX > 0) {
                            if((outputData.width - deltaX) > 677) {
                                outputData.width -= deltaX
                                outputData.x += deltaX
                            } else {
                                deltaX = outputData.width - 677
                                outputData.width -= deltaX
                                outputData.x += deltaX
                            }
                        } else if(deltaX < 0) {
                            if(-deltaX < outputData.x) {
                                outputData.width -= deltaX
                                outputData.x += deltaX
                            } else {
                                deltaX = outputData.x
                                outputData.width += deltaX
                                outputData.x -= deltaX
                            }
                        }
                    }
                }
            }
        }
        /**********************************************************************************************************/

        //Верхний правый угол для изменения размера
        /**********************************************************************************************************/
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 2
            anchors.topMargin: 2
            radius: 2
            width: 7
            height: 7

            MouseArea {
                id: topRightMouseScopeOut
                anchors.fill: parent
                cursorShape: rectangleOutData.activeFocusOnWindow ? Qt.SizeBDiagCursor : Qt.ArrowCursor
                property double clickPosTop
                property double clickPosRight

                onPressed: {
                    if(rectangleOutData.activeFocusOnWindow) {
                        clickPosRight = topLeftMouseScopeOut.mouseX
                        clickPosTop = topLeftMouseScopeOut.mouseY
                    }
                }

                onPositionChanged: {
                    if(rectangleOutData.activeFocusOnWindow) {
                        let deltaY = topRightMouseScopeOut.mouseY - clickPosTop

                        if(deltaY > 0) {
                            if((outputData.height - deltaY) > 360) {
                                outputData.height -= deltaY
                                outputData.y += deltaY
                            } else {
                                deltaY = outputData.height - 360
                                outputData.height -= deltaY
                                outputData.y += deltaY
                            }
                        } else if(deltaY < 0) {
                            if(-deltaY < outputData.y) {
                                outputData.height -= deltaY
                                outputData.y += deltaY
                            } else {
                                deltaY = outputData.y
                                outputData.height += deltaY
                                outputData.y -= deltaY
                            }
                        }

                        let deltaX = topRightMouseScopeOut.mouseX - clickPosRight

                        if(deltaX > 0) {
                            if(deltaX < (backgroundRectangle.width - outputData.x - outputData.width)) {
                                outputData.width += deltaX
                            } else {
                                deltaX = backgroundRectangle.width - outputData.x - outputData.width
                                outputData.width += deltaX
                            }
                        } else if (deltaX < 0) {
                            if((outputData.width + deltaX) > 677) {
                                outputData.width += deltaX
                            } else {
                                deltaX = 677 - outputData.width
                                outputData.width += deltaX
                            }
                        }
                    }
                }
            }
        }
        /**********************************************************************************************************/

        //Нижний левый угол для изменения размера
        /**********************************************************************************************************/
        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 2
            anchors.bottomMargin: 2
            radius: 2
            width: 7
            height: 7

            MouseArea {
                id: bottomLeftMouseScopeOut
                anchors.fill: parent
                cursorShape: rectangleOutData.activeFocusOnWindow ? Qt.SizeBDiagCursor : Qt.ArrowCursor
                property double clickPosBottom
                property double clickPosLeft

                onPressed: {
                    if(rectangleOutData.activeFocusOnWindow) {
                        clickPosLeft = topLeftMouseScopeOut.mouseX
                        clickPosBottom = topLeftMouseScopeOut.mouseY
                    }
                }

                onPositionChanged: {
                    if(rectangleOutData.activeFocusOnWindow) {
                        let deltaX = bottomLeftMouseScopeOut.mouseX - clickPosLeft

                        if(deltaX > 0) {
                            if((outputData.width - deltaX) > 677) {
                                outputData.width -= deltaX
                                outputData.x += deltaX
                            } else {
                                deltaX = outputData.width - 677
                                outputData.width -= deltaX
                                outputData.x += deltaX
                            }
                        } else if(deltaX < 0) {
                            if(-deltaX < outputData.x) {
                                outputData.width -= deltaX
                                outputData.x += deltaX
                            } else {
                                deltaX = outputData.x
                                outputData.width += deltaX
                                outputData.x -= deltaX
                            }
                        }

                        let deltaY = bottomLeftMouseScopeOut.mouseY - clickPosBottom
                        if(deltaY > 0) {

                            if(deltaY < (backgroundRectangle.height - (outputData.height + outputData.y))) {
                                outputData.height += deltaY

                            } else {
                                deltaY = (backgroundRectangle.height - outputData.y) - outputData.height
                                outputData.height += deltaY
                            }

                        } else if(deltaY < 0) {

                            if((outputData.height + deltaY) > 360) {
                                outputData.height += deltaY
                            } else {
                                deltaY = 360 - outputData.height
                                outputData.height += deltaY
                            }
                        }
                    }
                }
            }
        }
        /**********************************************************************************************************/

        //Нижний правый угол для изменения размера
        /**********************************************************************************************************/
        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 2
            anchors.bottomMargin: 2
            radius: 2
            width: 7
            height: 7

            MouseArea {
                id: bottomRightMouseScopeOut
                anchors.fill: parent
                cursorShape: rectangleOutData.activeFocusOnWindow ? Qt.SizeFDiagCursor : Qt.ArrowCursor
                property double clickPosBottom
                property double clickPosRight

                onPressed: {
                    if(rectangleOutData.activeFocusOnWindow) {
                        clickPosRight = topLeftMouseScopeOut.mouseX
                        clickPosBottom = topLeftMouseScopeOut.mouseY
                    }
                }

                onPositionChanged: {
                    let deltaX = bottomRightMouseScopeOut.mouseX - clickPosRight

                    if(deltaX > 0) {
                        if(deltaX < (backgroundRectangle.width - outputData.x - outputData.width)) {
                            outputData.width += deltaX
                        } else {
                            deltaX = backgroundRectangle.width - outputData.x - outputData.width
                            outputData.width += deltaX
                        }
                    } else if (deltaX < 0) {
                        if((outputData.width + deltaX) > 677) {
                            outputData.width += deltaX
                        } else {
                            deltaX = 677 - outputData.width
                            outputData.width += deltaX
                        }
                    }

                    let deltaY = bottomRightMouseScopeOut.mouseY - clickPosBottom
                    if(deltaY > 0) {

                        if(deltaY < (backgroundRectangle.height - (outputData.height + outputData.y))) {
                            outputData.height += deltaY

                        } else {
                            deltaY = (backgroundRectangle.height - outputData.y) - outputData.height
                            outputData.height += deltaY
                        }

                    } else if(deltaY < 0) {

                        if((outputData.height + deltaY) > 360) {
                            outputData.height += deltaY
                        } else {
                            deltaY = 360 - outputData.height
                            outputData.height += deltaY
                        }
                    }
                }
            }
        }
        /**********************************************************************************************************/
    }  
}
