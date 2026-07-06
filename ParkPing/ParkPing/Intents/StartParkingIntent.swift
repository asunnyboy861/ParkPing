import AppIntents
import SwiftUI

struct StartParkingIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Parking Timer"
    static var description = IntentDescription("Start a parking timer for the specified duration in minutes.")

    static var openAppWhenRun: Bool = true

    @Parameter(title: "Duration (minutes)", default: 120, inclusiveRange: (1, 1440))
    var durationMinutes: Int

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .startParkingFromIntent,
                object: nil,
                userInfo: ["durationMinutes": durationMinutes]
            )
        }
        return .result()
    }
}

struct ParkPingShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartParkingIntent(),
            phrases: [
                "I parked with \(.applicationName)",
                "Start parking timer with \(.applicationName)",
                "Start a \(.applicationName) timer"
            ],
            shortTitle: "Start Parking Timer",
            systemImageName: "parkingsign"
        )
    }
}

extension Notification.Name {
    static let startParkingFromIntent = Notification.Name("startParkingFromIntent")
}
