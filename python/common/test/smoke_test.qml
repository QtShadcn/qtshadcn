import QtQuick
import QtShadcn

Item {
    property bool screenshotMode: ThemeManager.screenshotMode()

    QtShadcnTheme { id: theme }
    ShadcnButton { text: "Smoke test" }
    ShadcnAlert { variant: ShadcnAlert.Warning }
    ShadcnAlert { variant: ShadcnAlert.Success }
    ShadcnCard {}
    ShadcnSelect { model: ["First", "Second"] }
    ShadcnPopoverContent {}
    ShadcnDropdownMenuContent {}

    Component.onCompleted: theme.mode = "dark"
}
