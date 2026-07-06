import Foundation
import SwiftData
import ActivityKit
import UIKit
import CoreLocation

@MainActor
@Observable
final class TimerEngine {
    private var modelContext: ModelContext?
    private var currentSession: ParkingSession?
    private var currentActivity: Activity<ParkingActivityAttributes>?
    private var timer: Timer?
    private var liveActivityUpdateTimer: Timer?

    var remainingTimeString: String = "00:00"
    var isRunning: Bool = false
    var currentSessionId: UUID?
    var showUpgradeAlert: Bool = false
    var upgradeReason: String = ""

    private let storeManager = StoreManager.shared
    private let notificationManager = NotificationManager.shared

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        restoreActiveSessionIfNeeded()
    }

    private func restoreActiveSessionIfNeeded() {
        guard let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<ParkingSession>(
            predicate: #Predicate { $0.statusRaw == "active" }
        )

        if let sessions = try? modelContext.fetch(descriptor),
           let activeSession = sessions.first {
            currentSession = activeSession
            currentSessionId = activeSession.id
            isRunning = true
            startTimer()

            if activeSession.isExpired {
                handleExpiry()
            }
        }
    }

    func startParking(durationMinutes: Int, location: CLLocation? = nil) -> Bool {
        guard !isRunning else { return false }

        if !storeManager.isPro {
            if durationMinutes > ParkTheme.freeDurationLimitMinutes {
                showUpgradeAlert = true
                upgradeReason = "Free version supports timers up to \(ParkTheme.freeDurationLimitMinutes / 60) hour\(ParkTheme.freeDurationLimitMinutes / 60 == 1 ? "" : "s"). Upgrade to PRO for unlimited duration."
                Haptics.warning()
                return false
            }
        }

        guard let modelContext = modelContext else { return false }

        let session = ParkingSession(
            durationMinutes: durationMinutes,
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude
        )

        modelContext.insert(session)
        try? modelContext.save()

        currentSession = session
        currentSessionId = session.id

        notificationManager.scheduleNotifications(for: session)
        startLiveActivity(for: session)
        startTimer()

        isRunning = true
        Haptics.medium()

        return true
    }

    func stopParking() {
        guard let session = currentSession else { return }

        session.endTime = Date()
        session.status = .completed
        try? modelContext?.save()

        notificationManager.cancelNotifications(for: session.id)
        endLiveActivity()

        timer?.invalidate()
        timer = nil
        liveActivityUpdateTimer?.invalidate()
        liveActivityUpdateTimer = nil

        currentSession = nil
        currentSessionId = nil
        isRunning = false
        remainingTimeString = "00:00"

        Haptics.success()
    }

    func cancelParking() {
        guard let session = currentSession else { return }

        session.endTime = Date()
        session.status = .cancelled
        try? modelContext?.save()

        notificationManager.cancelNotifications(for: session.id)
        endLiveActivity()

        timer?.invalidate()
        timer = nil
        liveActivityUpdateTimer?.invalidate()
        liveActivityUpdateTimer = nil

        currentSession = nil
        currentSessionId = nil
        isRunning = false
        remainingTimeString = "00:00"
    }

    var currentSessionValue: ParkingSession? {
        currentSession
    }

    var remainingTime: TimeInterval {
        currentSession?.remainingTime ?? 0
    }

    var isWarning: Bool {
        currentSession?.isWarning ?? false
    }

    var isExpired: Bool {
        currentSession?.isExpired ?? false
    }

    var progress: Double {
        currentSession?.progress ?? 0
    }

    var totalDurationMinutes: Int {
        currentSession?.durationMinutes ?? 0
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateRemainingTime()
            }
        }

        liveActivityUpdateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateLiveActivity()
            }
        }

        updateRemainingTime()
        updateLiveActivity()
    }

    private func updateRemainingTime() {
        guard let session = currentSession else {
            remainingTimeString = "00:00"
            return
        }

        let remaining = session.remainingTime
        remainingTimeString = ParkingSession.formatRemaining(remaining)

        if session.isExpired {
            handleExpiry()
        }
    }

    private func handleExpiry() {
        guard let session = currentSession, session.status != .expired else { return }

        session.status = .expired
        try? modelContext?.save()

        Haptics.error()

        updateLiveActivity()
    }

    private func startLiveActivity(for session: ParkingSession) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = ParkingActivityAttributes(
            sessionStartDate: session.startTime,
            totalDurationMinutes: session.durationMinutes
        )

        let totalSeconds = session.durationMinutes * 60
        let initialState = ParkingActivityAttributes.ContentState(
            remainingSeconds: Int(session.remainingTime),
            totalSeconds: totalSeconds,
            isWarning: false,
            isExpired: false
        )

        Task {
            do {
                currentActivity = try Activity.request(
                    attributes: attributes,
                    content: .init(state: initialState, staleDate: session.expiresAt),
                    pushType: nil
                )
            } catch {
            }
        }
    }

    private func updateLiveActivity() {
        guard let activity = currentActivity,
              let session = currentSession else { return }

        let totalSeconds = session.durationMinutes * 60
        let newState = ParkingActivityAttributes.ContentState(
            remainingSeconds: Int(session.remainingTime),
            totalSeconds: totalSeconds,
            isWarning: session.isWarning,
            isExpired: session.isExpired
        )

        Task {
            await activity.update(.init(state: newState, staleDate: session.expiresAt))
        }
    }

    private func endLiveActivity() {
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
