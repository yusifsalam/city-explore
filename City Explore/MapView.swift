import SwiftUI
import MapKit

struct MapView: View {
    @Environment(LocationManager.self) private var locationManager
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var mapStyle: MapStyle = .standard
    @State private var isFollowingUser = true
    
    var body: some View {
        Map(position: $position) {
            
            // Add breadcrumb path as a MapPolyline
            if let breadcrumbs = locationManager.breadcrumbs {
                MapPolyline(coordinates: breadcrumbs.locations.map { $0.coordinate })
                        .stroke(.blue, lineWidth: 4)
                
                // Add breadcrumb bounds if needed
                if locationManager.showBreadcrumbBounds {
                    MapPolygon(coordinates: createBoundingPolygon(from: breadcrumbs.pathBounds))
                        .stroke(.blue, lineWidth: 2)
                        .foregroundStyle(.blue.opacity(0.25))
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onChange(of: locationManager.location) { oldValue, newValue in
            guard let location = newValue, locationManager.isMonitoringLocation else { return }
            
            // Add location to breadcrumbs
            if let breadcrumbs = locationManager.breadcrumbs {
                breadcrumbs.addLocation(location)
                
                // If this is the first location, set the map position
                if breadcrumbs.locations.count == 1 {
                    position = .region(MKCoordinateRegion(
                        center: location.coordinate,
                        latitudinalMeters: 1000,
                        longitudinalMeters: 1000
                    ))
                    isFollowingUser = true
                } else if isFollowingUser {
                    // Keep following user if that mode is active
                    position = .userLocation(followsHeading: true, fallback: .automatic)
                }
            }
        }
        .onAppear {
            // Initial setup
            if let location = locationManager.location {
                position = .region(MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                ))
            } else {
                position = .userLocation(followsHeading: true, fallback: .automatic)
            }
        }
    }
    
    // Helper function to create a polygon from MKMapRect
    private func createBoundingPolygon(from rect: MKMapRect) -> [CLLocationCoordinate2D] {
        return [
            MKMapPoint(x: rect.minX, y: rect.minY).coordinate,
            MKMapPoint(x: rect.minX, y: rect.maxY).coordinate,
            MKMapPoint(x: rect.maxX, y: rect.maxY).coordinate,
            MKMapPoint(x: rect.maxX, y: rect.minY).coordinate,
            MKMapPoint(x: rect.minX, y: rect.minY).coordinate // Close the polygon
        ]
    }
}

// Extension to get coordinates from BreadcrumbPath
extension BreadcrumbPath {
    var coordinates: [CLLocationCoordinate2D] {
        return locations.map { $0.coordinate }
    }
}
