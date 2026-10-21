pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: userHeaderBtn
    implicitHeight: 56
    radius: Appearance.rounding.full
    signal clicked

    property bool isActive: false

    scale: userHeaderMouse.pressed ? 0.95 : (userHeaderMouse.containsMouse ? 1.03 : 1.0)
    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }

    color: isActive
        ? (userHeaderMouse.pressed ? (SettingsTheme.isWuWa ? SettingsTheme.colNavHover : Appearance.colors.colPrimaryActive) : userHeaderMouse.containsMouse ? (SettingsTheme.isWuWa ? SettingsTheme.colNavHover : Appearance.colors.colPrimaryHover) : (SettingsTheme.isWuWa ? SettingsTheme.colAccent : Appearance.colors.colPrimary))
        : (userHeaderMouse.pressed ? (SettingsTheme.isWuWa ? SettingsTheme.colNavHover : Appearance.colors.colLayer2Active) : userHeaderMouse.containsMouse ? (SettingsTheme.isWuWa ? SettingsTheme.colNavHover : Appearance.colors.colLayer2Hover) : (SettingsTheme.isWuWa ? SettingsTheme.colItemBg : Appearance.colors.colLayer2))
    border.width: SettingsTheme.isWuWa ? 1 : 0
    border.color: SettingsTheme.isWuWa ? (userHeaderMouse.containsMouse ? SettingsTheme.colBorderFocused : SettingsTheme.colCardBorder) : "transparent"

    Behavior on color {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    readonly property string _imageStyle: Config.options.userProfile.imageStyle
    readonly property string _customName: Config.options.userProfile.customName
    readonly property string _customGreeting: Config.options.userProfile.customGreeting
    readonly property string _avatarPath: Config.options.userProfile.imagePath

    // Avatar
    Item {
        id: avatarContainer
        anchors {
            left: parent.left
            leftMargin: 6
            verticalCenter: parent.verticalCenter
        }
        width: userHeaderBtn.implicitHeight - 10
        height: userHeaderBtn.implicitHeight - 10

        UserProfileAvatar {
            anchors.fill: parent
            active: GlobalStates.settingsOpen
        }
    }

    // Greeting text
    ColumnLayout {
        id: greetingText
        anchors {
            left: avatarContainer.right
            leftMargin: 10
            right: parent.right
            rightMargin: 14
            verticalCenter: parent.verticalCenter
        }
        spacing: 0

        StyledText {
            text: userHeaderBtn._customGreeting !== "" ? userHeaderBtn._customGreeting : Translation.tr("Hello,")
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: userHeaderBtn.isActive
                ? (SettingsTheme.isWuWa ? SettingsTheme.colNavOnActive : Appearance.colors.colOnPrimary)
                : (SettingsTheme.isWuWa ? SettingsTheme.colTextSecondary : Appearance.colors.colOnLayer1)
            opacity: userHeaderBtn.isActive ? 0.85 : (SettingsTheme.isWuWa ? 0.90 : 0.65)
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        StyledText {
            text: userHeaderBtn._customName !== "" ? userHeaderBtn._customName : SystemInfo.username.toUpperCase()
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.DemiBold
            color: userHeaderBtn.isActive
                ? (SettingsTheme.isWuWa ? SettingsTheme.colNavOnActive : Appearance.colors.colOnPrimary)
                : (SettingsTheme.isWuWa ? SettingsTheme.colTextPrimary : Appearance.colors.colOnLayer1)
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: userHeaderMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: userHeaderBtn.clicked()
    }
}
