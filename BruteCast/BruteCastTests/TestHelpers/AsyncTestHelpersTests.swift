import XCTest
import Combine
@testable import BruteCast

final class AsyncTestHelpersTests: XCTestCase {

    func testAwaitPublisher_WithSuccessfulPublisher_ReturnsValue() async throws {
        // Arrange
        let expectedValue = 42
        let publisher = Just(expectedValue)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        // Act
        let result = try await publisher.async()

        // Assert
        XCTAssertEqual(result, expectedValue)
    }

    func testAwaitPublisher_WithFailingPublisher_ThrowsError() async {
        // Arrange
        struct TestError: Error {}
        let publisher = Fail<Int, Error>(error: TestError())
            .eraseToAnyPublisher()

        // Act & Assert
        do {
            _ = try await publisher.async()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is TestError)
        }
    }

    func testAwaitPublisher_WithMultipleValues_ReturnsFirstValue() async throws {
        // Arrange
        let publisher = [1, 2, 3].publisher
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        // Act
        let result = try await publisher.async()

        // Assert
        XCTAssertEqual(result, 1)
    }
}
