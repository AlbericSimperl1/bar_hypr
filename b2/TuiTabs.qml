// TuiTabs.qml - rij tabs; de actieve staat op wit
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: tabs
    property var model: []     // [{ key, label }]
    property string current
    signal picked(string key)

    Layout.leftMargin: 2
    spacing: 4

    Repeater {
        model: tabs.model
        delegate: SChip {
            required property var modelData
            label: modelData.label
            sel: tabs.current === modelData.key
            onActivated: tabs.picked(modelData.key)
        }
    }
}
