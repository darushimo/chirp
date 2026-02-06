import Foundation

/// Protocol for types that can be filtered by time.
public protocol TimeFilterable {
    var timestamp: Date { get }
}

/// Represents a time range for filtering.
public struct TimeRange {
    let start: Date
    let end: Date

    /// Creates a range from a start date for a number of hours.
    public static func hours(from start: Date, hours: Int) -> TimeRange {
        TimeRange(
            start: start,
            end: start.addingTimeInterval(TimeInterval(hours * 3600))
        )
    }

    /// Creates a range from a start date for a number of days.
    public static func days(from start: Date, days: Int) -> TimeRange {
        TimeRange(
            start: start,
            end: start.addingTimeInterval(TimeInterval(days * 24 * 3600))
        )
    }

    /// Checks if a date falls within this range (inclusive).
    func contains(_ date: Date) -> Bool {
        date >= start && date <= end
    }
}

/// Pattern for filtering time-series data.
///
/// **When to use:**
/// - Filtering weather data by time range
/// - Showing events within a date range
/// - Time-windowed data analysis
///
/// **When NOT to use:**
/// - Single date lookups (use dictionary)
/// - Non-temporal filtering
///
/// **Example:**
/// ```swift
/// let next12Hours = TimeRange.hours(from: Date(), hours: 12)
/// let filtered = TimeBasedFiltering.filter(weatherData, in: next12Hours)
/// ```
public struct TimeBasedFiltering {

    /// Filters an array of time-stamped items to only those within a time range.
    /// - Parameters:
    ///   - items: Array of items with timestamps
    ///   - range: Time range to filter by
    /// - Returns: Items with timestamps within the range
    public static func filter<T: TimeFilterable>(_ items: [T], in range: TimeRange) -> [T] {
        items.filter { range.contains($0.timestamp) }
    }
}
