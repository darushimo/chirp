import XCTest
import SwiftUI
@testable import BruteCast

final class ThemeTests: XCTestCase {

    func testPresetThemesExist() {
        XCTAssertFalse(Theme.presets.isEmpty)
        XCTAssertEqual(Theme.presets.count, 5)
    }

    func testClassicTheme() {
        let theme = Theme.classic
        XCTAssertEqual(theme.name, "CLASSIC")
        // Classic theme should have white background
        XCTAssertEqual(theme.backgroundColor.red, 1.0)
        XCTAssertEqual(theme.backgroundColor.green, 1.0)
        XCTAssertEqual(theme.backgroundColor.blue, 1.0)
    }

    func testDarkTheme() {
        let theme = Theme.dark
        XCTAssertEqual(theme.name, "DARK")
        // Dark theme should have black background
        XCTAssertEqual(theme.backgroundColor.red, 0.0)
        XCTAssertEqual(theme.backgroundColor.green, 0.0)
        XCTAssertEqual(theme.backgroundColor.blue, 0.0)
    }

    func testMonoTheme() {
        let theme = Theme.mono
        XCTAssertEqual(theme.name, "MONO")
    }

    func testHighContrastTheme() {
        let theme = Theme.highContrast
        XCTAssertEqual(theme.name, "HI-CON")
    }

    func testColorBlindSafeTheme() {
        let theme = Theme.colorBlindSafe
        XCTAssertEqual(theme.name, "CB-SAFE")
    }

    func testCodableColor() throws {
        // Given
        let codableColor = CodableColor(red: 1.0, green: 0.5, blue: 0.25, opacity: 0.8)

        // When
        let encoded = try JSONEncoder().encode(codableColor)
        let decoded = try JSONDecoder().decode(CodableColor.self, from: encoded)

        // Then
        XCTAssertEqual(codableColor.red, decoded.red)
        XCTAssertEqual(codableColor.green, decoded.green)
        XCTAssertEqual(codableColor.blue, decoded.blue)
        XCTAssertEqual(codableColor.opacity, decoded.opacity)
    }

    func testCodableColorFromSwiftUIColor() {
        // Given
        let swiftUIColor = Color.red

        // When
        let codableColor = CodableColor(color: swiftUIColor)

        // Then
        XCTAssertGreaterThan(codableColor.red, 0.9) // Red should be close to 1.0
        XCTAssertLessThan(codableColor.green, 0.1) // Green should be close to 0.0
        XCTAssertLessThan(codableColor.blue, 0.1) // Blue should be close to 0.0
    }

    func testThemeCodable() throws {
        // Given
        let theme = Theme.classic

        // When
        let encoded = try JSONEncoder().encode(theme)
        let decoded = try JSONDecoder().decode(Theme.self, from: encoded)

        // Then
        XCTAssertEqual(theme.name, decoded.name)
        XCTAssertEqual(theme.backgroundColor, decoded.backgroundColor)
        XCTAssertEqual(theme.textColor, decoded.textColor)
    }

    func testAlertTintColor() {
        // The alert tint should be a semi-transparent pink/red
        let alertTint = Theme.alertTint
        XCTAssertNotNil(alertTint)
    }

    func testThemeEquality() {
        let theme1 = Theme.classic
        let theme2 = Theme(
            id: theme1.id,
            name: theme1.name,
            backgroundColor: theme1.backgroundColor,
            textColor: theme1.textColor,
            temperatureColor: theme1.temperatureColor,
            windColor: theme1.windColor,
            precipitationColor: theme1.precipitationColor,
            accentColor: theme1.accentColor
        )

        XCTAssertEqual(theme1, theme2)
    }
}
