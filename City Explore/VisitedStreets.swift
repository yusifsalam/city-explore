import SwiftUI
import MapKit

struct VisitedStreets: View {
    let streetSegments = [
        // First street
        StreetSegment(
            name: "Fabianinkatu",
            coordinates: [
                CLLocationCoordinate2D(latitude: 60.169887, longitude: 24.949241),
                CLLocationCoordinate2D(latitude: 60.168990, longitude: 24.949335),
            ],
            isVisited: true
        ),
        // Second street
        StreetSegment(
            name: "Yliopistonkatu",
            coordinates: [
                CLLocationCoordinate2D(latitude: 60.169833, longitude: 24.947316),
                CLLocationCoordinate2D(latitude: 60.169887, longitude: 24.949241),
            ],
            isVisited: false
        ),
    ]
    
    // Initial map position centered on sample data
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 60.169801, longitude: 24.949062),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    )
    
    var body: some View {
        Map(position: $position) {
            // Add polylines for each street segment
            ForEach(streetSegments) { segment in
                MapPolyline(coordinates: segment.coordinates)
                    .stroke(segment.isVisited ? .green : .red, lineWidth: 4)
                    .mapOverlayLevel(level: .aboveRoads)
            }
            Marker("R",coordinate: CLLocationCoordinate2D(latitude: 60.169801, longitude: 24.949062))
        }
        .mapStyle(.standard)
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Text("Streets visited: \(visitedCount)/\(streetSegments.count)")
                    .font(.headline)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
    }
    
    var visitedCount: Int {
        streetSegments.filter { $0.isVisited }.count
    }
}

// Simple model for street segments
struct StreetSegment: Identifiable {
    let id = UUID()
    let name: String
    let coordinates: [CLLocationCoordinate2D]
    var isVisited: Bool
}

#Preview {
    VisitedStreets()
}
