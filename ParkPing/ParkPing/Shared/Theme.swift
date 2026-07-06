import SwiftUI

enum ParkTheme {
    static let primary = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let warning = Color(red: 1.0, green: 0.62, blue: 0.04)
    static let danger = Color(red: 1.0, green: 0.23, blue: 0.19)
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)

    static let cornerRadius: CGFloat = 16
    static let spacing: CGFloat = 8

    static let startButtonHeight: CGFloat = 80
    static let countdownFontSize: CGFloat = 72

    static let freeDurationLimitMinutes = 120
    static let freeActiveTimerLimit = 1
    static let warningThresholdMinutes = 5
}

extension Color {
    static let parkPrimary = ParkTheme.primary
    static let parkWarning = ParkTheme.warning
    static let parkDanger = ParkTheme.danger
    static let parkSuccess = ParkTheme.success
}
