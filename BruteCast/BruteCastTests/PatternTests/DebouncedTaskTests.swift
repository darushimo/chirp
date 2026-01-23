import XCTest
@testable import BruteCast

@MainActor
final class DebouncedTaskTests: XCTestCase {

    func testDebouncedTask_WithMultipleRapidCalls_OnlyExecutesLastOne() async throws {
        var executionCount = 0
        var lastValue: String?

        let debounced = DebouncedTask<String>(delay: 0.1) { value in
            executionCount += 1
            lastValue = value
        }

        debounced.submit("a")
        debounced.submit("b")
        debounced.submit("c")

        try await Task.sleep(for: .milliseconds(200))

        XCTAssertEqual(executionCount, 1, "Should only execute once")
        XCTAssertEqual(lastValue, "c", "Should execute with the last value")
    }

    func testDebouncedTask_WithSpacedCalls_ExecutesMultipleTimes() async throws {
        var executionCount = 0
        var values: [String] = []

        let debounced = DebouncedTask<String>(delay: 0.1) { value in
            executionCount += 1
            values.append(value)
        }

        debounced.submit("a")
        try await Task.sleep(for: .milliseconds(150))

        debounced.submit("b")
        try await Task.sleep(for: .milliseconds(150))

        XCTAssertEqual(executionCount, 2, "Should execute twice for spaced calls")
        XCTAssertEqual(values, ["a", "b"], "Should execute with correct values in order")
    }

    func testDebouncedTask_Cancel_PreventsExecution() async throws {
        var executionCount = 0

        let debounced = DebouncedTask<String>(delay: 0.1) { _ in
            executionCount += 1
        }

        debounced.submit("test")
        debounced.cancel()

        try await Task.sleep(for: .milliseconds(200))

        XCTAssertEqual(executionCount, 0, "Should not execute after cancel")
    }

    func testDebouncedTask_WithEmptyStringValue_StillDebounces() async throws {
        var executionCount = 0
        var lastValue: String?

        let debounced = DebouncedTask<String>(delay: 0.1) { value in
            executionCount += 1
            lastValue = value
        }

        debounced.submit("")
        debounced.submit("a")
        debounced.submit("")

        try await Task.sleep(for: .milliseconds(200))

        XCTAssertEqual(executionCount, 1, "Should only execute once even with empty strings")
        XCTAssertEqual(lastValue, "", "Should execute with the last empty value")
    }

    func testDebouncedTask_WithAsyncOperation_CompletesSuccessfully() async throws {
        var executionCount = 0
        var lastValue: Int?

        let debounced = DebouncedTask<Int>(delay: 0.1) { value in
            executionCount += 1
            try? await Task.sleep(for: .milliseconds(50))
            lastValue = value
        }

        debounced.submit(1)
        debounced.submit(2)
        debounced.submit(3)

        try await Task.sleep(for: .milliseconds(300))

        XCTAssertEqual(executionCount, 1, "Should only execute once")
        XCTAssertEqual(lastValue, 3, "Should complete async operation with last value")
    }
}
