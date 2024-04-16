/*
    SPDX-FileCopyrightText: 2015 Martin Kotelnik <clearmartin@seznam.cz>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {

    property alias cfg_autostart: autostart.checked
    property alias cfg_smoothTransitions: smoothTransitions.checked
    property alias cfg_manualTemperatureStep: manualTemperatureStep.value
    property alias cfg_manualBrightnessStep: manualBrightnessStep.value
    property alias cfg_useDefaultIcons: useDefaultIcons.checked
    property string cfg_iconActive: plasmoid.configuration.iconActive
    property string cfg_iconInactive: plasmoid.configuration.iconInactive

    Kirigami.FormLayout {
        CheckBox {
            id: autostart
            Kirigami.FormData.label: i18n("Autostart")
        }

        CheckBox {
            id: smoothTransitions
            Kirigami.FormData.label: i18n("Smooth transitions")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Manual temperature step:")
            Layout.minimumWidth: Kirigami.Units.gridUnit * 10
            Layout.fillHeight: true
            Layout.fillWidth: true

            Slider {
                id: manualTemperatureStep
                snapMode: Slider.SnapOnRelease
                stepSize: -125
                from : 25
                to: 5000
                Layout.fillHeight: true
                Layout.fillWidth: true
                //implicitWidth : parent.width / 2
            }
            Label {
                text: manualTemperatureStep.value
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        /*SpinBox {
            id: manualBrightnessStep
            Layout.minimumWidth: iconActivePicker.width
            decimals: 2
            stepSize: 0.01
            minimumValue: 0.01
            maximumValue: 0.2
        }*/

        RowLayout {
            Kirigami.FormData.label: i18n("Manual brightness step:")
            Layout.fillHeight: true
            Layout.fillWidth: true

            Slider {
                id: manualBrightnessStep
                snapMode: Slider.SnapOnRelease
                stepSize: -0.01
                from : 0.01
                to: 0.2
                Layout.fillHeight: true
                Layout.fillWidth: true
                //implicitWidth : parent.width / 2
            }
            Label {
                text: manualBrightnessStep.value.toFixed(2)
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: useDefaultIcons
            Kirigami.FormData.label: i18n("Use default icons")
            Layout.columnSpan: 2
        }

        IconPicker {
            Kirigami.FormData.label: i18n("Active:")
            id: iconActivePicker
            currentIcon: cfg_iconActive
            defaultIcon: 'redshift-status-on'
            onIconChanged: cfg_iconActive = iconName
            enabled: !useDefaultIcons.checked
        }

        IconPicker {
            Kirigami.FormData.label: i18n("Inactive:")
            currentIcon: cfg_iconInactive
            defaultIcon: 'redshift-status-off'
            onIconChanged: cfg_iconInactive = iconName
            enabled: !useDefaultIcons.checked
        }

        /*Kirigami.Separator {
            Kirigami.FormData.isSection: true
        }


        GridLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 10
            columns: 4
            RowLayout {
                Layout.columnSpan: parent.columns
                spacing: 2
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Plasmoid version") + ": "
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
                Label {
                    text: Plasmoid.metaData.version
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }*/
    }
}
