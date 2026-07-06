import SwiftUI

struct SettingsView: View {
    @StateObject private var storeManager = StoreManager.shared
    @State private var showPaywall = false
    @State private var showContactSupport = false

    private let githubUser = "asunnyboy861"
    private let appName = "ParkPing"

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                proSection
                featuresSection
                legalSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showContactSupport) {
                ContactSupportView()
            }
        }
    }

    private var proSection: some View {
        Section {
            if storeManager.isPro {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.parkSuccess)
                    Text("PRO Activated")
                        .font(.headline)
                    Spacer()
                    Text("Thank you!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(Color.parkWarning)
                        VStack(alignment: .leading) {
                            Text("Upgrade to PRO")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Unlock all features for \(storeManager.formattedPrice)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                Task {
                    await storeManager.restorePurchases()
                }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
            }
        } header: {
            Text("ParkPing PRO")
        }
    }

    private var featuresSection: some View {
        Section {
            NavigationLink {
                StreetSweepingView()
            } label: {
                Label("Street Sweeping Reminders", systemImage: "broom.fill")
            }

            NavigationLink {
                AboutLiveActivityView()
            } label: {
                Label("Live Activity & Widget", systemImage: "rectangle.stack.fill")
            }
        } header: {
            Text("Features")
        } footer: {
            Text("Street sweeping reminders and Live Activity require PRO.")
                .font(.caption2)
        }
    }

    private var legalSection: some View {
        Section {
            Button {
                showContactSupport = true
            } label: {
                Label("Contact Support", systemImage: "envelope.fill")
            }

            Link(destination: policyURL("privacy")) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }

            Link(destination: policyURL("terms")) {
                Label("Terms of Use", systemImage: "doc.text.fill")
            }

            Link(destination: policyURL("support")) {
                Label("Support Page", systemImage: "questionmark.circle.fill")
            }
        } header: {
            Text("Support & Legal")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("App Version")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }

            Link(destination: URL(string: "https://github.com/\(githubUser)/\(appName)")!) {
                HStack {
                    Label("View on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("About")
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                Text("ParkPing — Parking Timer & Reminder")
                Text("One tap. One time. No subscription. Ever.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func policyURL(_ page: String) -> URL {
        URL(string: "https://\(githubUser).github.io/\(appName)/\(page).html")!
    }
}

struct AboutLiveActivityView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.parkPrimary)

                Text("Live Activity & Widget")
                    .font(.title2.bold())

                Text("ParkPing shows a live countdown on your Dynamic Island and Lock Screen when a timer is active. Add the home screen widget for quick access.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    FeaturePoint(icon: "circle.dashed", text: "Dynamic Island countdown")
                    FeaturePoint(icon: "lock.fill", text: "Lock Screen timer display")
                    FeaturePoint(icon: "square.grid.2x2.fill", text: "Home screen widget")
                    FeaturePoint(icon: "applewatch", text: "Apple Watch app")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: ParkTheme.cornerRadius))
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Live Activity")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeaturePoint: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.parkPrimary)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

struct StreetSweepingView: View {
    @StateObject private var storeManager = StoreManager.shared
    @AppStorage("sweepingEnabled") private var sweepingEnabled = false
    @AppStorage("sweepingHour") private var sweepingHour = 18
    @AppStorage("sweepingMinute") private var sweepingMinute = 0
    @AppStorage("sweepingDays") private var sweepingDaysData = Data()

    @State private var selectedDays: Set<Int> = []

    var body: some View {
        Form {
            Section {
                Toggle("Enable Reminders", isOn: $sweepingEnabled)
                    .onChange(of: sweepingEnabled) { _, newValue in
                        if storeManager.isPro {
                            updateSchedule()
                        } else {
                            sweepingEnabled = false
                        }
                    }
            } header: {
                Text("Street Sweeping")
            } footer: {
                Text("Get weekly reminders before street sweeping in your area. PRO feature.")
                    .font(.caption2)
            }

            if storeManager.isPro && sweepingEnabled {
                Section {
                    Picker("Reminder Time", selection: $sweepingHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text("\(hour % 12 == 0 ? 12 : hour % 12):00 \(hour < 12 ? "AM" : "PM")")
                                .tag(hour)
                        }
                    }
                    .onChange(of: sweepingHour) { _, _ in updateSchedule() }

                    VStack(alignment: .leading) {
                        Text("Days")
                            .font(.headline)
                            .padding(.top, 8)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(1...7, id: \.self) { day in
                                let dayName = Calendar.current.shortWeekdaySymbols[day - 1]
                                Button {
                                    toggleDay(day)
                                } label: {
                                    Text(dayName)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(selectedDays.contains(day) ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 36)
                                        .background(selectedDays.contains(day) ? Color.parkPrimary : Color(.secondarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .onChange(of: selectedDays) { _, _ in updateSchedule() }
                }
            } else if !storeManager.isPro {
                Section {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(Color.parkWarning)
                        Text("Upgrade to PRO to enable street sweeping reminders.")
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle("Street Sweeping")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSelectedDays()
        }
    }

    private func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
        saveSelectedDays()
    }

    private func loadSelectedDays() {
        if let set = try? JSONDecoder().decode(Set<Int>.self, from: sweepingDaysData) {
            selectedDays = set
        }
    }

    private func saveSelectedDays() {
        if let data = try? JSONEncoder().encode(selectedDays) {
            sweepingDaysData = data
        }
    }

    private func updateSchedule() {
        Task { @MainActor in
            NotificationManager.shared.scheduleStreetSweepingReminder(
                id: "default",
                daysOfWeek: Array(selectedDays),
                hour: sweepingHour,
                minute: sweepingMinute,
                enabled: sweepingEnabled && storeManager.isPro
            )
        }
    }
}
