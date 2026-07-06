import SwiftUI
import SwiftData
import CoreLocation

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TimerEngine.self) private var timerEngine
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var locationManager = LocationManager.shared

    @State private var selectedDuration = 120
    @State private var showDurationPicker = false
    @State private var showFindCar = false
    @State private var showPaywall = false
    @State private var showCancelConfirm = false

    private let durationPresets = [60, 120, 240, 480]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if timerEngine.isRunning {
                    activeSessionView
                } else {
                    idleView
                }
            }
            .navigationTitle("ParkPing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if timerEngine.isRunning {
                        Menu {
                            Button {
                                saveLocation()
                            } label: {
                                Label("Save Location", systemImage: "mappin.circle")
                            }

                            Button {
                                showFindCar = true
                            } label: {
                                Label("Find My Car", systemImage: "car.fill")
                            }

                            Divider()

                            Button(role: .destructive) {
                                showCancelConfirm = true
                            } label: {
                                Label("Cancel Timer", systemImage: "xmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showFindCar) {
            FindCarView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .alert("Cancel Timer?", isPresented: $showCancelConfirm) {
            Button("Cancel Timer", role: .destructive) {
                timerEngine.cancelParking()
            }
            Button("Keep Timer", role: .cancel) {}
        } message: {
            Text("This will stop the current parking timer. The session will be saved as cancelled.")
        }
        .alert("Upgrade to PRO", isPresented: Binding(
            get: { timerEngine.showUpgradeAlert },
            set: { timerEngine.showUpgradeAlert = $0 }
        )) {
            Button("Upgrade") {
                showPaywall = true
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(timerEngine.upgradeReason)
        }
        .onReceive(NotificationCenter.default.publisher(for: .startParkingFromIntent)) { notification in
            if let duration = notification.userInfo?["durationMinutes"] as? Int {
                selectedDuration = duration
                if !timerEngine.isRunning {
                    _ = timerEngine.startParking(durationMinutes: duration)
                }
            }
        }
    }

    private var idleView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "car.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.parkPrimary)
                    .accessibilityLabel("ParkPing")

                Text("ParkPing")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                Text("Tap to start parking timer")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("\(selectedDuration / 60)h\(selectedDuration % 60 > 0 ? " \(selectedDuration % 60)m" : "")")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color.parkPrimary)
            }

            Button {
                startTimer()
            } label: {
                Text("START")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: ParkTheme.startButtonHeight)
                    .background(Color.parkPrimary)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)
            .accessibilityLabel("Start parking timer")
            .accessibilityHint("Starts a \(selectedDuration / 60) hour parking timer")

            VStack(spacing: 8) {
                Text("Duration")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                HStack(spacing: 8) {
                    ForEach(durationPresets, id: \.self) { minutes in
                        Button {
                            selectDuration(minutes)
                        } label: {
                            Text(formatPreset(minutes))
                                .font(.subheadline.weight(selectedDuration == minutes ? .bold : .regular))
                                .foregroundStyle(selectedDuration == minutes ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedDuration == minutes ? Color.parkPrimary : Color(.secondarySystemBackground))
                                .clipShape(Capsule())
                        }
                        .accessibilityLabel("Set duration to \(formatPreset(minutes))")
                    }
                }
            }

            Spacer()
        }
    }

    private var activeSessionView: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color(.tertiarySystemFill), lineWidth: 12)
                        .frame(width: 240, height: 240)

                    Circle()
                        .trim(from: 0, to: timerEngine.progress)
                        .stroke(
                            timerEngine.isExpired ? Color.parkDanger :
                            timerEngine.isWarning ? Color.parkWarning :
                            Color.parkPrimary,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: timerEngine.progress)

                    VStack(spacing: 4) {
                        Image(systemName: "car.fill")
                            .font(.title2)
                            .foregroundStyle(
                                timerEngine.isExpired ? Color.parkDanger :
                                timerEngine.isWarning ? Color.parkWarning :
                                Color.parkPrimary
                            )

                        Text(timerEngine.remainingTimeString)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())

                        Text(timerEngine.isExpired ? "EXPIRED" :
                             timerEngine.isWarning ? "Ending Soon" : "Parking")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Parking timer \(timerEngine.remainingTimeString) remaining")
            }

            VStack(spacing: 8) {
                if let session = timerEngine.currentSessionValue {
                    if session.locationName != nil {
                        Label(session.locationName ?? "Location saved", systemImage: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text("Started \(timerEngine.currentSessionValue?.startTime.formatted(date: .omitted, time: .shortened) ?? "")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                timerEngine.stopParking()
            } label: {
                Label("I'm Back", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.parkSuccess)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)
            .accessibilityLabel("I'm back")
            .accessibilityHint("Stops the parking timer and saves the session")
        }
    }

    private func startTimer() {
        let success = timerEngine.startParking(durationMinutes: selectedDuration)
        if success {
            Haptics.light()
        }
    }

    private func selectDuration(_ minutes: Int) {
        selectedDuration = minutes
        Haptics.light()
    }

    private func saveLocation() {
        locationManager.requestPermission()
        locationManager.requestCurrentLocation()

        Task {
            try? await Task.sleep(for: .seconds(2))

            guard let location = locationManager.currentLocation else { return }

            let address = await locationManager.reverseGeocode(location)

            if let session = timerEngine.currentSessionValue {
                session.latitude = location.coordinate.latitude
                session.longitude = location.coordinate.longitude
                session.locationName = address
                try? modelContext.save()
                Haptics.success()
            }
        }
    }

    private func formatPreset(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 && mins > 0 {
            return "\(hours)h\(mins)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }
}
