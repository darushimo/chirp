import Foundation

/// Utility for running tests multiple times to measure reliability.
/// Used to ensure features pass consistently (e.g., 9/10 times for AI features).
struct ReliabilityRunner {

    struct Result {
        let successCount: Int
        let failureCount: Int
        let successRate: Double
        let failures: [Error]

        var meetsThreshold: Bool {
            successRate >= 0.9 // 90% threshold
        }

        var summary: String {
            """
            Reliability Test Results:
            - Success: \(successCount)/\(successCount + failureCount)
            - Success Rate: \(String(format: "%.1f%%", successRate * 100))
            - Meets Threshold (90%): \(meetsThreshold ? "✓" : "✗")
            """
        }
    }

    /// Runs a test closure multiple times and reports success rate.
    /// - Parameters:
    ///   - iterations: Number of times to run the test
    ///   - test: The test closure to run
    /// - Returns: Result with success/failure counts and rate
    static func run(
        iterations: Int,
        test: () async throws -> Void
    ) async rethrows -> Result {
        var successCount = 0
        var failureCount = 0
        var failures: [Error] = []

        for _ in 0..<iterations {
            do {
                try await test()
                successCount += 1
            } catch {
                failureCount += 1
                failures.append(error)
            }
        }

        let successRate = Double(successCount) / Double(iterations)

        return Result(
            successCount: successCount,
            failureCount: failureCount,
            successRate: successRate,
            failures: failures
        )
    }

    /// Synchronous version for non-async tests
    static func run(
        iterations: Int,
        test: () throws -> Void
    ) rethrows -> Result {
        var successCount = 0
        var failureCount = 0
        var failures: [Error] = []

        for _ in 0..<iterations {
            do {
                try test()
                successCount += 1
            } catch {
                failureCount += 1
                failures.append(error)
            }
        }

        let successRate = Double(successCount) / Double(iterations)

        return Result(
            successCount: successCount,
            failureCount: failureCount,
            successRate: successRate,
            failures: failures
        )
    }
}
