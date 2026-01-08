import XCTest
@testable import BruteCast

@MainActor
final class WeatherViewModelTests: XCTestCase {
    var sut: WeatherViewModel!

    override func setUp() {
        super.setUp()
        sut = WeatherViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertNil(sut.headerWeather)
        XCTAssertNil(sut.headerAlerts)
        XCTAssertTrue(sut.cityWeatherData.isEmpty)
        XCTAssertTrue(sut.cityAlerts.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
        XCTAssertEqual(sut.selectedTimeRange, .twelveHours)
    }

    func testTimeRangeSelection() {
        // Given
        XCTAssertEqual(sut.selectedTimeRange, .twelveHours)

        // When
        sut.selectedTimeRange = .thirtySixHours

        // Then
        XCTAssertEqual(sut.selectedTimeRange, .thirtySixHours)

        // When
        sut.selectedTimeRange = .fiveDays

        // Then
        XCTAssertEqual(sut.selectedTimeRange, .fiveDays)
    }

    func testTimeRangeHours() {
        XCTAssertEqual(TimeRange.twelveHours.hours, 12)
        XCTAssertEqual(TimeRange.thirtySixHours.hours, 36)
        XCTAssertEqual(TimeRange.fiveDays.hours, 120)
    }

    func testWeatherDataFiltering() {
        // Given
        let mockData = MockWeatherData.generateHourlyData(hours: 168)
        let cityData = CityWeatherData(city: MockCities.newYork, hourlyData: mockData)

        // When - 12 hours
        let twelveHourData = cityData.data(for: .twelveHours)
        XCTAssertLessThanOrEqual(twelveHourData.count, 13) // 12 hours + possible current hour

        // When - 36 hours
        let thirtySixHourData = cityData.data(for: .thirtySixHours)
        XCTAssertLessThanOrEqual(thirtySixHourData.count, 37)

        // When - 5 days
        let fiveDayData = cityData.data(for: .fiveDays)
        XCTAssertLessThanOrEqual(fiveDayData.count, 121)
    }

    func testRemoveCityData() {
        // Given
        let weather1 = CityWeatherData(city: MockCities.newYork, hourlyData: [])
        let weather2 = CityWeatherData(city: MockCities.tokyo, hourlyData: [])
        sut.cityWeatherData = [weather1, weather2]

        // When
        sut.removeCityData(at: 0)

        // Then
        XCTAssertEqual(sut.cityWeatherData.count, 1)
        XCTAssertEqual(sut.cityWeatherData[0].city.name, "Tokyo")
    }

    func testWeatherForCity() {
        // Given
        let weather = CityWeatherData(city: MockCities.newYork, hourlyData: [])
        sut.cityWeatherData = [weather]

        // When
        let result = sut.weather(for: MockCities.newYork)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.city.name, "New York")
    }

    func testAlertsForCity() {
        // Given
        let alerts = CityAlerts(city: MockCities.newYork, alerts: [MockAlerts.extremeColdWatch])
        sut.cityAlerts = [alerts]

        // When
        let result = sut.alerts(for: MockCities.newYork)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.alerts.count, 1)
    }
}
