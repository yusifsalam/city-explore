import CoreLocation
import MapKit
import OSLog

@MainActor
@Observable
public final class LocationManager {
    private let logger = Logger(subsystem: "fi.yusif.CityExplore", category: "LocationManager")
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
            logger.info("Requesting location authorization")
        }
    }
    
    public func updateLocationAuthorizationStatus() {
        locationsStatus = manager.authorizationStatus
    }
    
    public func startMonitoringLocationStatus() {
        let initialStatus = locationsStatus
        logger.info("Starting location status monitoring")
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
        logger.info("Stopping location status monitoring")
        monitoringTask?.cancel()
    }
    
    public func updateLocation() async {
        requestLocationAuthorization()
        let updates = CLLocationUpdate.liveUpdates()
        do {
            for try await update in updates {
                if let location = update.location {
                    self.location = location
                    logger.notice("Location updated")
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
                    logger.notice("Current location found")
                    return location
                }
            }
        } catch {
            logger.error("Could not get current location")
        }
        return nil
    }
}
