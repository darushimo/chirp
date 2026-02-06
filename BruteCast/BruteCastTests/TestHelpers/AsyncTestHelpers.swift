import Combine
import XCTest

/// Test helpers for async/await and Combine integration
extension Publisher {
    /// Converts a publisher to an async value
    /// Useful for testing Combine publishers in async contexts
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var hasResumed = false

            cancellable = first()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            if !hasResumed {
                                // This shouldn't happen if we received a value
                                // but guard against it
                                continuation.resume(throwing: AsyncTestError.noValue)
                                hasResumed = true
                            }
                        case .failure(let error):
                            if !hasResumed {
                                continuation.resume(throwing: error)
                                hasResumed = true
                            }
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        if !hasResumed {
                            continuation.resume(returning: value)
                            hasResumed = true
                        }
                    }
                )
        }
    }
}

enum AsyncTestError: Error {
    case noValue
    case timeout
}

/// Helper for testing async code with timeouts
extension XCTestCase {
    /// Waits for an async condition to become true
    func waitForCondition(
        timeout: TimeInterval = 1.0,
        pollingInterval: TimeInterval = 0.1,
        condition: @escaping () -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if condition() {
                return
            }
            try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
        }

        throw AsyncTestError.timeout
    }
}
