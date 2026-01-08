import Foundation

enum MockCities {
    static let newYork = City(
        name: "New York",
        state: "NY",
        country: "United States",
        latitude: 40.7128,
        longitude: -74.0060,
        timezone: "America/New_York"
    )

    static let losAngeles = City(
        name: "Los Angeles",
        state: "CA",
        country: "United States",
        latitude: 34.0522,
        longitude: -118.2437,
        timezone: "America/Los_Angeles"
    )

    static let chicago = City(
        name: "Chicago",
        state: "IL",
        country: "United States",
        latitude: 41.8781,
        longitude: -87.6298,
        timezone: "America/Chicago"
    )

    static let miami = City(
        name: "Miami",
        state: "FL",
        country: "United States",
        latitude: 25.7617,
        longitude: -80.1918,
        timezone: "America/New_York"
    )

    static let seattle = City(
        name: "Seattle",
        state: "WA",
        country: "United States",
        latitude: 47.6062,
        longitude: -122.3321,
        timezone: "America/Los_Angeles"
    )

    static let tokyo = City(
        name: "Tokyo",
        state: nil,
        country: "Japan",
        latitude: 35.6762,
        longitude: 139.6503,
        timezone: "Asia/Tokyo"
    )

    static let london = City(
        name: "London",
        state: nil,
        country: "United Kingdom",
        latitude: 51.5074,
        longitude: -0.1278,
        timezone: "Europe/London"
    )

    static let paris = City(
        name: "Paris",
        state: nil,
        country: "France",
        latitude: 48.8566,
        longitude: 2.3522,
        timezone: "Europe/Paris"
    )

    static let sydney = City(
        name: "Sydney",
        state: "NSW",
        country: "Australia",
        latitude: -33.8688,
        longitude: 151.2093,
        timezone: "Australia/Sydney"
    )

    static let allCities: [City] = [
        newYork, losAngeles, chicago, miami, seattle,
        tokyo, london, paris, sydney
    ]

    static let usCities: [City] = [
        newYork, losAngeles, chicago, miami, seattle
    ]

    static let sampleSearchResults: [City] = [
        newYork,
        City(name: "New York Mills", state: "MN", country: "United States", latitude: 46.5180, longitude: -95.3758, timezone: "America/Chicago"),
        City(name: "East New York", state: "NY", country: "United States", latitude: 40.6661, longitude: -73.8823, timezone: "America/New_York")
    ]
}
