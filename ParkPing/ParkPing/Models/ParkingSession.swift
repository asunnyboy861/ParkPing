import Foundation
import SwiftData

@Model
final class ParkingSession {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var durationMinutes: Int
    var statusRaw: String
    var latitude: Double?
    var longitude: Double?
    var locationName: String?
    var photoPath: String?
    var cost: Double?
    var notes: String?
    var createdAt: Date

    enum Status: String, Codable {
        case active
        case completed
        case expired
        case cancelled
    }

    var status: Status {
        get { Status(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    init(
        durationMinutes: Int,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationName: String? = nil
    ) {
        self.id = UUID()
        self.startTime = Date()
        self.endTime = nil
        self.durationMinutes = durationMinutes
        self.statusRaw = Status.active.rawValue
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.photoPath = nil
        self.cost = nil
        self.notes = nil
        self.createdAt = Date()
    }

    var expiresAt: Date {
        startTime.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }

    var remainingTime: TimeInterval {
        max(0, expiresAt.timeIntervalSinceNow)
    }

    var isExpired: Bool {
        Date() >= expiresAt
    }

    var isWarning: Bool {
        let warningThreshold = TimeInterval(ParkTheme.warningThresholdMinutes * 60)
        return !isExpired && remainingTime <= warningThreshold
    }

    var progress: Double {
        guard durationMinutes > 0 else { return 0 }
        let totalSeconds = Double(durationMinutes * 60)
        let elapsed = totalSeconds - remainingTime
        return min(1.0, max(0.0, elapsed / totalSeconds))
    }

    var formattedDuration: String {
        let hours = durationMinutes / 60
        let mins = durationMinutes % 60
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }
}

extension ParkingSession {
    static func formatRemaining(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    static func formatRemainingShort(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "<1m"
        }
    }
}
