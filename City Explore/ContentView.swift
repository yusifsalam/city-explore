import SwiftUI
import MapKit

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $position)
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .task {
                locationManager.requestLocationAuthorization()
                locationManager.startMonitoringLocationStatus()
                await locationManager.updateLocation()
            }
            .onDisappear {
                locationManager.stopMonitoringLocationStatus()
            }
    }
}

#Preview {
    ContentView()
}
