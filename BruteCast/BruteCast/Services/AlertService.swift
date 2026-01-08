import Foundation

protocol AlertServiceProtocol {
    func fetchAlerts(for city: City) async throws -> CityAlerts
    func fetchAlerts(latitude: Double, longitude: Double) async throws -> [WeatherAlert]
}

final class AlertService: AlertServiceProtocol {
    static let shared = AlertService()

    private let session: URLSession
    private let nwsBaseURL = "https://api.weather.gov"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchAlerts(for city: City) async throws -> CityAlerts {
        guard city.isInUSA() else {
            return CityAlerts(city: city, alerts: [])
        }

        let alerts = try await fetchAlerts(latitude: city.latitude, longitude: city.longitude)
        return CityAlerts(city: city, alerts: alerts)
    }

    func fetchAlerts(latitude: Double, longitude: Double) async throws -> [WeatherAlert] {
        let pointURL = URL(string: "\(nwsBaseURL)/points/\(latitude),\(longitude)")!

        var pointRequest = URLRequest(url: pointURL)
        pointRequest.setValue("BruteCast/1.0 (contact@brutecast.app)", forHTTPHeaderField: "User-Agent")
        pointRequest.setValue("application/geo+json", forHTTPHeaderField: "Accept")

        let (pointData, pointResponse) = try await session.data(for: pointRequest)

        guard let httpResponse = pointResponse as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return []
        }

        guard let pointJSON = try? JSONDecoder().decode(NWSPointResponse.self, from: pointData),
              let zoneId = pointJSON.properties.forecastZone.split(separator: "/").last else {
            return []
        }

        let alertsURL = URL(string: "\(nwsBaseURL)/alerts/active/zone/\(zoneId)")!

        var alertsRequest = URLRequest(url: alertsURL)
        alertsRequest.setValue("BruteCast/1.0 (contact@brutecast.app)", forHTTPHeaderField: "User-Agent")
        alertsRequest.setValue("application/geo+json", forHTTPHeaderField: "Accept")

        let (alertsData, alertsResponse) = try await session.data(for: alertsRequest)

        guard let alertsHttpResponse = alertsResponse as? HTTPURLResponse,
              alertsHttpResponse.statusCode == 200 else {
            return []
        }

        let alertsJSON = try JSONDecoder().decode(NWSAlertsResponse.self, from: alertsData)
        return parseAlerts(from: alertsJSON)
    }

    private func parseAlerts(from response: NWSAlertsResponse) -> [WeatherAlert] {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let fallbackFormatter = ISO8601DateFormatter()
        fallbackFormatter.formatOptions = [.withInternetDateTime]

        return response.features.compactMap { feature -> WeatherAlert? in
            let props = feature.properties

            let onset = props.onset.flatMap { dateFormatter.date(from: $0) ?? fallbackFormatter.date(from: $0) }
            let expires = props.expires.flatMap { dateFormatter.date(from: $0) ?? fallbackFormatter.date(from: $0) }

            let severity: AlertSeverity
            switch props.severity?.lowercased() {
            case "extreme": severity = .extreme
            case "severe": severity = .severe
            case "moderate": severity = .moderate
            case "minor": severity = .minor
            default: severity = .unknown
            }

            return WeatherAlert(
                id: props.id,
                headline: props.headline ?? props.event,
                event: props.event,
                severity: severity,
                certainty: props.certainty ?? "Unknown",
                urgency: props.urgency ?? "Unknown",
                onset: onset,
                expires: expires,
                description: props.description ?? "",
                instruction: props.instruction,
                areaDesc: props.areaDesc ?? "",
                senderName: props.senderName ?? ""
            )
        }
    }
}

enum AlertServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case notInUSA

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from NWS"
        case .notInUSA:
            return "Alerts only available for US locations"
        }
    }
}

struct NWSPointResponse: Codable {
    let properties: PointProperties

    struct PointProperties: Codable {
        let forecastZone: String
    }
}

struct NWSAlertsResponse: Codable {
    let features: [AlertFeature]

    struct AlertFeature: Codable {
        let properties: AlertProperties
    }

    struct AlertProperties: Codable {
        let id: String
        let event: String
        let headline: String?
        let severity: String?
        let certainty: String?
        let urgency: String?
        let onset: String?
        let expires: String?
        let description: String?
        let instruction: String?
        let areaDesc: String?
        let senderName: String?
    }
}
