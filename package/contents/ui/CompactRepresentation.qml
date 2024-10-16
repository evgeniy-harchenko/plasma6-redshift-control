/*
    SPDX-FileCopyrightText: 2015 Martin Kotelnik <clearmartin@seznam.cz>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

Item {
    id: compactRepresentation

    property double itemWidth: parent === null ? 0 : vertical ? parent.width : parent.height
    property double itemHeight: itemWidth

    Layout.preferredWidth: itemWidth
    Layout.preferredHeight: itemHeight

    property double fontPixelSize: itemWidth * 0.72
    property int temperatureIncrement: plasmoid.configuration.manualTemperatureStep
    property int temperatureMin: 1000
    property int temperatureMax: 25000

    // x100 for better counting
    property int brightnessIncrement: plasmoid.configuration.manualBrightnessStep * 100
    property int brightnessMin: 10
    property int brightnessMax: 100

    property bool textColorLight: ((Kirigami.Theme.textColor.r + Kirigami.Theme.textColor.g + Kirigami.Theme.textColor.b) / 3) > 0.5
    property color bulbIconColourActive: Kirigami.Theme.textColor
    property color bulbIconColourInactive: textColorLight ? Qt.tint(Kirigami.Theme.textColor, '#80000000') : Qt.tint(Kirigami.Theme.textColor, '#80FFFFFF')//textColorLight ? '#80000000' : '#80FFFFFF'
    property color bulbIconColourCurrent: active ? bulbIconColourActive : bulbIconColourInactive
    property string customIconSource: active ? plasmoid.configuration.iconActive : plasmoid.configuration.iconInactive
    property color redshiftColour: '#ff3c0b'
    property color brightnessColour: '#39a2ee'

    property string backendString: plasmoid.configuration.backendString

    property string versionString: 'N/A'

    FontLoader {
        source: '../fonts/fontawesome-webfont-4.3.0.ttf'
    }

    Kirigami.Icon {
        id: customIcon
        anchors.fill: parent
        visible: !plasmoid.configuration.useDefaultIcons
        source: customIconSource
        color: bulbIconColourCurrent
    }

    PlasmaComponents.Label {
        id: bulbIcon
        anchors.centerIn: parent
        visible: plasmoid.configuration.useDefaultIcons

        font.family: 'FontAwesome'
        text: '\uf0eb'

        color: bulbIconColourCurrent
        font.pixelSize: fontPixelSize
        font.pointSize: -1
    }

    PlasmaComponents.Label {
        id: manualIcon
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.1

        font.family: 'FontAwesome'
        text: '\uf04c'

        color: textColorLight ? Qt.tint(Kirigami.Theme.textColor, '#80FFFF00') : Qt.tint(Kirigami.Theme.textColor, '#80FF3300')
        font.pixelSize: fontPixelSize * 0.3
        font.pointSize: -1
        verticalAlignment: Text.AlignBottom

        visible: manualEnabled
    }

    PropertyAnimation {
        id: animWheelBrighness
        targets: [customIcon, bulbIcon]
        property: "color"
        running: false;
        from: brightnessColour;
        to: bulbIconColourCurrent;
        duration: 1000
    }

    PropertyAnimation {
        id: animWheelTemperature
        targets: [customIcon, bulbIcon]
        property: "color"
        running: false;
        from: redshiftColour;
        to: bulbIconColourCurrent;
        duration: 1000
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onWheel: (wheel)=> {
            if (!manualEnabled) {
                manualTemperature = currentTemperature
                manualBrightness = currentBrightness
                redshiftDS.connectedSources.length = 0
                manualEnabled = true
                previouslyActive = active
                active = false
            }
            if (redshiftDS.connectedSources.length > 0) {
                return
            }
            if (wheel.angleDelta.y > 0) {
                // wheel up
                if (manualEnabledBrightness) {
                    manualBrightness += brightnessIncrement
                    if (manualBrightness > brightnessMax) {
                        manualBrightness = brightnessMax
                    }
                    currentBrightness = manualBrightness
                } else {
                    manualTemperature += temperatureIncrement
                    if (manualTemperature > temperatureMax) {
                        manualTemperature = temperatureMax
                    }
                }
            } else {
                // wheel down
                if (manualEnabledBrightness) {
                    manualBrightness -= brightnessIncrement
                    if (manualBrightness < brightnessMin) {
                        manualBrightness = brightnessMin
                    }
                    currentBrightness = manualBrightness
                } else {
                    manualTemperature -= temperatureIncrement
                    if (manualTemperature < temperatureMin) {
                        manualTemperature = temperatureMin
                    }
                }
            }
            if (parseFloat(versionString) >= 1.12) {
                redshiftDS.connectedSources.push(redshiftOneTimeCommand + " -P")
            } else {
                redshiftDS.connectedSources.push(redshiftOneTimeCommand)
            }
        }

        onClicked: (mouse)=> {
            if (mouse.button === Qt.MiddleButton) {
                manualEnabledBrightness = !manualEnabledBrightness
                updateTooltip()
                if (manualEnabledBrightness) {
                    animWheelBrighness.running = false
                    animWheelTemperature.running = false
                    animWheelBrighness.running = true
                } else {
                    animWheelBrighness.running = false
                    animWheelTemperature.running = false
                    animWheelTemperature.running = true
                }
                return;
            }

            if (!manualEnabled) {
                toggleRedshift()
                return
            }

            manualEnabled = false
            if (previouslyActive) {
                toggleRedshift()
            } else {
                stopRedshift()
            }
        }
    }

    Plasma5Support.DataSource {
        id: getOptionsDS
        engine: 'executable'

        connectedSources: [backendString + ' -V']

        onNewData: (sourceName, data) => {
            connectedSources.length = 0
            if (data['exit code'] > 0) {
                print('Error running ' + backendString + ' with command: ' + sourceName + '   ...stderr: ' + data.stderr)
                return
            }
            versionString = data.stdout.split(' ')[1]
        }
    }
}
