import XCTest
@testable import BruteCast

final class MockDataGeneratorTests: XCTestCase {

    func testSinusoidalCurve_GeneratesExpectedDailyPattern() {
        // Arrange
        let startDate = Date()
        let hourCount = 24
        let baseline = 60.0
        let amplitude = 20.0
        let peakHour = 14 // 2 PM

        // Act
        let values = MockDataGenerator.sinusoidalCurve(
            count: hourCount,
            baseline: baseline,
            amplitude: amplitude,
            peakOffset: peakHour
        )

        // Assert
        XCTAssertEqual(values.count, hourCount)

        // Peak should be near hour 14
        let peakIndex = values.enumerated().max(by: { $0.element < $1.element })?.offset
        XCTAssertNotNil(peakIndex)
        if let peakIndex = peakIndex {
            XCTAssertEqual(peakIndex, peakHour, accuracy: 2, "Peak should occur near specified hour")
        }

        // Min should be near hour 2 (opposite of 14 in 24h cycle)
        let minIndex = values.enumerated().min(by: { $0.element < $1.element })?.offset
        XCTAssertNotNil(minIndex)
        if let minIndex = minIndex {
            XCTAssertEqual(minIndex, 2, accuracy: 2, "Min should occur ~12 hours from peak")
        }

        // Values should be in reasonable range
        XCTAssertTrue(values.allSatisfy { $0 >= baseline - amplitude && $0 <= baseline + amplitude })
    }

    func testRandomWalk_StaysWithinBounds() {
        // Arrange
        let count = 100
        let start = 50.0
        let stepSize = 5.0
        let min = 0.0
        let max = 100.0

        // Act
        let values = MockDataGenerator.randomWalk(
            count: count,
            start: start,
            stepSize: stepSize,
            min: min,
            max: max
        )

        // Assert
        XCTAssertEqual(values.count, count)
        XCTAssertEqual(values.first, start)
        XCTAssertTrue(values.allSatisfy { $0 >= min && $0 <= max })
    }

    func testLinearInterpolation_BetweenTwoPoints() {
        // Arrange
        let count = 5
        let start = 0.0
        let end = 10.0

        // Act
        let values = MockDataGenerator.linearInterpolation(
            count: count,
            start: start,
            end: end
        )

        // Assert
        XCTAssertEqual(values.count, count)
        XCTAssertEqual(values.first, start)
        XCTAssertEqual(values.last, end)

        // Should be evenly spaced
        XCTAssertEqual(values[1], 2.5, accuracy: 0.01)
        XCTAssertEqual(values[2], 5.0, accuracy: 0.01)
        XCTAssertEqual(values[3], 7.5, accuracy: 0.01)
    }
}
