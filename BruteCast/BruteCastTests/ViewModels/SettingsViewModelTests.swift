import XCTest
import SwiftUI
@testable import BruteCast

@MainActor
final class SettingsViewModelTests: XCTestCase {
    var sut: SettingsViewModel!

    override func setUp() {
        super.setUp()
        sut = SettingsViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDefaultValues() {
        XCTAssertEqual(sut.temperatureUnit, .fahrenheit)
        XCTAssertEqual(sut.speedUnit, .mph)
        XCTAssertEqual(sut.headerLocationMode, .currentLocation)
        XCTAssertNil(sut.selectedHeaderCity)
    }

    func testTemperatureUnitChange() {
        // Given
        XCTAssertEqual(sut.temperatureUnit, .fahrenheit)

        // When
        sut.temperatureUnit = .celsius

        // Then
        XCTAssertEqual(sut.temperatureUnit, .celsius)
    }

    func testSpeedUnitChange() {
        // Given
        XCTAssertEqual(sut.speedUnit, .mph)

        // When
        sut.speedUnit = .kmh

        // Then
        XCTAssertEqual(sut.speedUnit, .kmh)
    }

    func testSelectPresetTheme() {
        // Given
        let darkTheme = Theme.dark

        // When
        sut.selectPresetTheme(darkTheme)

        // Then
        XCTAssertEqual(sut.currentTheme.name, darkTheme.name)
        XCTAssertEqual(sut.backgroundColor, darkTheme.background)
        XCTAssertEqual(sut.textColor, darkTheme.text)
    }

    func testHeaderLocationModeChange() {
        // Given
        XCTAssertEqual(sut.headerLocationMode, .currentLocation)

        // When
        sut.headerLocationMode = .selectedCity

        // Then
        XCTAssertEqual(sut.headerLocationMode, .selectedCity)
    }

    func testSelectedHeaderCityChange() {
        // Given
        XCTAssertNil(sut.selectedHeaderCity)

        // When
        sut.selectedHeaderCity = MockCities.newYork

        // Then
        XCTAssertNotNil(sut.selectedHeaderCity)
        XCTAssertEqual(sut.selectedHeaderCity?.name, "New York")
    }

    func testResetToDefaults() {
        // Given
        sut.temperatureUnit = .celsius
        sut.speedUnit = .kmh
        sut.selectPresetTheme(.dark)
        sut.headerLocationMode = .selectedCity
        sut.selectedHeaderCity = MockCities.tokyo

        // When
        sut.resetToDefaults()

        // Then
        XCTAssertEqual(sut.temperatureUnit, .fahrenheit)
        XCTAssertEqual(sut.speedUnit, .mph)
        XCTAssertEqual(sut.currentTheme.name, Theme.classic.name)
        XCTAssertEqual(sut.headerLocationMode, .currentLocation)
        XCTAssertNil(sut.selectedHeaderCity)
    }
}
