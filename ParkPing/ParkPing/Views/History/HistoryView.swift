import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ParkingSession.startTime, order: .reverse) private var sessions: [ParkingSession]
    @StateObject private var storeManager = StoreManager.shared

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    emptyState
                } else {
                    sessionList
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Parking History")
                .font(.headline)

            Text("Your parking sessions will appear here after you use the timer.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sessionList: some View {
        ScrollView {
            VStack(spacing: 16) {
                statsHeader

                if !storeManager.isPro && sessions.count > 3 {
                    upgradePrompt
                }

                LazyVStack(spacing: 12) {
                    ForEach(groupedSessions, id: \.0) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(group.0)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .padding(.horizontal)

                            ForEach(group.1) { session in
                                SessionRow(session: session)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var statsHeader: some View {
        HStack {
            StatCard(title: "Total Sessions", value: "\(sessions.count)")
            StatCard(title: "Total Time", value: formatTotalTime(sessions))
            StatCard(title: "This Week", value: "\(thisWeekCount)")
        }
        .padding(.horizontal)
    }

    private var upgradePrompt: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .foregroundStyle(Color.parkPrimary)
            Text("Upgrade to PRO to view full history")
                .font(.subheadline.weight(.medium))
            Text("Free version shows recent sessions only.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: ParkTheme.cornerRadius))
        .padding(.horizontal)
    }

    private var groupedSessions: [(String, [ParkingSession])] {
        let calendar = Calendar.current
        let visibleSessions = storeManager.isPro ? sessions : Array(sessions.prefix(3))

        let grouped = Dictionary(grouping: visibleSessions) { session -> String in
            if calendar.isDateInToday(session.startTime) {
                return "Today"
            } else if calendar.isDateInYesterday(session.startTime) {
                return "Yesterday"
            } else {
                return session.startTime.formatted(date: .abbreviated, time: .omitted)
            }
        }

        let order = ["Today", "Yesterday"]
        let orderedGroups = order.compactMap { key in
            grouped[key].map { (key, $0) }
        }

        let dateGroups = grouped
            .filter { !order.contains($0.key) }
            .sorted { lhs, rhs in
                let lhsDate = lhs.value.first?.startTime ?? .distantPast
                let rhsDate = rhs.value.first?.startTime ?? .distantPast
                return lhsDate > rhsDate
            }
            .map { ($0.key, $0.value) }

        return orderedGroups + dateGroups
    }

    private var thisWeekCount: Int {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return sessions.filter { $0.startTime >= weekStart }.count
    }

    private func formatTotalTime(_ sessions: [ParkingSession]) -> String {
        let totalMinutes = sessions.reduce(0) { $0 + $1.durationMinutes }
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        if hours > 0 {
            return "\(hours)h\(mins > 0 ? " \(mins)m" : "")"
        }
        return "\(mins)m"
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color.parkPrimary)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SessionRow: View {
    let session: ParkingSession

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(session.formattedDuration)
                    .font(.subheadline.weight(.medium))

                if let location = session.locationName {
                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text("\(session.startTime.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(session.startTime.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                statusBadge
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: ParkTheme.cornerRadius))
    }

    private var statusColor: Color {
        switch session.status {
        case .active: return .parkPrimary
        case .completed: return .parkSuccess
        case .expired: return .parkDanger
        case .cancelled: return .secondary
        }
    }

    private var statusIcon: String {
        switch session.status {
        case .active: return "car.fill"
        case .completed: return "checkmark.circle.fill"
        case .expired: return "exclamationmark.triangle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }

    private var statusBadge: some View {
        Text(session.status.rawValue.capitalized)
            .font(.caption2.weight(.medium))
            .foregroundStyle(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.1))
            .clipShape(Capsule())
    }
}
