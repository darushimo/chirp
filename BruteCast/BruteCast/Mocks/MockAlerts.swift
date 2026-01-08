import Foundation

enum MockAlerts {
    static let extremeColdWatch = WeatherAlert(
        id: "urn:oid:2.49.0.1.840.0.mock.1",
        headline: "Extreme Cold Watch issued January 8 at 10:00AM EST",
        event: "Extreme Cold Watch",
        severity: .extreme,
        certainty: "Likely",
        urgency: "Expected",
        onset: Date(),
        expires: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
        description: "Very cold temperatures expected. Wind chills may reach -20 to -30 degrees.",
        instruction: "Limit time outdoors. Dress in layers.",
        areaDesc: "New York City Metro Area",
        senderName: "NWS New York NY"
    )

    static let windAdvisory = WeatherAlert(
        id: "urn:oid:2.49.0.1.840.0.mock.2",
        headline: "Wind Advisory in effect from 6 PM this evening",
        event: "Wind Advisory",
        severity: .moderate,
        certainty: "Likely",
        urgency: "Expected",
        onset: Calendar.current.date(byAdding: .hour, value: 6, to: Date()),
        expires: Calendar.current.date(byAdding: .hour, value: 18, to: Date()),
        description: "Sustained winds 25 to 35 mph with gusts up to 50 mph expected.",
        instruction: "Secure outdoor objects.",
        areaDesc: "Coastal areas",
        senderName: "NWS New York NY"
    )

    static let floodWatch = WeatherAlert(
        id: "urn:oid:2.49.0.1.840.0.mock.3",
        headline: "Flash Flood Watch through Tuesday afternoon",
        event: "Flash Flood Watch",
        severity: .severe,
        certainty: "Possible",
        urgency: "Expected",
        onset: Date(),
        expires: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
        description: "Heavy rainfall may lead to flash flooding in low-lying areas.",
        instruction: "Monitor forecasts and be prepared to move to higher ground.",
        areaDesc: "Low-lying areas along rivers and streams",
        senderName: "NWS Miami FL"
    )

    static let heatAdvisory = WeatherAlert(
        id: "urn:oid:2.49.0.1.840.0.mock.4",
        headline: "Heat Advisory in effect until 8 PM",
        event: "Heat Advisory",
        severity: .moderate,
        certainty: "Likely",
        urgency: "Expected",
        onset: Date(),
        expires: Calendar.current.date(byAdding: .hour, value: 8, to: Date()),
        description: "Heat index values up to 105 expected.",
        instruction: "Drink plenty of fluids and stay in air-conditioned rooms.",
        areaDesc: "Urban areas",
        senderName: "NWS Los Angeles CA"
    )

    static let newYorkAlerts = CityAlerts(
        city: MockCities.newYork,
        alerts: [extremeColdWatch, windAdvisory]
    )

    static let miamiAlerts = CityAlerts(
        city: MockCities.miami,
        alerts: [floodWatch]
    )

    static let losAngelesAlerts = CityAlerts(
        city: MockCities.losAngeles,
        alerts: [heatAdvisory]
    )

    static let noAlerts = CityAlerts(
        city: MockCities.tokyo,
        alerts: []
    )

    static let allSampleAlerts: [CityAlerts] = [
        newYorkAlerts, miamiAlerts, losAngelesAlerts, noAlerts
    ]
}
