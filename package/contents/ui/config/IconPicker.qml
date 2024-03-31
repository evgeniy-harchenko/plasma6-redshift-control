/*
    SPDX-FileCopyrightText: 2015 Martin Kotelnik <clearmartin@seznam.cz>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.iconthemes as KIconThemes
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami

// basically taken from kickoff
Button {
    id: iconButton

    property string currentIcon
    property string defaultIcon

    signal iconChanged(string iconName)

    Layout.minimumWidth: previewFrame.width + Kirigami.Units.smallSpacing
    Layout.maximumWidth: Layout.minimumWidth
    Layout.minimumHeight: previewFrame.height + Kirigami.Units.smallSpacing
    Layout.maximumHeight: Layout.minimumHeight

    implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing
    implicitHeight: implicitWidth
    hoverEnabled: true

    KIconThemes.IconDialog {
        id: iconDialog
        onIconNameChanged: {
            iconPreview.source = iconName
            iconChanged(iconName)
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

    KSvg.FrameSvgItem {
        id: previewFrame
        anchors.centerIn: parent
        width: Kirigami.Units.iconSizes.medium + fixedMargins.left + fixedMargins.right
        height: width
        imagePath: plasmoid.location === PlasmaCore.Types.Vertical || plasmoid.location === PlasmaCore.Types.Horizontal
                    ? "widgets/panel-background" : "widgets/background"

        Kirigami.Icon {
            id: iconPreview
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.medium
            height: width
            source: currentIcon
        }
    }

    function setDefaultIcon() {
        iconPreview.source = defaultIcon
        iconChanged(defaultIcon)
    }

    // QQC Menu can only be opened at cursor position, not a random one


    Menu {
        id: iconMenu
        y: +parent.height

        MenuItem {
            text: i18nc("@item:inmenu Open icon chooser dialog", "Choose...")
            icon.name: "document-open-folder"
            onClicked: iconDialog.open()
        }

        MenuItem {
            text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
            icon.name: "edit-clear"
            onClicked: setDefaultIcon()
        }
    }
}
