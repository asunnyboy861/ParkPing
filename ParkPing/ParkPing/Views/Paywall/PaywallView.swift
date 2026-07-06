import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeManager = StoreManager.shared
    @State private var isPurchasing = false
    @State private var purchaseError: String?

    private let githubUser = "asunnyboy861"
    private let appName = "ParkPing"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featureList
                    purchaseSection
                    legalLinks
                }
                .padding()
            }
            .navigationTitle("ParkPing PRO")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.parkWarning)

            Text("Unlock ParkPing PRO")
                .font(.title2.bold())

            Text("One-time purchase. No subscription. Ever.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var featureList: some View {
        VStack(spacing: 12) {
            PaywallFeature(icon: "infinity.circle.fill", title: "Unlimited Timers", description: "No duration cap, multiple active timers")
            PaywallFeature(icon: "circle.dashed.fill", title: "Live Activity", description: "Dynamic Island & Lock Screen countdown")
            PaywallFeature(icon: "square.grid.2x2.fill", title: "Home Screen Widget", description: "Quick start & live countdown")
            PaywallFeature(icon: "applewatch", title: "Apple Watch App", description: "Check remaining time on your wrist")
            PaywallFeature(icon: "mappin.circle.fill", title: "Find My Car", description: "Save location & get directions")
            PaywallFeature(icon: "mic.fill", title: "Siri Integration", description: "\"Hey Siri, I parked\"")
            PaywallFeature(icon: "broom.fill", title: "Street Sweeping Alerts", description: "Weekly reminders to avoid tickets")
            PaywallFeature(icon: "camera.fill", title: "Photo Memory", description: "Snap a photo of your parking spot")
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: ParkTheme.cornerRadius))
    }

    private var purchaseSection: some View {
        VStack(spacing: 12) {
            if let error = purchaseError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.parkDanger)
            }

            Button {
                Task {
                    isPurchasing = true
                    purchaseError = nil
                    let success = await storeManager.purchase()
                    isPurchasing = false
                    if success {
                        Haptics.success()
                        dismiss()
                    }
                }
            } label: {
                Group {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else if storeManager.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        VStack(spacing: 2) {
                            Text("Upgrade for \(storeManager.formattedPrice)")
                                .font(.headline)
                            Text("One-time purchase")
                                .font(.caption)
                        }
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.parkPrimary)
                .clipShape(Capsule())
            }
            .disabled(isPurchasing || storeManager.isLoading)

            Button {
                Task {
                    await storeManager.restorePurchases()
                    if storeManager.isPro {
                        Haptics.success()
                        dismiss()
                    }
                }
            } label: {
                Text("Restore Purchases")
                    .font(.subheadline)
                    .foregroundStyle(Color.parkPrimary)
            }
        }
    }

    private var legalLinks: some View {
        HStack(spacing: 16) {
            Link("Privacy Policy", destination: URL(string: "https://\(githubUser).github.io/\(appName)/privacy.html")!)
                .font(.caption2)
                .foregroundStyle(Color.parkPrimary)

            Link("Terms of Use", destination: URL(string: "https://\(githubUser).github.io/\(appName)/terms.html")!)
                .font(.caption2)
                .foregroundStyle(Color.parkPrimary)
        }
        .padding(.top, 4)
    }
}

struct PaywallFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.parkPrimary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.parkSuccess)
        }
    }
}
