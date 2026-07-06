import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }

    func scheduleNotifications(for session: ParkingSession) {
        let sessionId = session.id.uuidString

        let warningTime = session.expiresAt.addingTimeInterval(-TimeInterval(ParkTheme.warningThresholdMinutes * 60))
        if warningTime > Date() {
            let warningContent = UNMutableNotificationContent()
            warningContent.title = "Parking expires in \(ParkTheme.warningThresholdMinutes) minutes"
            warningContent.body = "Time to head back to your car!"
            warningContent.sound = .default
            warningContent.interruptionLevel = .timeSensitive

            let warningTrigger = UNTimeIntervalNotificationTrigger(
                timeInterval: max(1, warningTime.timeIntervalSinceNow),
                repeats: false
            )

            let warningRequest = UNNotificationRequest(
                identifier: "warning-\(sessionId)",
                content: warningContent,
                trigger: warningTrigger
            )

            center.add(warningRequest)
        }

        let expiryContent = UNMutableNotificationContent()
        expiryContent.title = "Parking time expired!"
        expiryContent.body = "Move your car now to avoid a ticket."
        expiryContent.sound = .default
        expiryContent.interruptionLevel = .timeSensitive

        let expiryTrigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, session.expiresAt.timeIntervalSinceNow),
            repeats: false
        )

        let expiryRequest = UNNotificationRequest(
            identifier: "expiry-\(sessionId)",
            content: expiryContent,
            trigger: expiryTrigger
        )

        center.add(expiryRequest)
    }

    func cancelNotifications(for sessionId: UUID) {
        let id = sessionId.uuidString
        center.removePendingNotificationRequests(withIdentifiers: ["warning-\(id)", "expiry-\(id)"])
        center.removeDeliveredNotifications(withIdentifiers: ["warning-\(id)", "expiry-\(id)"])
    }

    func scheduleStreetSweepingReminder(
        id: String,
        daysOfWeek: [Int],
        hour: Int,
        minute: Int,
        enabled: Bool
    ) {
        let identifier = "sweeping-\(id)"

        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        guard enabled, !daysOfWeek.isEmpty else { return }

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "Street Sweeping Reminder"
        content.body = "Street sweeping is tomorrow. Move your car to avoid a ticket!"
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        for day in daysOfWeek {
            var components = dateComponents
            components.weekday = day
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "sweeping-\(id)-\(day)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    func cancelStreetSweepingReminders(id: String) {
        let identifiers = (1...7).map { "sweeping-\(id)-\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
