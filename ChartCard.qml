import QtQuick
import QtCharts
import Qt5Compat.GraphicalEffects

Item {
    property var lineSeries: lineSeriesChart

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
            ValuesAxis {
                id: valueAxisX
                min: 0
                max: 10
                tickCount: 11
            }

            ValuesAxis {
                id: valueAxisY
                min: 0
                max: 9
                tickCount: 10
            }

            width: parent.width
            height: parent.height

            LineSeries {
                id: lineSeriesChart
                axisX: valueAxisX
                axisY: valueAxisY
                name: "График отклонения напряжения"
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
