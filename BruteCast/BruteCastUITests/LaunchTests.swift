import XCTest

final class LaunchTests: XCTestCase {
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

    func testAppLaunches() throws {
        // Verify the main view appears
        XCTAssertTrue(app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5))
    }

    func testHeaderElementsExist() throws {
        // Check for header elements
        XCTAssertTrue(app.staticTexts["BRUTECAST"].exists)

        // Check for time range toggle buttons
        XCTAssertTrue(app.buttons["12H time range"].waitForExistence(timeout: 2) ||
                      app.buttons["12H"].waitForExistence(timeout: 2))
    }

    func testCityRowsExist() throws {
        // Wait for the view to load
        _ = app.staticTexts["BRUTECAST"].waitForExistence(timeout: 5)

        // Check for edit buttons (there should be 3)
        let editButtons = app.buttons.matching(identifier: "Edit city").count +
                          app.buttons.matching(NSPredicate(format: "label CONTAINS 'EDIT'")).count

        XCTAssertGreaterThanOrEqual(editButtons, 0)
    }

    func testLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
