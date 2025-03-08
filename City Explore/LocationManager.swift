import CoreLocation
import MapKit
import OSLog

@MainActor
@Observable
public final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let logger = Logger(subsystem: "fi.yusif.CityExplore", category: "LocationManager")
    @ObservationIgnored private let manager = CLLocationManager()
    private var monitoringTask: Task<Void, Never>?
    
    public var location: CLLocation?
    public var locationsStatus: CLAuthorizationStatus = .notDetermined
    public var isAuthorized: Bool = false
    public var breadcrumbs: BreadcrumbPath?
    public var showBreadcrumbBounds = true
    public var isMonitoringLocation = false
    
    override init() {
        super.init()
        manager.delegate = self
        startLocationServices()
    }
    
    func toggleShowBreadcrumbBounds() {
        showBreadcrumbBounds.toggle()
    }
    
    func startLocationServices() {
        logger.info("Starting location services")
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            isAuthorized = true
        } else {
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func startRecordingLocation() {
        breadcrumbs = BreadcrumbPath()
        manager.activityType = .fitness
        manager.pausesLocationUpdatesAutomatically = false
        manager.startUpdatingLocation()
        isMonitoringLocation = true
    }
    
    func stopRecordingLocation() {
        manager.stopUpdatingLocation()
        isMonitoringLocation = false
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
            manager.requestLocation()
        case .notDetermined:
            isAuthorized = false
            manager.requestWhenInUseAuthorization()
        case .denied:
            isAuthorized = false
            logger.error("Location permission denied")
        default:
            isAuthorized = true
            startLocationServices()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error("\(error.localizedDescription)")
    }
    
    
    
}
