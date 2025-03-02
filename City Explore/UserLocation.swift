import SwiftUI
import MapKit

struct UserLocationView: View {
    @Environment(LocationManager.self) var locationManager
    @State private var position: MapCameraPosition = .automatic
    var body: some View {
        Map(position: $position)
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
    }
}
