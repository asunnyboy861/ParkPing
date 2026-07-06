import ActivityKit
import SwiftUI
import WidgetKit

struct ParkPingWidgetEntry: TimelineEntry {
    let date: Date
    let isRunning: Bool
    let remainingMinutes: Int
    let totalMinutes: Int
    let isWarning: Bool
    let isExpired: Bool
}

struct ParkPingWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ParkPingWidgetEntry {
        ParkPingWidgetEntry(
            date: Date(),
            isRunning: true,
            remainingMinutes: 45,
            totalMinutes: 120,
            isWarning: false,
            isExpired: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ParkPingWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ParkPingWidgetEntry>) -> Void) {
        let entry = ParkPingWidgetEntry(
            date: Date(),
            isRunning: false,
            remainingMinutes: 0,
            totalMinutes: 0,
            isWarning: false,
            isExpired: false
        )
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct ParkPingWidgetView: View {
    let entry: ParkPingWidgetEntry

    var body: some View {
        ZStack {
            if entry.isRunning {
                VStack(spacing: 6) {
                    HStack {
                        Image(systemName: entry.isExpired ? "exclamationmark.octagon.fill" : "car.fill")
                            .font(.caption)
                            .foregroundStyle(entry.isExpired ? .red : (entry.isWarning ? .orange : .blue))
                        Spacer()
                        Text(entry.isExpired ? "Expired" : (entry.isWarning ? "Ending" : "Parked"))
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                    }

                    Text(formatRemaining(entry.remainingMinutes))
                        .font(.title.monospacedDigit().bold())
                        .foregroundStyle(entry.isExpired ? .red : (entry.isWarning ? .orange : .primary))

                    ProgressView(value: progressValue(entry))
                        .tint(entry.isExpired ? .red : (entry.isWarning ? .orange : .blue))
                }
                .padding(12)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "parkingsign")
                        .font(.title)
                        .foregroundStyle(.blue)
                    Text("No Active Timer")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text("Open ParkPing")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(12)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func progressValue(_ entry: ParkPingWidgetEntry) -> Double {
        guard entry.totalMinutes > 0 else { return 0 }
        let elapsed = Double(entry.totalMinutes - entry.remainingMinutes)
        return min(1.0, max(0.0, elapsed / Double(entry.totalMinutes)))
    }

    private func formatRemaining(_ minutes: Int) -> String {
        let total = max(0, minutes)
        let hours = total / 60
        let mins = total % 60

        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}

struct ParkPingWidget: Widget {
    let kind: String = "ParkPingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ParkPingWidgetProvider()) { entry in
            ParkPingWidgetView(entry: entry)
        }
        .configurationDisplayName("ParkPing")
        .description("Quick view of your active parking timer.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ParkPingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ParkingActivityAttributes.self) { context in
            ParkingLiveActivityView(context: context)
                .padding(.horizontal, 8)
                .activityBackgroundTint(backgroundColor(context.state))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ParkingDynamicIslandExpanded(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ParkingDynamicIslandCompactTrailing(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.isExpired ? "Move your car now" : (context.state.isWarning ? "Head back soon" : "Timer running"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            } compactLeading: {
                ParkingDynamicIslandCompactLeading(context: context)
            } compactTrailing: {
                ParkingDynamicIslandCompactTrailing(context: context)
            } minimal: {
                ParkingDynamicIslandMinimal(context: context)
            }
        }
    }

    private func backgroundColor(_ state: ParkingActivityAttributes.ContentState) -> Color {
        if state.isExpired { return Color(red: 1.0, green: 0.231, blue: 0.188) }
        if state.isWarning { return Color(red: 1.0, green: 0.62, blue: 0.039) }
        return Color(red: 0.0, green: 0.478, blue: 1.0)
    }
}

struct ParkPingWidgetBundle: WidgetBundle {
    var body: some Widget {
        ParkPingWidget()
        ParkPingLiveActivity()
    }
}
