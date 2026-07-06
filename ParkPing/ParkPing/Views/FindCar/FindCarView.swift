import SwiftUI
import SwiftData
import MapKit
import CoreLocation

struct FindCarView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate { $0.statusRaw == "active" }, sort: \ParkingSession.startTime, order: .reverse) private var activeSessions: [ParkingSession]
    @StateObject private var locationManager = LocationManager.shared

    var body: some View {
        NavigationStack {
            Group {
                if let session = activeSessions.first, session.latitude != nil, session.longitude != nil {
                    mapView(for: session)
                } else {
                    emptyState
                }
            }
            .navigationTitle("Find My Car")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func mapView(for session: ParkingSession) -> some View {
        let coordinate = CLLocationCoordinate2D(
            latitude: session.latitude ?? 0,
            longitude: session.longitude ?? 0
        )

        return VStack(spacing: 0) {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))) {
                Marker("Your Car", coordinate: coordinate)
                    .tint(Color.parkPrimary)
            }
            .clipShape(RoundedRectangle(cornerRadius: ParkTheme.cornerRadius))
            .padding()

            VStack(spacing: 12) {
                if let locationName = session.locationName {
                    Label(locationName, systemImage: "mappin.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    openDirections(coordinate: coordinate)
                } label: {
                    Label("Get Directions", systemImage: "location.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.parkPrimary)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
                .padding(.bottom)
                .accessibilityLabel("Get directions to your car")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Location Saved")
                .font(.headline)

            Text("Save your parking location from the timer screen to find your car here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func openDirections(coordinate: CLLocationCoordinate2D) {
        let url = URL(string: "maps://?daddr=\(coordinate.latitude),\(coordinate.longitude)")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
