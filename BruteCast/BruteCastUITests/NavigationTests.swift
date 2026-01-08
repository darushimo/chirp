import XCTest

final class NavigationTests: XCTestCase {
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

    func testOpenSettings() throws {
        // Wait for app to load
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))

        // Tap BRUTECAST to open settings
        app.staticTexts["BRUTECAST"].tap()

        // Verify settings view appears
        XCTAssertTrue(app.staticTexts["SETTINGS"].waitForExistence(timeout: 3) ||
                      app.navigationBars["SETTINGS"].waitForExistence(timeout: 3))
    }

    func testSettingsHasUnitsSection() throws {
        // Open settings
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))
        app.staticTexts["BRUTECAST"].tap()

        // Wait for settings to appear
        _ = app.staticTexts["SETTINGS"].waitForExistence(timeout: 3)

        // Check for units section
        XCTAssertTrue(app.staticTexts["UNITS"].waitForExistence(timeout: 2))
    }

    func testSettingsHasThemeSection() throws {
        // Open settings
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))
        app.staticTexts["BRUTECAST"].tap()

        // Wait for settings to appear
        _ = app.staticTexts["SETTINGS"].waitForExistence(timeout: 3)

        // Check for theme section
        XCTAssertTrue(app.staticTexts["THEME"].waitForExistence(timeout: 2))
    }

    func testSettingsClose() throws {
        // Open settings
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))
        app.staticTexts["BRUTECAST"].tap()

        // Wait for settings to appear
        _ = app.staticTexts["SETTINGS"].waitForExistence(timeout: 3)

        // Tap Done
        let doneButton = app.buttons["DONE"]
        if doneButton.exists {
            doneButton.tap()

            // Verify we're back to main view
            XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 2))
        }
    }

    func testTimeRangeToggle() throws {
        // Wait for app to load
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))

        // Find and tap 36H button
        let button36H = app.buttons.matching(NSPredicate(format: "label CONTAINS '36H'")).firstMatch

        if button36H.exists {
            button36H.tap()
            // Button should be selected (visual change would happen)
        }

        // Find and tap 5D button
        let button5D = app.buttons.matching(NSPredicate(format: "label CONTAINS '5D'")).firstMatch

        if button5D.exists {
            button5D.tap()
        }

        // Find and tap 12H button to return
        let button12H = app.buttons.matching(NSPredicate(format: "label CONTAINS '12H'")).firstMatch

        if button12H.exists {
            button12H.tap()
        }
    }
}
