import CoreLocation
import MapKit

@MainActor
@Observable
public final class LocationManager {
    private let manager = CLLocationManager()
    private var monitoringTask: Task<Void, Never>?
    
    public var location: CLLocation?
    public var locationsStatus: CLAuthorizationStatus = .notDetermined
    
    public init() {}
    
    public var hasAccess: Bool {
        locationsStatus == .authorizedAlways || locationsStatus == .authorizedWhenInUse
    }
    
    public func requestLocationAuthorization() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    public func updateLocationAuthorizationStatus() {
        locationsStatus = manager.authorizationStatus
    }
    
    public func startMonitoringLocationStatus() {
        let initialStatus = locationsStatus
        monitoringTask = Task {
            while true {
                updateLocationAuthorizationStatus()
                if locationsStatus != initialStatus {
                    break
                }
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }
    
    public func stopMonitoringLocationStatus() {
        monitoringTask?.cancel()
    }
    
    public func updateLocation() async {
        requestLocationAuthorization()
        let updates = CLLocationUpdate.liveUpdates()
        do {
            for try await update in updates {
                if let location = update.location {
                    self.location = location
                    break
                }
            }
        } catch {
        }
    }
    
    public func getCurrentLocation() async -> CLLocation? {
        requestLocationAuthorization()
        let updates = CLLocationUpdate.liveUpdates()
        do {
            for try await update in updates {
                if let location = update.location {
                    self.location = location
                    return location
                }
            }
        } catch {
            print("Could not get location")
        }
        return nil
    }
}
