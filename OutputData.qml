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

    width: 677
    height: 360
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 3
        verticalOffset: 3
        radius: 5
        color: "#80000000"
    }

    Drag.active: mousAreaOutput.drag.active

    Rectangle {
        color: "#ffffff"
        radius: 5
        border.color: "#d1d1d1"
        anchors.fill: parent

        ScrollView {
            width: parent.width
            height: parent.height - 10
            contentHeight: 600
            anchors.centerIn: parent

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
            }

            Label {
                id: labelOutputData
                anchors.horizontalCenter: parent.horizontalCenter
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
                anchors.horizontalCenter: scrollViewOutput.horizontalCenter
                anchors.top: scrollViewOutput.bottom
                anchors.topMargin: 5
                text: qsTr("Аппараты защиты и двигатель")
                font.bold: true
                font.pointSize: 20
            }
            /*******************************************************************/

            Label {
                id: labelFuse
                anchors.top: labelProtectionDevice.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 15
                text: qsTr("Номинальный ток предохранителя на ТП, А")
            }

            TextField {
                id: textFieldFuse
                anchors.verticalCenter: labelFuse.verticalCenter
                anchors.left: labelFuse.right
                anchors.topMargin: 10
                anchors.leftMargin: 70
            }
            /*******************************************************************/

            Label {
                id: labelThermalRelease
                anchors.top: labelFuse.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 15
                text: qsTr("Номинальный ток теплового расцепителя на ТП, А")
            }

            TextField {
                id: textFieldThermalRelease
                anchors.verticalCenter: labelThermalRelease.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
            }
            /*******************************************************************/

            Label {
                id: labelElectromagneticRelease
                anchors.top: labelThermalRelease.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 15
                text: qsTr("Номинальный ток электромагнитного расцепителя на ТП, А")
            }

            TextField {
                id: textFieldElectromagneticRelease
                anchors.verticalCenter: labelElectromagneticRelease.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
            }
            /*******************************************************************/

            Label {
                id: labelEngine
                anchors.top: labelElectromagneticRelease.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 15
                text: qsTr("Номинальный ток электродвигателя, А")
            }

            TextField {
                id: textFieldEngine
                anchors.verticalCenter: labelEngine.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
            }
            /*******************************************************************/

            Label {
                id: labelStartingCurrent
                anchors.top: labelEngine.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 15
                text: qsTr("Пусковой ток электродвигателя, А")
            }

            TextField {
                id: textFieldStartingCurrent
                anchors.verticalCenter: labelStartingCurrent.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
            }

            /*******************************************************************/

            Label {
                id: labelDesignCurrentConsumerSum
                anchors.top: labelStartingCurrent.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 15
                text: qsTr("Суммарный расчетный ток нагрузок, А")
            }

            TextField {
                id: textFieldDesignCurrentConsumerSum
                anchors.verticalCenter: labelDesignCurrentConsumerSum.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
            }

            /*******************************************************************/

            Label {
                id: labelResistancePhaseZeroSum
                anchors.top: labelDesignCurrentConsumerSum.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 15
                text: qsTr("Суммарное сопротивление петли фаза-ноль, Ом")
            }

            TextField {
                id: textFieldResistancePhaseZeroSum
                anchors.verticalCenter: labelResistancePhaseZeroSum.verticalCenter
                anchors.horizontalCenter: textFieldFuse.horizontalCenter
                anchors.topMargin: 10
            }
        }
    }
}
