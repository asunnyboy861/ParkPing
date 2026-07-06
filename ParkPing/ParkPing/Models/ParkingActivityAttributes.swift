import ActivityKit
import Foundation

struct ParkingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var remainingSeconds: Int
        var totalSeconds: Int
        var isWarning: Bool
        var isExpired: Bool

        var progress: Double {
            guard totalSeconds > 0 else { return 0 }
            let elapsed = Double(totalSeconds - remainingSeconds)
            return min(1.0, max(0.0, elapsed / Double(totalSeconds)))
        }

        var remainingMinutes: Int {
            max(0, remainingSeconds / 60)
        }
    }

    var sessionStartDate: Date
    var totalDurationMinutes: Int
}
