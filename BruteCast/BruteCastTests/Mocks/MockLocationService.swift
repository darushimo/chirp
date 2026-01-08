import Foundation
import CoreLocation
@testable import BruteCast

class MockLocationService: LocationServiceProtocol {
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    var mockCity: City?
    var shouldFail = false

    func requestPermission() {
        // No-op for tests
    }

    func getCurrentCity() async throws -> City {
        if shouldFail {
            throw LocationServiceError.locationUnavailable
        }
        if let city = mockCity {
            return city
        }
        return MockCities.newYork
    }
}
