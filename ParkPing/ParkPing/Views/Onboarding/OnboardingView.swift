import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "car.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.parkPrimary)

                Text("ParkPing")
                    .font(.largeTitle.bold())

                Text("Parking Timer & Reminder")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                OnboardingFeature(
                    icon: "hand.tap.fill",
                    title: "One Tap to Start",
                    description: "No account. No setup. Just tap START."
                )
                OnboardingFeature(
                    icon: "bell.badge.fill",
                    title: "Smart Reminders",
                    description: "Get notified 5 minutes before your meter expires."
                )
                OnboardingFeature(
                    icon: "creditcard.fill",
                    title: "No Subscription. Ever.",
                    description: "Free to use. PRO is a one-time $3.99 purchase."
                )
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 8) {
                Button {
                    onComplete()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.parkPrimary)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 32)

                Text("No account needed • No tracking • No ads")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
    }
}

struct OnboardingFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.parkPrimary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}
