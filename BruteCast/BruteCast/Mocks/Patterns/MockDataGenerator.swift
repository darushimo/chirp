import Foundation

/// Generalized patterns for generating realistic mock data.
///
/// **When to use:**
/// - Creating test data that mimics real-world patterns
/// - Seeding UI previews with believable data
/// - Generating data for performance testing
///
/// **Patterns:**
/// - Sinusoidal: Daily cycles (temperature, traffic, etc.)
/// - Random Walk: Incrementally changing values (stock prices, sensor drift)
/// - Linear Interpolation: Smooth transitions between points
///
public struct MockDataGenerator {

    /// Generates a sinusoidal curve representing a daily cycle.
    ///
    /// Perfect for: temperature, light levels, traffic patterns, user activity
    ///
    /// - Parameters:
    ///   - count: Number of data points
    ///   - baseline: Center value
    ///   - amplitude: Variation above/below baseline
    ///   - peakOffset: Index where peak occurs (e.g., 14 for 2 PM in 24-hour data)
    /// - Returns: Array of values following sinusoidal pattern
    public static func sinusoidalCurve(
        count: Int,
        baseline: Double,
        amplitude: Double,
        peakOffset: Int = 0
    ) -> [Double] {
        (0..<count).map { index in
            let phase = Double(index - peakOffset) / Double(count) * 2.0 * .pi
            let value = baseline + amplitude * cos(phase)
            return value
        }
    }

    /// Generates a random walk bounded by min/max values.
    ///
    /// Perfect for: stock prices, sensor readings, network latency
    ///
    /// - Parameters:
    ///   - count: Number of data points
    ///   - start: Initial value
    ///   - stepSize: Maximum change per step
    ///   - min: Lower bound
    ///   - max: Upper bound
    /// - Returns: Array of values following random walk
    public static func randomWalk(
        count: Int,
        start: Double,
        stepSize: Double,
        min: Double,
        max: Double
    ) -> [Double] {
        var values: [Double] = [start]
        var current = start

        for _ in 1..<count {
            let change = Double.random(in: -stepSize...stepSize)
            current = (current + change).clamped(to: min...max)
            values.append(current)
        }

        return values
    }

    /// Generates linearly interpolated values between start and end.
    ///
    /// Perfect for: smooth transitions, ramps, gradual changes
    ///
    /// - Parameters:
    ///   - count: Number of data points
    ///   - start: Initial value
    ///   - end: Final value
    /// - Returns: Array of evenly spaced values from start to end
    public static func linearInterpolation(
        count: Int,
        start: Double,
        end: Double
    ) -> [Double] {
        guard count > 1 else { return [start] }

        let step = (end - start) / Double(count - 1)
        return (0..<count).map { index in
            start + step * Double(index)
        }
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
