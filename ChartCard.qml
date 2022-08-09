import QtQuick
import QtCharts
import Qt5Compat.GraphicalEffects

Item {

    DropShadow {
        anchors.fill: rectChart
        source: rectChart
        transparentBorder: true
        horizontalOffset: 4
        verticalOffset: 4
        radius: 5
        color: "#80000000"
    }

    Rectangle {
        id: rectChart
        width: 677
        height: 300
        radius: 5
        border.color: "#d1d1d1"

        ChartView {
            id: chartCard
            anchors.centerIn: parent

            width: parent.width
            height: parent.height

            LineSeries {
                name: "График отклонения напряжения"
                XYPoint {
                    x: 0
                    y: 2
                }

                XYPoint {
                    x: 1
                    y: 1.2
                }

                XYPoint {
                    x: 2
                    y: 3.3
                }

                XYPoint {
                    x: 5
                    y: 2.1
                }
            }
        }

        Drag.active: mouseRectChart.drag.active
    }

    MouseArea {
        id: mouseRectChart
        anchors.fill: rectChart
        drag {
            target: rectChart
            minimumX: 0
            minimumY: -inpData.height
            maximumX: backgroundRectangle.width - rectChart.width
            maximumY: backgroundRectangle.height - rectChart.height - inpData.height
        }

        onContainsMouseChanged: {
            chartComp.z = outData.z + inpData.z + canvCard.z + 1
        }
    }
}

