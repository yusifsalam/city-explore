import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var selectedTab: Tabs = .visitedStreets
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Visited Streets", systemImage: "figure.walk", value: .visitedStreets) {
                VisitedStreets()
            }
            Tab("User Location", systemImage: "location.fill", value: .userLocation) {
                UserLocationView()
            }
        }
        
    }
}

enum Tabs: Equatable, Hashable, Identifiable {
    
    case visitedStreets
    case userLocation
    
    var id: Self { self }
}

#Preview {
    ContentView()
        .environment(LocationManager())
}
