/*
    SPDX-FileCopyrightText: 2015 Martin Kotelnik <clearmartin@seznam.cz>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: main

    anchors.fill: parent

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)

    property bool active: false
    property bool previouslyActive: false
    property bool startAfterStop: false

    property bool autostart: plasmoid.configuration.autostart
    property bool smoothTransitions: plasmoid.configuration.smoothTransitions

    property bool geoclueLocationEnabled: plasmoid.configuration.geoclueLocationEnabled
    property string latitude: plasmoid.configuration.latitude
    property string longitude: plasmoid.configuration.longitude
    property int dayTemperature: plasmoid.configuration.dayTemperature
    property int nightTemperature: plasmoid.configuration.nightTemperature
    property real dayBrightness: plasmoid.configuration.dayBrightness
    property real nightBrightness: plasmoid.configuration.nightBrightness
    property real gammaR: plasmoid.configuration.gammaR
    property real gammaG: plasmoid.configuration.gammaG
    property real gammaB: plasmoid.configuration.gammaB
    property string backendString: plasmoid.configuration.backendString
    property string renderMode: plasmoid.configuration.renderMode
    property string renderModeString: plasmoid.configuration.renderModeString
    property bool preserveScreenColour: renderMode === 'randr' || renderMode === 'vidmode' ? plasmoid.configuration.preserveScreenColour : false

    property int manualStartingTemperature: 6500
    property int manualTemperature: manualStartingTemperature
    property bool manualEnabled: false
    property int currentTemperature: manualStartingTemperature
    property int manualStartingBrightness: 100
    property real manualBrightness: manualStartingBrightness
    property bool manualEnabledBrightness: false
    property int currentBrightness: manualStartingBrightness

    //
    // terminal commands
    //
    // - parts
    property string brightnessAndGamma: ' -b ' + dayBrightness + ':' + nightBrightness + ' -g ' + gammaR + ':' + gammaG + ':' + gammaB
    property string locationCmdPart: geoclueLocationEnabled ? '' : ' -l ' + latitude + ':' + longitude
    property string modeCmdPart: renderModeString === '' ? '' : ' ' + renderModeString

    // - commands
    property string redshiftCommand: backendString + locationCmdPart + modeCmdPart + ' -t ' + dayTemperature + ':' + nightTemperature + brightnessAndGamma + (smoothTransitions ? '' : ' -r')
    property string redshiftOneTimeBrightnessAndGamma: ' -b ' + (currentBrightness * 0.01).toFixed(2) + ':' + (currentBrightness * 0.01).toFixed(2) + ' -g ' + gammaR + ':' + gammaG + ':' + gammaB
    property string redshiftOneTimeCommand: backendString + modeCmdPart + ' -PO ' + manualTemperature + redshiftOneTimeBrightnessAndGamma + ' -r'
    property string redshiftPrintCommand: 'LANG=C ' + redshiftCommand + ' -p'

    //property bool inTray: (plasmoid.parent === null || plasmoid.parent.objectName === 'taskItemContainer')
    property string toolTipText: ""

    /*toolTipMainText: i18n("Redshift Control")
    toolTipSubText: toolTipText
    toolTipTextFormat: Text.RichText*/

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        icon: 'redshift-status-on'
        mainText: i18n("Redshift Control")
        subText: {
            var details = toolTipText
            return details
        }
    }

    preferredRepresentation: fullRepresentation
    fullRepresentation: CompactRepresentation {
    }

    Component.onCompleted: {
        print('renderModeString: ' + renderModeString)
        /*if (!inTray) {
            // not in tray
            fullRepresentation = null
        }*/
        restartRedshiftIfAutostart()
    }

    function toggleRedshift() {
        if (redshiftDS.connectedSources.length > 0) {
            stopRedshift()
        } else {
            print('enabling ' + backendString + ' with command: ' + redshiftCommand)
            redshiftDS.connectedSources.push(redshiftCommand)
            active = true
        }
    }

    function stopRedshift() {
        print('disabling ' + backendString)
        redshiftDS.removeSource(redshiftCommand)
        redshiftDS.connectedSources.push(redshiftDS.redshiftStopSource)
        active = false
    }

    function restartRedshiftIfAutostart() {
        manualEnabled = false
        startAfterStop = autostart
        stopRedshift()
    }

    onRedshiftCommandChanged: {
        restartRedshiftIfAutostart()
    }

    onRedshiftPrintCommandChanged: {
        redshiftPrintDS.connectedSources.length = 0
        redshiftPrintDS.connectedSources.push(redshiftPrintCommand)
    }

    Plasma5Support.DataSource {
        id: redshiftDS
        engine: 'executable'

        property string redshiftStopSource: preserveScreenColour ? 'pkill -USR1 ' + backendString + '; killall ' + backendString + '' : 'killall ' + backendString + '; ' + backendString + ' -x'

        connectedSources: [redshiftStopSource]

        onNewData: (sourceName, data) => {
            if (sourceName === redshiftStopSource) {
                print('clearing connected sources, stop source was: ' + redshiftStopSource)
                connectedSources.length = 0
                if (startAfterStop) {
                    startAfterStop = false
                    toggleRedshift()
                }
                return
            }

            if (data['exit code'] > 0) {
                print('Error running ' + backendString + ' with command: ' + sourceName + '   ...stderr: ' + data.stderr)

                var service = notificationsDS.serviceForSource('notifications')
                var operation = service.operationDescription('createNotification')
                operation.appName = backendString + ' Control'
                operation.appIcon = 'redshift-status-on'
                operation.summary = 'Error running ' + backendString + ' command'
                operation.body = data.stderr
                service.startOperationCall(operation)

                stopRedshift()
                return
            }

            print('process exited with code 0. sourceName: ' + sourceName + ', data: ' + data.stdout)

            if (manualEnabled) {
                connectedSources.length = 0
            }
        }
    }

    Plasma5Support.DataSource {
        id: redshiftPrintDS
        engine: 'executable'
        interval: active ? 10000 : 0

        connectedSources: []

        onNewData: (sourceName, data) => {
            if (data['exit code'] > 0) {
                print('Error running ' + backendString + ' print cmd with command: ' + sourceName + '   ...stderr: ' + data.stderr)
                return
            }

            // example output: "Color temperature: 5930K"
            var matchTemperature = /Color temperature: ([0-9]+)K/.exec(backendString === "gammastep" ? data.stderr : data.stdout)
            // example output: "Brightness: 1.0"
            var matchBrightness = /Brightness: ([0-9]+\.[0-9]+)/.exec(backendString === "gammastep" ? data.stderr : data.stdout)
            if (matchTemperature !== null) {
                currentTemperature = parseInt(matchTemperature[1])
            }
            if (matchBrightness !== null) {
                currentBrightness = parseFloat(matchBrightness[1]) * 100
            }
        }
    }

    Plasma5Support.DataSource {
        id: notificationsDS
        engine: 'notifications'
        connectedSources: ['notifications']
    }

    function updateTooltip() {
        toolTipText = ''
        toolTipText += '<font size="4">'
        if (active) {
            toolTipText += i18n("Turned on") + ", " + currentTemperature + "K"
        } else {
            if (manualEnabled) {
                toolTipText += i18n("Manual temperature") + " " + manualTemperature + "K | " + i18n("Brightness") + " " + (manualBrightness * 0.01).toFixed(2)
            } else {
                toolTipText += i18n("Turned off")
            }
        }
        toolTipText += "</font>"
        toolTipText += "<br />"
        toolTipText += "<i>" + i18n("Use left / middle click and wheel to manage screen temperature and brightness") + "</i>"
        toolTipText += "<br />"
        if (manualEnabledBrightness) {
            toolTipText += i18n("Mouse wheel controls software brightness")
        } else {
            toolTipText += i18n("Mouse wheel controls screen temperature")
        }

        //Plasmoid.toolTipSubText = toolTipText
        //toolTipTextFormat: Text.RichText
        //toolTipSubText = toolTipText

        //toolTipMainText = i18n("Redshift Control")
        toolTipSubText = toolTipText
        //Plasmoid.icon = 'redshift-status-on'

        plasmoidPassiveTimer.stop()
        plasmoid.status = PlasmaCore.Types.ActiveStatus
        plasmoidPassiveTimer.restart()
    }

    Timer {
        id: plasmoidPassiveTimer
        interval: 20000
        onTriggered: {
            plasmoid.status = PlasmaCore.Types.PassiveStatus
        }
    }

    onActiveChanged: updateTooltip()
    onManualEnabledChanged: updateTooltip()
    onManualTemperatureChanged: updateTooltip()
    onManualBrightnessChanged: updateTooltip()
    onCurrentTemperatureChanged: updateTooltip()
    onCurrentBrightnessChanged: updateTooltip()

    /*toolTipMainText: i18n("Redshift Control")
    toolTipSubText: ''
    toolTipTextFormat: Text.RichText
    Plasmoid.icon: 'redshift-status-on'*/
    toolTipTextFormat: Text.RichText


    // NOTE: taken from colorPicker plasmoid
    // prevents the popup from actually opening, needs to be queued
    Timer {
        id: delayedRunShortcutTimer
        interval: 0
        onTriggered: {
            plasmoid.expanded = false
            toggleRedshift()
        }
    }

    Plasmoid.onActivated: {
        delayedRunShortcutTimer.start()
    }

}
