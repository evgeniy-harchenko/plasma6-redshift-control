/*
    SPDX-FileCopyrightText: 2015 Martin Kotelnik <clearmartin@seznam.cz>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kcmutils as KCM
import org.kde.kirigami 2.4 as Kirigami

KCM.SimpleKCM {
    id: advancedConfig

    property alias cfg_geoclueLocationEnabled: geoclueLocationEnabled.checked
    property alias cfg_latitude: latitude.text
    property alias cfg_longitude: longitude.text
    property alias cfg_dayTemperature: dayTemperature.value
    property alias cfg_nightTemperature: nightTemperature.value
    property alias cfg_dayBrightness: dayBrightness.value
    property alias cfg_nightBrightness: nightBrightness.value
    property alias cfg_gammaR: gammaR.value
    property alias cfg_gammaG: gammaG.value
    property alias cfg_gammaB: gammaB.value
    property string cfg_renderMode
    property alias cfg_renderModeScreen: renderModeScreen.text
    property alias cfg_renderModeCard: renderModeCard.text
    property alias cfg_renderModeCrtc: renderModeCrtc.text
    property alias cfg_preserveScreenColour: preserveScreenColour.checked
    property string cfg_renderModeString

    property string versionString: 'N/A'
    property string modeString: ''

    onCfg_renderModeChanged: {
        print('restore: ' + cfg_renderMode)
        var comboIndex = modeCombo.find(cfg_renderMode)
        print('restore index: ' + comboIndex)
        if (comboIndex > -1) {
            modeCombo.currentIndex = comboIndex
        }
    }

    Plasma5Support.DataSource {
        id: geolocationDS
        engine: 'geolocation'

        property string locationSource: 'location'

        connectedSources: []

        onNewData: (sourceName, data) => {
            print('geolocation: ' + data.latitude)
            latitude.text = data.latitude
            longitude.text = data.longitude
        }
    }

    Kirigami.FormLayout {
        //wideMode: true

        Kirigami.Separator {
            Layout.minimumWidth: Kirigami.Units.gridUnit * 20
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Location")
        }

        CheckBox {
            id: geoclueLocationEnabled
            Kirigami.FormData.label: i18n("Automatic (geoclue)")
        }

        TextField {
            id: latitude // decimals: 7
            Kirigami.FormData.label: i18n("Latitude:")
            //Layout.preferredWidth : 150
            enabled: !geoclueLocationEnabled.checked
            validator: RegularExpressionValidator {
                regularExpression: /^(\+|-)?(?:90(?:(?:\.0{1,7})?)|(?:[0-9]|[1-8][0-9])?(?:(?:\.[0-9]{1,7})?))$/
            }
            /*validator: DoubleValidator {
                top: 90
                bottom: -90
                decimals: 7;
                locale: "en"
                notation: DoubleValidator.StandardNotation
            }*/
        }

        TextField {
            id: longitude // decimals: 7
            Kirigami.FormData.label: i18n("Longitude:")
            //Layout.preferredWidth : 150
            enabled: !geoclueLocationEnabled.checked
            validator: RegularExpressionValidator {
                regularExpression: /^(\+|-)?(?:180(?:(?:\.0{1,7})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])?(?:(?:\.[0-9]{1,7})?))$/
            }
            /*validator: DoubleValidator {
                top: 180
                bottom: -180
                decimals: 7;
                locale: "en"
                notation: DoubleValidator.StandardNotation
            }*/
        }

        Button {
            text: i18n("Locate") // tooltip: i18n("This will use Mozilla Location Service exposed natively in KDE")
            onClicked: {
                geolocationDS.connectedSources.length = 0
                geolocationDS.connectedSources.push(geolocationDS.locationSource)
            }
            enabled: !geoclueLocationEnabled.checked
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Temperature")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Day:")
            Layout.fillHeight: true
            Layout.fillWidth: true

            Slider {
                id: dayTemperature
                snapMode: Slider.SnapOnRelease
                stepSize: -250
                from : 1000
                to: 25000
                Layout.fillHeight: true
                Layout.fillWidth: true
                //implicitWidth : parent.width / 2
            }
            Label {
                text: dayTemperature.value + "K"
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Night:")
            Layout.fillHeight: true
            Layout.fillWidth: true

            Slider {
                id: nightTemperature
                snapMode: Slider.SnapOnRelease
                stepSize: -250
                from : 1000
                to: 25000
                Layout.fillHeight: true
                Layout.fillWidth: true
                //implicitWidth : parent.width / 2
            }
            Label {
                text: nightTemperature.value + "K"
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Brightness")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Day:")
            Layout.fillHeight: true
            Layout.fillWidth: true

            Slider {
                id: dayBrightness
                snapMode: Slider.SnapOnRelease
                stepSize: 0.05
                from : 0.2
                to: 1.0
                Layout.fillHeight: true
                Layout.fillWidth: true
                /*ToolTip {
                    parent: dayBrightness.handle
                    visible: dayBrightness.pressed
                    text: dayBrightness.value.toFixed(2)
                }*/
            }
            Label {
                text: dayBrightness.value.toFixed(2)
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Night:")
            Layout.fillHeight: true
            Layout.fillWidth: true
            Slider {
                id: nightBrightness
                snapMode: Slider.SnapOnRelease
                stepSize: 0.05
                from : 0.2
                to: 1.0
                Layout.fillHeight: true
                Layout.fillWidth: true
                /*ToolTip {
                    parent: nightBrightness.handle
                    visible: nightBrightness.pressed
                    text: nightBrightness.value.toFixed(2)
                }*/
            }
            Label {
                text: nightBrightness.value.toFixed(2)
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Gamma")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("R:")
            Layout.fillHeight: true
            Layout.fillWidth: true
            Slider {
                id: gammaR
                snapMode: Slider.SnapOnRelease
                stepSize: -0.1
                from : 0.1
                to: 10
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 2
            }
            TextField {
                text: gammaR.value.toFixed(7)
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                onEditingFinished: {
                    gammaR.value = parseFloat(text)
                }
                validator: DoubleValidator {
                    top: gammaR.to
                    bottom: gammaR.from
                    decimals: 7;
                    locale: "en"
                    notation: DoubleValidator.StandardNotation
                }
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("G:")
            Layout.fillHeight: true
            Layout.fillWidth: true
            Slider {
                id: gammaG
                snapMode: Slider.SnapOnRelease
                stepSize: -0.1
                from : 0.1
                to: 10
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 2
            }
            TextField {
                text: gammaG.value.toFixed(7)
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                onEditingFinished: {
                    gammaG.value = parseFloat(text)
                }
                validator: DoubleValidator {
                    top: gammaG.to
                    bottom: gammaG.from
                    decimals: 7;
                    locale: "en"
                    notation: DoubleValidator.StandardNotation
                }
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("B:")
            Layout.fillHeight: true
            Layout.fillWidth: true
            Slider {
                id: gammaB
                snapMode: Slider.SnapOnRelease
                stepSize: -0.1
                from : 0.1
                to: 10
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 2
            }
            TextField {
                text: gammaB.value.toFixed(7)
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                onEditingFinished: {
                    gammaB.value = parseFloat(text)
                }
                validator: DoubleValidator {
                    top: gammaB.to
                    bottom: gammaB.from
                    decimals: 7;
                    locale: "en"
                    notation: DoubleValidator.StandardNotation
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Mode")
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 4

            ComboBox {
                id: modeCombo
                textRole: "text"
                model: ListModel {
                    ListElement {
                        text: 'Auto'
                        val: ''
                    }
                    ListElement {
                        text: 'drm'
                        val: 'drm'
                    }
                    ListElement {
                        text: 'randr'
                        val: 'randr'
                    }
                    ListElement {
                        text: 'vidmode'
                        val: 'vidmode'
                    }
                    ListElement {
                        text: 'Manual'
                        val: 'MANUAL'
                    }
                }
                onCurrentIndexChanged: {
                    cfg_renderMode = model.get(currentIndex).val
                    print('saved: ' + cfg_renderMode)
                    modeChanged()
                }
            } // col 2
            TextField {
                id: renderModeScreen
                placeholderText: i18n("Screen")
                visible: isMode([
                    'randr',
                    'vidmode'
                ])
                onTextChanged: modeChanged()
            }
            TextField {
                id: renderModeCard
                placeholderText: i18n("Card")
                visible: isMode([
                    'drm',
                    'card'
                ])
                onTextChanged: modeChanged()
            }
            TextField {
                id: fakeTextField
                opacity: 0
                visible: !renderModeScreen.visible && !renderModeCard.visible
            } // col 2
            TextField {
                id: renderModeCrtc
                width: advancedConfig / 8
                placeholderText: i18n("CRTC")
                opacity: isMode([
                    'drm',
                    'randr'
                ])
                    ? 1
                    : 0
                onTextChanged: modeChanged()
            } // col 4
            CheckBox {
                id: preserveScreenColour
                text: i18n("Preserve screen colour")
                opacity: isMode([
                    'randr',
                    'vidmode'
                ])
                    ? 1
                    : 0
                enabled: parseFloat(versionString) >= 1.11
                onCheckedChanged: modeChanged()
            }
            TextField {
                id: modeString
                placeholderText: i18n("Insert custom mode options")
                Layout.columnSpan: parent.columns
                Layout.fillWidth: true
                //Layout.preferredWidth : parent.width - 5
                enabled: isMode([
                    'MANUAL'
                ])
                visible: !isMode([
                    ''
                ])
                onTextChanged: cfg_renderModeString = text
            }

            RowLayout {
                Layout.columnSpan: parent.columns
                spacing: 2
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Redshift version:")
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
                Label {
                    text: versionString
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }


    function modeChanged() {
        switch (cfg_renderMode) {
            case 'drm':
                modeString.text = '-m drm' + (renderModeCard.text.length > 0 ? ':card=' + renderModeCard.text : '') + (renderModeCrtc.text.length > 0 ? ':crtc=' + renderModeCrtc.text : '')
                break
            case 'randr':
                modeString.text = '-m randr' + (renderModeScreen.text.length > 0 ? ':screen=' + renderModeScreen.text : '') + (renderModeCrtc.text.length > 0 ? ':crtc=' + renderModeCrtc.text : '') + (preserveScreenColour.enabled && preserveScreenColour.checked ? ':preserve=1' : '')
                break
            case 'vidmode':
                modeString.text = '-m vidmode' + (renderModeScreen.text.length > 0 ? ':screen=' + renderModeScreen.text : '') + (preserveScreenColour.enabled && preserveScreenColour.checked ? ':preserve=1' : '')
                break
            default:
                modeString.text = ''
        }
        cfg_renderModeString = modeString.text
    }

    function isMode(modes) {
        var currentMode = modeCombo.model.get(modeCombo.currentIndex).val
        return modes.some(function (iterMode) {
            return currentMode === iterMode
        })
    }

    Plasma5Support.DataSource {
        id: getOptionsDS
        engine: 'executable'

        connectedSources: ['redshift -V']

        onNewData: (sourceName, data) => {
            connectedSources.length = 0
            if (data['exit code'] > 0) {
                print('Error running redshift with command: ' + sourceName + '   ...stderr: ' + data.stderr)
                return
            }
            versionString = data.stdout.split(' ')[1]
        }
    }

}
