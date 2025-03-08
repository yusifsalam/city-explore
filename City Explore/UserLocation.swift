import SwiftUI
import MapKit

struct UserLocationView: View {
    @Environment(LocationManager.self) var locationManager
    @State private var position: MapCameraPosition = .automatic
    var body: some View {
        NavigationStack {
            ZStack {
                MapView()
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            locationManager.toggleShowBreadcrumbBounds()
                        }) {
                            Image(systemName: "record.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Record a walk")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if locationManager.isMonitoringLocation {
                            locationManager.stopRecordingLocation()
                        } else {
                            locationManager.startRecordingLocation()
                        }
                    }) {
                        Image(systemName: locationManager.isMonitoringLocation ? "stop.circle.fill" : "record.circle")
                            .foregroundColor(locationManager.isMonitoringLocation ? .red : .primary)
                    }
                }
            }
        }
    }
    
    private func toggleTrackingMode() {
        
    }
}

#Preview {
    UserLocationView()
        .environment(LocationManager())
}
