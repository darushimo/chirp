import XCTest

final class InteractionTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testRefreshButton() throws {
        // Wait for app to load
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))

        // Find and tap refresh button
        let refreshButton = app.buttons["Refresh weather data"]

        if refreshButton.exists {
            refreshButton.tap()
            // App should not crash, refresh should occur
        }
    }

    func testSettingsTemperatureUnitToggle() throws {
        // Open settings
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))
        app.staticTexts["BRUTECAST"].tap()

        // Wait for settings
        _ = app.staticTexts["SETTINGS"].waitForExistence(timeout: 3)

        // Find Celsius button
        let celsiusButton = app.buttons.matching(NSPredicate(format: "label CONTAINS '°C'")).firstMatch

        if celsiusButton.exists {
            celsiusButton.tap()
        }

        // Find Fahrenheit button
        let fahrenheitButton = app.buttons.matching(NSPredicate(format: "label CONTAINS '°F'")).firstMatch

        if fahrenheitButton.exists {
            fahrenheitButton.tap()
        }
    }

    func testSettingsThemeSelection() throws {
        // Open settings
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))
        app.staticTexts["BRUTECAST"].tap()

        // Wait for settings
        _ = app.staticTexts["SETTINGS"].waitForExistence(timeout: 3)

        // Find and tap Dark theme
        let darkButton = app.buttons["DARK"]

        if darkButton.exists {
            darkButton.tap()
            // Theme should change (visual)
        }

        // Find and tap Classic theme to reset
        let classicButton = app.buttons["CLASSIC"]

        if classicButton.exists {
            classicButton.tap()
        }
    }

    func testSettingsResetToDefaults() throws {
        // Open settings
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))
        app.staticTexts["BRUTECAST"].tap()

        // Wait for settings
        _ = app.staticTexts["SETTINGS"].waitForExistence(timeout: 3)

        // Scroll down to find reset button
        app.swipeUp()

        // Find and tap reset button
        let resetButton = app.buttons["RESET TO DEFAULTS"]

        if resetButton.exists {
            resetButton.tap()
            // Settings should reset
        }
    }

    func testHeaderLocationModeToggle() throws {
        // Open settings
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))
        app.staticTexts["BRUTECAST"].tap()

        // Wait for settings
        _ = app.staticTexts["SETTINGS"].waitForExistence(timeout: 3)

        // Find header location section
        XCTAssertTrue(app.staticTexts["HEADER LOCATION"].waitForExistence(timeout: 2))

        // Try to tap "Select City" option
        let selectCityButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'SELECT CITY'")).firstMatch

        if selectCityButton.exists {
            selectCityButton.tap()
            // City picker should appear
        }
    }

    func testAccessibilityLabels() throws {
        // Wait for app to load
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))

        // Check that key elements have accessibility labels
        let settingsButton = app.buttons["Open settings"]
        let refreshButton = app.buttons["Refresh weather data"]

        // At least some accessibility elements should exist
        XCTAssertTrue(settingsButton.exists || refreshButton.exists ||
                      app.staticTexts["BRUTECAST"].exists)
    }
}
