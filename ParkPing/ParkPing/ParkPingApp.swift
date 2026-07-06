import SwiftUI
import SwiftData

@main
struct ParkPingApp: App {
    @State private var timerEngine = TimerEngine()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: ParkingSession.self,
                configurations: ModelConfiguration(
                    schema: Schema([ParkingSession.self]),
                    isStoredInMemoryOnly: false
                )
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }
            }
            .environment(timerEngine)
            .modelContainer(modelContainer)
            .task {
                timerEngine.configure(modelContext: modelContainer.mainContext)
                _ = StoreManager.shared
                Task.detached {
                    await NotificationManager.shared.requestAuthorization()
                }
            }
        }
    }
}
