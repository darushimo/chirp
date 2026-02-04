import XCTest
@testable import BruteCast

final class TimeBasedFilteringTests: XCTestCase {

    func testFilterByTimeRange_WithItemsInRange_ReturnsMatchingItems() {
        // Arrange
        let now = Date()
        let items = [
            TimedItem(date: now.addingTimeInterval(-3600), value: "1 hour ago"),
            TimedItem(date: now.addingTimeInterval(-1800), value: "30 min ago"),
            TimedItem(date: now.addingTimeInterval(0), value: "now"),
            TimedItem(date: now.addingTimeInterval(1800), value: "30 min future"),
            TimedItem(date: now.addingTimeInterval(3600), value: "1 hour future"),
        ]

        let range = TimeRange.hours(from: now, hours: 1)

        // Act
        let filtered = TimeBasedFiltering.filter(items, in: range)

        // Assert
        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered[0].value, "now")
        XCTAssertEqual(filtered[1].value, "30 min future")
    }

    func testFilterByTimeRange_WithEmptyArray_ReturnsEmpty() {
        // Arrange
        let items: [TimedItem] = []
        let range = TimeRange.hours(from: Date(), hours: 12)

        // Act
        let filtered = TimeBasedFiltering.filter(items, in: range)

        // Assert
        XCTAssertTrue(filtered.isEmpty)
    }

    func testFilterByTimeRange_WithNoMatchingItems_ReturnsEmpty() {
        // Arrange
        let now = Date()
        let items = [
            TimedItem(date: now.addingTimeInterval(-7200), value: "2 hours ago"),
            TimedItem(date: now.addingTimeInterval(-10800), value: "3 hours ago"),
        ]

        let range = TimeRange.hours(from: now, hours: 1)

        // Act
        let filtered = TimeBasedFiltering.filter(items, in: range)

        // Assert
        XCTAssertTrue(filtered.isEmpty)
    }

    func testFilterByTimeRange_WithBoundaryValues_IncludesCorrectItems() {
        // Arrange
        let now = Date()
        let exactlyOneHourFuture = now.addingTimeInterval(3600)
        let items = [
            TimedItem(date: now, value: "start"),
            TimedItem(date: exactlyOneHourFuture, value: "end"),
            TimedItem(date: exactlyOneHourFuture.addingTimeInterval(1), value: "past end"),
        ]

        let range = TimeRange.hours(from: now, hours: 1)

        // Act
        let filtered = TimeBasedFiltering.filter(items, in: range)

        // Assert
        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered.map(\.value), ["start", "end"])
    }

    func testTimeRange_Days_CreatesCorrectRange() {
        // Arrange
        let now = Date()

        // Act
        let range = TimeRange.days(from: now, days: 5)

        // Assert
        let expectedEnd = now.addingTimeInterval(5 * 24 * 3600)
        XCTAssertEqual(range.start, now)
        XCTAssertEqual(range.end.timeIntervalSince1970, expectedEnd.timeIntervalSince1970, accuracy: 1.0)
    }
}

// Test model
struct TimedItem: TimeFilterable {
    let date: Date
    let value: String

    var timestamp: Date { date }
}
