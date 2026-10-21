pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ComboBox {
    id: root

    readonly property bool inSettings: {
        var win = root.QsWindow ? root.QsWindow.window : null;
        if (win && win.isSettingsWindow)
            return true;
        var p = root.parent;
        var depth = 0;
        while (p && depth < 20) {
            if (p.isSettingsScope || p.isSettingsWindow || p.inSettings)
                return true;
            p = p.parent;
            depth++;
        }
        return false;
    }
    readonly property bool isSettingsScope: inSettings
    readonly property bool applyWuWa: SettingsTheme.isWuWa && inSettings

    hoverEnabled: true

    property string buttonIcon: ""
    // Optional role containing a desktop-entry icon name/path. Keeping this
    // opt-in preserves the Material Symbol treatment used by existing lists,
    // while allowing app pickers to show the real application artwork.
    property string iconSourceRole: ""
    property string iconSourceFallback: "image-missing"
    property real popupWidth: 0
    property bool iconOnly: false
    property real buttonRadius: Appearance.rounding.full
    property real topLeftRadius: buttonRadius
    property real topRightRadius: buttonRadius
    property real bottomLeftRadius: buttonRadius
    property real bottomRightRadius: buttonRadius

    property color colBackground: applyWuWa ? SettingsTheme.colControlBg : Appearance.colors.colSecondaryContainer
    property color colBackgroundHover: applyWuWa ? SettingsTheme.colControlBgHover : Appearance.colors.colSecondaryContainerHover
    property color colBackgroundActive: applyWuWa ? SettingsTheme.colControlBgActive : Appearance.colors.colSecondaryContainerActive

    opacity: root.enabled ? 1 : 0.4
    implicitHeight: 40
    Layout.fillWidth: true

    Behavior on opacity {
        animation: Appearance.animation.elementResize.numberAnimation.createObject(this)
    }

    background: Rectangle {
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
        color: (root.down && !root.popup.visible) ? root.colBackgroundActive : root.hovered ? root.colBackgroundHover : root.colBackground
        border.width: root.applyWuWa ? 1 : 0
        border.color: root.applyWuWa ? (root.activeFocus || root.popup.visible ? SettingsTheme.colBorderFocused : SettingsTheme.colControlBorder) : "transparent"

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
        Behavior on border.color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    indicator: MaterialSymbol {
        visible: !root.iconOnly
        x: root.width - width - 16
        y: root.height / 2 - height / 2
        text: "keyboard_arrow_down"
        iconSize: Appearance.font.pixelSize.larger
        color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnSecondaryContainer

        rotation: root.popup.visible ? 180 : 0
        Behavior on rotation {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
    }

    contentItem: Item {
        implicitWidth: buttonLayout.implicitWidth
        implicitHeight: buttonLayout.implicitHeight

        RowLayout {
            id: buttonLayout
            anchors.fill: parent
            spacing: 8
            anchors.leftMargin: root.iconOnly ? 12 : 16
            anchors.rightMargin: root.iconOnly ? 12 : 16

            Loader {
                Layout.alignment: root.iconOnly ? Qt.AlignHCenter : Qt.AlignVCenter
                active: root.buttonIcon.length > 0
                    || (root.currentIndex >= 0
                        && typeof root.model[root.currentIndex] === 'object'
                        && (root.iconSourceRole.length === 0
                            || String(root.model[root.currentIndex]?.[root.iconSourceRole] ?? "").length === 0)
                        && !!root.model[root.currentIndex]?.icon)
                visible: active
                sourceComponent: MaterialSymbol {
                    text: {
                        if (root.currentIndex >= 0 && typeof root.model[root.currentIndex] === 'object' && !!root.model[root.currentIndex]?.icon) {
                            return root.model[root.currentIndex].icon;
                        }
                        return root.buttonIcon;
                    }
                    iconSize: Appearance.font.pixelSize.larger
                    color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnSecondaryContainer
                }
            }

            Loader {
                Layout.alignment: root.iconOnly ? Qt.AlignHCenter : Qt.AlignVCenter
                Layout.preferredWidth: Appearance.font.pixelSize.larger
                Layout.preferredHeight: Appearance.font.pixelSize.larger
                active: root.iconSourceRole.length > 0
                    && root.currentIndex >= 0
                    && typeof root.model[root.currentIndex] === "object"
                    && String(root.model[root.currentIndex]?.[root.iconSourceRole] ?? "").length > 0
                visible: active

                sourceComponent: IconImage {
                    source: Quickshell.iconPath(
                        String(root.model[root.currentIndex]?.[root.iconSourceRole] ?? ""),
                        root.iconSourceFallback
                    )
                }
            }

            StyledText {
                Layout.fillWidth: true
                visible: !root.iconOnly
                Layout.alignment: Qt.AlignVCenter
                color: root.applyWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnSecondaryContainer
                text: root.displayText
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                animateChange: true
                animationDistanceY: 8
            }
        }
    }

    delegate: ItemDelegate {
        id: itemDelegate
        width: ListView.view ? ListView.view.width : root.width
        height: 40
        implicitHeight: 40

        required property var model
        required property int index
        property color color: {
            if (root.applyWuWa) {
                if (root.currentIndex === itemDelegate.index) {
                    if (itemDelegate.down) return Qt.darker(SettingsTheme.colOptionSelected, 1.15);
                    if (itemDelegate.hovered) return Qt.lighter(SettingsTheme.colOptionSelected, 1.08);
                    return SettingsTheme.colOptionSelected;
                } else {
                    if (itemDelegate.down) return ColorUtils.applyAlpha(SettingsTheme.colAccent, 0.20);
                    if (itemDelegate.hovered) return ColorUtils.applyAlpha(SettingsTheme.colRowHover, 0.70);
                    return "transparent";
                }
            } else {
                if (root.currentIndex === itemDelegate.index) {
                    if (itemDelegate.down) return Appearance.colors.colSecondaryContainerActive;
                    if (itemDelegate.hovered) return Appearance.colors.colSecondaryContainerHover;
                    return Appearance.colors.colSecondaryContainer;
                } else {
                    if (itemDelegate.down) return Appearance.colors.colLayer3Active;
                    if (itemDelegate.hovered) return Appearance.colors.colLayer3Hover;
                    return ColorUtils.transparentize(Appearance.colors.colLayer3);
                }
            }
        }
        property color colText: root.applyWuWa
            ? ((root.currentIndex === itemDelegate.index) ? SettingsTheme.colOptionOnSelected : SettingsTheme.colTextPrimary)
            : ((root.currentIndex === itemDelegate.index) ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer3)

        background: Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: itemDelegate.color

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
        }

        contentItem: RowLayout {
            spacing: 8
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            Loader {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: Appearance.font.pixelSize.larger
                active: typeof itemDelegate.model === 'object'
                    && (root.iconSourceRole.length === 0
                        || String(itemDelegate.model?.[root.iconSourceRole] ?? "").length === 0)
                    && itemDelegate.model?.icon?.length > 0
                visible: active

                sourceComponent: Item {
                    implicitWidth: icon.implicitWidth
                    implicitHeight: Appearance.font.pixelSize.larger

                    MaterialSymbol {
                        id: icon
                        anchors.centerIn: parent
                        text: itemDelegate.model?.icon ?? ""
                        iconSize: Appearance.font.pixelSize.larger
                        color: itemDelegate.colText
                    }
                }
            }

            Loader {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: Appearance.font.pixelSize.larger
                Layout.preferredHeight: Appearance.font.pixelSize.larger
                active: root.iconSourceRole.length > 0
                    && typeof itemDelegate.model === "object"
                    && String(itemDelegate.model?.[root.iconSourceRole] ?? "").length > 0
                visible: active

                sourceComponent: IconImage {
                    source: Quickshell.iconPath(
                        String(itemDelegate.model?.[root.iconSourceRole] ?? ""),
                        root.iconSourceFallback
                    )
                }
            }

            StyledText {
                Layout.fillWidth: true
                Layout.preferredHeight: Appearance.font.pixelSize.larger
                color: itemDelegate.colText
                text: itemDelegate.model[root.textRole]
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

        }

        StyledToolTip {
            text: itemDelegate.model[root.textRole] || ""
            extraVisibleCondition: itemDelegate.hovered && root.popup.visible
        }
    }

    popup: Popup {
        id: popupRoot
        y: root.height + 4
        width: root.popupWidth > 0 ? root.popupWidth : root.width
        height: Math.min(listView.contentHeight + topPadding + bottomPadding, 300)
        padding: 8

        onOpened: {
            if (root.currentIndex >= 0 && listView) {
                listView.positionViewAtIndex(root.currentIndex, ListView.Center);
            }
        }

        transformOrigin: Item.Top

        enter: Transition {
            SequentialAnimation {
                PropertyAction {
                    target: popupRoot
                    property: "y"
                    value: root.height - 10
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: popupRoot
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Appearance.animation.elementMoveFast.duration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.animationCurves.standardDecel
                    }
                    NumberAnimation {
                        target: popupRoot
                        property: "y"
                        from: root.height - 10
                        to: root.height + 4
                        duration: Appearance.animation.elementMoveFast.duration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.animationCurves.standardDecel
                    }
                }
            }
        }

        exit: Transition {
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        target: popupRoot
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: Appearance.animation.elementMoveFast.duration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.animationCurves.standardAccel
                    }
                    NumberAnimation {
                        target: popupRoot
                        property: "y"
                        from: root.height + 4
                        to: root.height - 10
                        duration: Appearance.animation.elementMoveFast.duration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.animationCurves.standardAccel
                    }
                }
                PropertyAction {
                    target: popupRoot
                    property: "y"
                    value: root.height + 4
                }
            }
        }

        background: Item {
            StyledRectangularShadow {
                target: popupBackground
            }

            Rectangle {
                id: popupBackground
                anchors.fill: parent
                radius: Appearance.rounding.normal
                color: root.applyWuWa ? SettingsTheme.colPopupBg : Appearance.m3colors.m3surfaceContainerHigh
                border.width: root.applyWuWa ? 1 : 0
                border.color: root.applyWuWa ? SettingsTheme.colPopupBorder : "transparent"
            }
        }

        contentItem: StyledListView {
            id: listView
            clip: true
            implicitHeight: contentHeight
            spacing: 2
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            animatePopulate: false
            animateAppearance: false
        }
    }
}
