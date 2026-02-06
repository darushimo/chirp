import XCTest
@testable import BruteCast

final class ReliabilityRunnerTests: XCTestCase {

    func testRunReliabilityTest_WithAlwaysPassingTest_Returns100PercentSuccess() async throws {
        // Arrange
        let iterations = 10
        let alwaysPass: () async throws -> Void = {
            // This test always passes
        }

        // Act
        let result = try await ReliabilityRunner.run(
            iterations: iterations,
            test: alwaysPass
        )

        // Assert
        XCTAssertEqual(result.successCount, 10)
        XCTAssertEqual(result.failureCount, 0)
        XCTAssertEqual(result.successRate, 1.0)
    }

    func testRunReliabilityTest_WithAlwaysFailingTest_Returns0PercentSuccess() async throws {
        // Arrange
        let iterations = 10
        let alwaysFail: () async throws -> Void = {
            throw NSError(domain: "test", code: 1)
        }

        // Act
        let result = try await ReliabilityRunner.run(
            iterations: iterations,
            test: alwaysFail
        )

        // Assert
        XCTAssertEqual(result.successCount, 0)
        XCTAssertEqual(result.failureCount, 10)
        XCTAssertEqual(result.successRate, 0.0)
    }

    func testRunReliabilityTest_WithPartiallyFailingTest_ReturnsCorrectSuccessRate() async throws {
        // Arrange
        var attemptCount = 0
        let partiallyFail: () async throws -> Void = {
            attemptCount += 1
            if attemptCount <= 3 {
                throw NSError(domain: "test", code: 1)
            }
        }

        // Act
        let result = try await ReliabilityRunner.run(
            iterations: 10,
            test: partiallyFail
        )

        // Assert
        XCTAssertEqual(result.successCount, 7)
        XCTAssertEqual(result.failureCount, 3)
        XCTAssertEqual(result.successRate, 0.7)
    }
}
