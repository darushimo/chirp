import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol {
    var currentLocation: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestPermission()
    func getCurrentCity() async throws -> City
}

final class LocationService: NSObject, ObservableObject, LocationServiceProtocol {
    static let shared = LocationService()

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentCity: City?
    @Published var error: Error?

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = locationManager.authorizationStatus
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func getCurrentCity() async throws -> City {
        guard let location = currentLocation else {
            throw LocationServiceError.locationUnavailable
        }

        let placemarks = try await geocoder.reverseGeocodeLocation(location)

        guard let placemark = placemarks.first else {
            throw LocationServiceError.geocodingFailed
        }

        let timezone = placemark.timeZone?.identifier ?? TimeZone.current.identifier

        return City(
            name: placemark.locality ?? placemark.administrativeArea ?? "Unknown",
            state: placemark.administrativeArea,
            country: placemark.country ?? "Unknown",
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timezone: timezone
        )
    }

    @MainActor
    func updateCurrentCity() async {
        do {
            currentCity = try await getCurrentCity()
            error = nil
        } catch {
            self.error = error
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location

        Task {
            await updateCurrentCity()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            stopUpdatingLocation()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

enum LocationServiceError: LocalizedError {
    case locationUnavailable
    case geocodingFailed
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .locationUnavailable:
            return "Location unavailable"
        case .geocodingFailed:
            return "Could not determine city"
        case .permissionDenied:
            return "Location permission denied"
        }
    }
}
