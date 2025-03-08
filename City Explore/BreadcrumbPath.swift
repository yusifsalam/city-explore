import Foundation
import MapKit
import os

public class BreadcrumbPath: NSObject, MKOverlay {
    private struct BreadcrumbData {
        var locations: [CLLocation]
        var bounds: MKMapRect
        init(locations: [CLLocation] = [], bounds: MKMapRect = MKMapRect.world) {
            self.locations = locations
            self.bounds = bounds
            
        }
    }
    
    public let boundingMapRect: MKMapRect = MKMapRect.world
    private(set) public var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private let protectedBreadcrumbData = OSAllocatedUnfairLock(initialState: BreadcrumbData())
    
    var pathBounds: MKMapRect {
        return protectedBreadcrumbData.withLock { data in
            return data.bounds
        }
    }
    
    var locations: [CLLocation] {
        return protectedBreadcrumbData.withLock { data in
            return data.locations
        }
    }
    
    func addLocation(_ newLocation: CLLocation) -> (locationAdded: Bool, boundingRectChanged: Bool) {
        let result = protectedBreadcrumbData.withLockUnchecked { data in
            guard isNewLocationUsable(newLocation, breadcrumbData: data) else { return (false, false) }
            
            var previousLocation = data.locations.last
            if data.locations.isEmpty {
                coordinate = newLocation.coordinate
                let origin = MKMapPoint(coordinate)
                let oneKilometerInMapPoints = 1000 * MKMapPointsPerMeterAtLatitude(coordinate.latitude)
                let oneSquareKilometer = MKMapSize(width: oneKilometerInMapPoints, height: oneKilometerInMapPoints)
                data.bounds = MKMapRect(origin: origin, size: oneSquareKilometer)
                data.bounds = data.bounds.intersection(.world)
                previousLocation = newLocation
            }
            data.locations.append(newLocation)
            let pointSize = MKMapSize(width: 0, height: 0)
            let newPointRect = MKMapRect(origin: MKMapPoint(newLocation.coordinate), size: pointSize)
            let prevPointRect = MKMapRect(origin: MKMapPoint(previousLocation!.coordinate), size: pointSize)
            let pointRect = newPointRect.union(prevPointRect)
            
            // Update the `pathBounds` to hold the new location, if needed.
            var boundsChanged = false
            let locationChanged = true
            if !data.bounds.contains(pointRect) {
                var newBounds = data.bounds.union(pointRect)
                let paddingAmountInMapPoints = 1000 * MKMapPointsPerMeterAtLatitude(pointRect.origin.coordinate.latitude)
                
                // Grow by an extra kilometer in the direction of the overrun.
                if pointRect.minY < data.bounds.minY {
                    newBounds.origin.y -= paddingAmountInMapPoints
                    newBounds.size.height += paddingAmountInMapPoints
                }
                
                if pointRect.maxY > data.bounds.maxY {
                    newBounds.size.height += paddingAmountInMapPoints
                }
                
                if pointRect.minX < data.bounds.minX {
                    newBounds.origin.x -= paddingAmountInMapPoints
                    newBounds.size.width += paddingAmountInMapPoints
                }
                
                if pointRect.maxX > data.bounds.maxX {
                    newBounds.size.width += paddingAmountInMapPoints
                }
                
                // Ensure the updated `pathBounds` is never larger than the world size.
                data.bounds = newBounds.intersection(.world)
                boundsChanged = true
            }
            return (locationChanged, boundsChanged)
        }
        return result
    }
    
    private func isNewLocationUsable(_ newLocation: CLLocation, breadcrumbData: BreadcrumbData) -> Bool {
        let now = Date()
        let locationAge = now.timeIntervalSince(newLocation.timestamp)
        guard locationAge < 60 else {
            return false
        }
        guard breadcrumbData.locations.count > 10 else { return true }
        
        let minimumDistanceBetweenLocationsInMeters = 10.0
        let previousLocation = breadcrumbData.locations.last!
        let metersApart = newLocation.distance(from: previousLocation)
        return metersApart > minimumDistanceBetweenLocationsInMeters
    }

}
