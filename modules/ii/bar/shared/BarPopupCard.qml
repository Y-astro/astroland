import QtQuick
import QtQuick.Layouts
import qs.modules.common

Rectangle {
    id: root

    property bool hovered: false
    property bool active: false
    property bool low: false
    property bool elevated: false

    radius: BarPopupTheme.radiusCard
    color: active
        ? BarPopupTheme.colCardBackgroundActive
        : (hovered
            ? BarPopupTheme.colCardBackgroundHover
            : (elevated
                ? BarPopupTheme.colCardBackgroundElevated
                : (low ? BarPopupTheme.colCardBackgroundLow : BarPopupTheme.colCardBackground)))

    border.width: (active || hovered) ? 1 : BarPopupTheme.cardBorderWidth
    border.color: (active || hovered) ? BarPopupTheme.colAccent : BarPopupTheme.colCardBorder

    Behavior on color {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }
    Behavior on border.color {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }
}
