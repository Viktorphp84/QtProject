import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls

Item {
    id: outputData

    property var columnScrollOutput_1: columnScrollOutput_1
    property var columnScrollOutput_2: columnScrollOutput_2
    property var columnScrollOutput_3: columnScrollOutput_3
    property var columnScrollOutput_4: columnScrollOutput_4
    property var columnScrollOutput_5: columnScrollOutput_5
    property var columnScrollOutput_6: columnScrollOutput_6
    property var columnScrollOutput_7: columnScrollOutput_7
    property var columnScrollOutput_8: columnScrollOutput_8
    property var columnScrollOutput_9: columnScrollOutput_9

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
                }
            }


            /*Label {
                id: labelProtectionDevice
                anchors.horizontalCenter: row.horizontalCenter
                anchors.top: row.bottom
                text: qsTr("Аппараты защиты и двигатель")
                font.bold: true
                font.pointSize: 20
            }

            Label {
                id: labelFuse
                anchors.top: labelProtectionDevice.bottom
                anchors.left: parent.left
                anchors.topMargin: 10
                anchors.leftMargin: 10
                text: qsTr("Номинальный ток предохранителя на ТП, А")
            }

            TextField {
                anchors.top: labelProtectionDevice.bottom
                anchors.left: labelFuse.right
                anchors.topMargin: 10
                anchors.leftMargin: 10
            }*/
        }
    }
}
