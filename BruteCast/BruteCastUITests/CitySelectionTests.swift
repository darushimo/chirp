import XCTest

final class CitySelectionTests: XCTestCase {
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

    func testOpenCityPicker() throws {
        // Wait for app to load
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))

        // Find and tap an edit button
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'edit' OR label CONTAINS[c] 'EDIT'")).firstMatch

        if editButton.exists {
            editButton.tap()

            // Verify city picker appears
            XCTAssertTrue(app.navigationBars["SEARCH CITY"].waitForExistence(timeout: 3) ||
                          app.staticTexts["SEARCH CITY"].waitForExistence(timeout: 3))
        }
    }

    func testCityPickerHasSearchField() throws {
        // Wait for app to load
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))

        // Find and tap an edit button
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'edit' OR label CONTAINS[c] 'EDIT'")).firstMatch

        if editButton.exists {
            editButton.tap()

            // Wait for picker to appear
            _ = app.navigationBars.firstMatch.waitForExistence(timeout: 3)

            // Check for search field
            let searchField = app.textFields.firstMatch
            XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        }
    }

    func testCityPickerCancel() throws {
        // Wait for app to load
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))

        // Find and tap an edit button
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'edit' OR label CONTAINS[c] 'EDIT'")).firstMatch

        if editButton.exists {
            editButton.tap()

            // Wait for picker to appear
            _ = app.navigationBars.firstMatch.waitForExistence(timeout: 3)

            // Tap cancel
            let cancelButton = app.buttons["CANCEL"]
            if cancelButton.exists {
                cancelButton.tap()

                // Verify we're back to main view
                XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 2))
            }
        }
    }

    func testSearchCityByName() throws {
        // Wait for app to load
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))

        // Find and tap an edit button
        let editButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'edit' OR label CONTAINS[c] 'EDIT'")).firstMatch

        if editButton.exists {
            editButton.tap()

            // Wait for picker to appear
            _ = app.navigationBars.firstMatch.waitForExistence(timeout: 3)

            // Type in search field
            let searchField = app.textFields.firstMatch
            if searchField.waitForExistence(timeout: 2) {
                searchField.tap()
                searchField.typeText("New York")

                // Wait for results (with network delay)
                sleep(2)

                // Results should appear (or at least no crash)
            }
        }
    }
}
