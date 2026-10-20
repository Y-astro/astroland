import qs.modules.common
import qs.services
import QtQuick
import Quickshell.Services.Notifications

RippleButton {
    id: button
    property string buttonText
    property string urgency

    implicitHeight: 34
    leftPadding: 15
    rightPadding: 15
    buttonRadius: Appearance.rounding.small
    colBackground: (urgency == NotificationUrgency.Critical)
        ? (ResonanceTheme.enabled ? ResonanceTheme.alpha(ResonanceTheme.warningOrange, 0.35) : Appearance.colors.colSecondaryContainer)
        : (ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarItem : Appearance.colors.colLayer4)
    colBackgroundHover: (urgency == NotificationUrgency.Critical)
        ? (ResonanceTheme.enabled ? ResonanceTheme.alpha(ResonanceTheme.warningOrange, 0.50) : Appearance.colors.colSecondaryContainerHover)
        : (ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarItemHover : Appearance.colors.colLayer4Hover)
    colRipple: (urgency == NotificationUrgency.Critical)
        ? (ResonanceTheme.enabled ? ResonanceTheme.alpha(ResonanceTheme.warningOrange, 0.60) : Appearance.colors.colSecondaryContainerActive)
        : (ResonanceTheme.enabled ? ResonanceTheme.bgGlassSidebarItemActive : Appearance.colors.colLayer4Active)
    borderWidth: ResonanceTheme.enabled ? 1 : 0
    borderColor: ResonanceTheme.enabled
        ? ((urgency == NotificationUrgency.Critical) ? ResonanceTheme.warningOrange : ResonanceTheme.borderSidebarItem)
        : Appearance.colors.colOutline

    contentItem: StyledText {
        horizontalAlignment: Text.AlignHCenter
        text: buttonText
        color: (urgency == NotificationUrgency.Critical)
            ? (ResonanceTheme.enabled ? ResonanceTheme.warningOrange : Appearance.m3colors.m3onSurfaceVariant)
            : (ResonanceTheme.enabled ? ResonanceTheme.textPrimary : Appearance.m3colors.m3onSurface)
    }
}