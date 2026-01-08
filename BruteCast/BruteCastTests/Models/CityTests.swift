import XCTest
@testable import BruteCast

final class CityTests: XCTestCase {

    func testCityDisplayName() {
        // With state
        let newYork = MockCities.newYork
        XCTAssertEqual(newYork.displayName, "New York, NY")

        // Without state
        let tokyo = MockCities.tokyo
        XCTAssertEqual(tokyo.displayName, "Tokyo, Japan")
    }

    func testCityFullDisplayName() {
        // With state
        let newYork = MockCities.newYork
        XCTAssertEqual(newYork.fullDisplayName, "New York, NY, United States")

        // Without state
        let tokyo = MockCities.tokyo
        XCTAssertEqual(tokyo.fullDisplayName, "Tokyo, Japan")
    }

    func testIsInUSA() {
        XCTAssertTrue(MockCities.newYork.isInUSA())
        XCTAssertTrue(MockCities.losAngeles.isInUSA())
        XCTAssertFalse(MockCities.tokyo.isInUSA())
        XCTAssertFalse(MockCities.london.isInUSA())
    }

    func testTimezoneIdentifier() {
        let newYork = MockCities.newYork
        XCTAssertNotNil(newYork.timezoneIdentifier)
        XCTAssertEqual(newYork.timezone, "America/New_York")
    }

    func testTimezoneAbbreviation() {
        let newYork = MockCities.newYork
        // Note: This will depend on DST
        XCTAssertFalse(newYork.timezoneAbbreviation.isEmpty)
    }

    func testCityEquality() {
        let city1 = City(
            id: UUID(),
            name: "Test",
            country: "Test",
            latitude: 0,
            longitude: 0,
            timezone: "UTC"
        )

        let city2 = City(
            id: city1.id,
            name: "Test",
            country: "Test",
            latitude: 0,
            longitude: 0,
            timezone: "UTC"
        )

        XCTAssertEqual(city1, city2)
    }

    func testCityCodable() throws {
        // Given
        let city = MockCities.newYork

        // When
        let encoded = try JSONEncoder().encode(city)
        let decoded = try JSONDecoder().decode(City.self, from: encoded)

        // Then
        XCTAssertEqual(city.name, decoded.name)
        XCTAssertEqual(city.state, decoded.state)
        XCTAssertEqual(city.country, decoded.country)
        XCTAssertEqual(city.latitude, decoded.latitude)
        XCTAssertEqual(city.longitude, decoded.longitude)
        XCTAssertEqual(city.timezone, decoded.timezone)
    }

    func testPlaceholder() {
        let placeholder = City.placeholder
        XCTAssertEqual(placeholder.name, "---")
        XCTAssertEqual(placeholder.country, "---")
    }
}
