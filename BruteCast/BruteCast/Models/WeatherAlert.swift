import Foundation
import SwiftUI

struct WeatherAlert: Identifiable, Codable, Equatable {
    let id: String
    let headline: String
    let event: String
    let severity: AlertSeverity
    let certainty: String
    let urgency: String
    let onset: Date?
    let expires: Date?
    let description: String
    let instruction: String?
    let areaDesc: String
    let senderName: String

    var shortName: String {
        event
    }

    var weatherKitURL: URL? {
        URL(string: "https://weatherkit.apple.com/alertDetails/\(id)")
    }

    var isActive: Bool {
        let now = Date()
        if let onset = onset, let expires = expires {
            return now >= onset && now <= expires
        }
        if let expires = expires {
            return now <= expires
        }
        return true
    }

    var affectedGraphType: GraphType {
        let lowercaseEvent = event.lowercased()

        if lowercaseEvent.contains("wind") || lowercaseEvent.contains("tornado") || lowercaseEvent.contains("hurricane") {
            return .wind
        }

        if lowercaseEvent.contains("flood") || lowercaseEvent.contains("rain") || lowercaseEvent.contains("storm") || lowercaseEvent.contains("thunder") {
            return .precipitation
        }

        return .temperature
    }

    func isActiveAt(date: Date) -> Bool {
        if let onset = onset, let expires = expires {
            return date >= onset && date <= expires
        }
        if let onset = onset {
            return date >= onset
        }
        if let expires = expires {
            return date <= expires
        }
        return true
    }
}

enum AlertSeverity: String, Codable {
    case extreme = "Extreme"
    case severe = "Severe"
    case moderate = "Moderate"
    case minor = "Minor"
    case unknown = "Unknown"

    var color: Color {
        switch self {
        case .extreme: return .red
        case .severe: return .orange
        case .moderate: return .yellow
        case .minor: return .blue
        case .unknown: return .gray
        }
    }

    var priority: Int {
        switch self {
        case .extreme: return 4
        case .severe: return 3
        case .moderate: return 2
        case .minor: return 1
        case .unknown: return 0
        }
    }
}

enum GraphType: String {
    case temperature
    case wind
    case precipitation
}

struct CityAlerts: Identifiable, Codable {
    let id: UUID
    let city: City
    let alerts: [WeatherAlert]
    let lastUpdated: Date

    init(id: UUID = UUID(), city: City, alerts: [WeatherAlert], lastUpdated: Date = Date()) {
        self.id = id
        self.city = city
        self.alerts = alerts
        self.lastUpdated = lastUpdated
    }

    var activeAlerts: [WeatherAlert] {
        alerts.filter { $0.isActive }
    }

    var sortedAlerts: [WeatherAlert] {
        alerts.sorted { $0.severity.priority > $1.severity.priority }
    }

    func alerts(for graphType: GraphType) -> [WeatherAlert] {
        alerts.filter { $0.affectedGraphType == graphType }
    }
}
