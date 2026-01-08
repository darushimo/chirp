import Foundation

struct City: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    let state: String?
    let country: String
    let latitude: Double
    let longitude: Double
    let timezone: String

    init(
        id: UUID = UUID(),
        name: String,
        state: String? = nil,
        country: String,
        latitude: Double,
        longitude: Double,
        timezone: String
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
    }

    var displayName: String {
        if let state = state, !state.isEmpty {
            return "\(name), \(state)"
        }
        return "\(name), \(country)"
    }

    var fullDisplayName: String {
        if let state = state, !state.isEmpty {
            return "\(name), \(state), \(country)"
        }
        return "\(name), \(country)"
    }

    var timezoneIdentifier: TimeZone {
        TimeZone(identifier: timezone) ?? .current
    }

    var currentLocalTime: String {
        let formatter = DateFormatter()
        formatter.timeZone = timezoneIdentifier
        formatter.dateFormat = "h:mma"
        return formatter.string(from: Date()).uppercased()
    }

    var currentLocalTimeWithZone: String {
        let formatter = DateFormatter()
        formatter.timeZone = timezoneIdentifier
        formatter.dateFormat = "h:mma zzz"
        return formatter.string(from: Date()).uppercased()
    }

    var timezoneAbbreviation: String {
        timezoneIdentifier.abbreviation() ?? "UTC"
    }

    func localTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timezoneIdentifier
        formatter.dateFormat = "EEE h:mma"
        return formatter.string(from: date).uppercased()
    }

    func isInUSA() -> Bool {
        return country == "United States" || country == "USA" || country == "US"
    }
}

extension City {
    static let placeholder = City(
        name: "---",
        country: "---",
        latitude: 0,
        longitude: 0,
        timezone: "UTC"
    )
}
