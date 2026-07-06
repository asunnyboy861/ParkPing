import ActivityKit
import SwiftUI
import WidgetKit

struct ParkingLiveActivityView: View {
    let context: ActivityViewContext<ParkingActivityAttributes>

    var body: some View {
        let state = context.state
        let remainingText = formatRemaining(state.remainingSeconds)

        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LinearGradient(
                    colors: gradientColors(for: state),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            HStack(spacing: 12) {
                Image(systemName: state.isExpired ? "exclamationmark.octagon.fill" : "car.fill")
                    .font(.title2)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text(state.isExpired ? "Expired" : (state.isWarning ? "Ending Soon" : "Parked"))
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.9))

                    Text(remainingText)
                        .font(.title2.monospacedDigit().bold())
                        .foregroundStyle(.white)
                }

                Spacer()

                ProgressView(value: state.progress)
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(0.9)
            }
            .padding(.horizontal, 16)
        }
    }

    private func gradientColors(for state: ParkingActivityAttributes.ContentState) -> [Color] {
        if state.isExpired {
            return [Color(red: 1.0, green: 0.231, blue: 0.188), Color(red: 0.85, green: 0.15, blue: 0.12)]
        }
        if state.isWarning {
            return [Color(red: 1.0, green: 0.62, blue: 0.039), Color(red: 0.9, green: 0.5, blue: 0.0)]
        }
        return [Color(red: 0.0, green: 0.478, blue: 1.0), Color(red: 0.0, green: 0.35, blue: 0.85)]
    }

    private func formatRemaining(_ seconds: Int) -> String {
        let total = max(0, seconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%02d:%02d", minutes, secs)
    }
}

struct ParkingDynamicIslandCompactLeading: View {
    let context: ActivityViewContext<ParkingActivityAttributes>

    var body: some View {
        Image(systemName: context.state.isExpired ? "exclamationmark.octagon.fill" : "car.fill")
            .foregroundStyle(context.state.isExpired ? .red : (context.state.isWarning ? .orange : .blue))
    }
}

struct ParkingDynamicIslandCompactTrailing: View {
    let context: ActivityViewContext<ParkingActivityAttributes>

    var body: some View {
        Text(formatRemaining(context.state.remainingSeconds))
            .font(.caption.monospacedDigit().bold())
            .foregroundStyle(context.state.isExpired ? .red : (context.state.isWarning ? .orange : .primary))
    }

    private func formatRemaining(_ seconds: Int) -> String {
        let total = max(0, seconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

struct ParkingDynamicIslandMinimal: View {
    let context: ActivityViewContext<ParkingActivityAttributes>

    var body: some View {
        Image(systemName: context.state.isExpired ? "exclamationmark.octagon.fill" : "timer")
            .foregroundStyle(context.state.isExpired ? .red : (context.state.isWarning ? .orange : .blue))
    }
}

struct ParkingDynamicIslandExpanded: View {
    let context: ActivityViewContext<ParkingActivityAttributes>

    var body: some View {
        let state = context.state

        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Label {
                    Text(state.isExpired ? "Expired" : (state.isWarning ? "Ending Soon" : "Parked"))
                        .font(.caption.bold())
                } icon: {
                    Image(systemName: state.isExpired ? "exclamationmark.octagon.fill" : "car.fill")
                }
                .foregroundStyle(state.isExpired ? .red : (state.isWarning ? .orange : .blue))

                Text(formatRemaining(state.remainingSeconds))
                    .font(.title.monospacedDigit().bold())
            }

            Spacer()

            ProgressView(value: state.progress)
                .progressViewStyle(.circular)
                .tint(state.isExpired ? .red : (state.isWarning ? .orange : .blue))
                .scaleEffect(1.2)
        }
        .padding(8)
    }

    private func formatRemaining(_ seconds: Int) -> String {
        let total = max(0, seconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%02d:%02d", minutes, secs)
    }
}
