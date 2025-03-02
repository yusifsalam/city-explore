import SwiftUI

@main
struct CityExploreApp: App {
    @Environment(\.openURL) private var openURL
    @State private var locationManager = LocationManager()
    var body: some Scene {
        WindowGroup {
            if locationManager.isAuthorized {
                ContentView()
            } else {
                ContentUnavailableView {
                    Label("Location Services Not Enabled", systemImage: "exclamationmark.triangle")
                    
                    Button("Open App Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
            }
            
        }
        .environment(locationManager)
    }
    
}

