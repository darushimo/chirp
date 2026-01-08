import Foundation

struct WidgetWeatherEntry: Codable {
    let date: Date
    let headerCity: SimpleCity?
    let headerConditions: SimpleConditions?
    let headerAlertCount: Int
    let cities: [SimpleCityWeather]

    init(
        date: Date = Date(),
        headerCity: SimpleCity? = nil,
        headerConditions: SimpleConditions? = nil,
        headerAlertCount: Int = 0,
        cities: [SimpleCityWeather] = []
    ) {
        self.date = date
        self.headerCity = headerCity
        self.headerConditions = headerConditions
        self.headerAlertCount = headerAlertCount
        self.cities = cities
    }
}

struct SimpleCity: Codable {
    let name: String
    let timezone: String
    let localTime: String
}

struct SimpleConditions: Codable {
    let temperature: Double
    let feelsLike: Double
    let windSpeed: Double
    let windDirection: String
    let humidity: Int
    let precipProbability: Int
    let uvIndex: Double
}

struct SimpleCityWeather: Codable, Identifiable {
    let id: UUID
    let city: SimpleCity
    let currentTemp: Double
    let highTemp: Double
    let lowTemp: Double
    let conditions: SimpleConditions
    let alertCount: Int

    init(
        id: UUID = UUID(),
        city: SimpleCity,
        currentTemp: Double,
        highTemp: Double,
        lowTemp: Double,
        conditions: SimpleConditions,
        alertCount: Int = 0
    ) {
        self.id = id
        self.city = city
        self.currentTemp = currentTemp
        self.highTemp = highTemp
        self.lowTemp = lowTemp
        self.conditions = conditions
        self.alertCount = alertCount
    }
}

extension WidgetWeatherEntry {
    static let placeholder = WidgetWeatherEntry(
        date: Date(),
        headerCity: SimpleCity(name: "New York", timezone: "EST", localTime: "5:42PM"),
        headerConditions: SimpleConditions(
            temperature: 72,
            feelsLike: 68,
            windSpeed: 12,
            windDirection: "NE",
            humidity: 65,
            precipProbability: 20,
            uvIndex: 6
        ),
        headerAlertCount: 1,
        cities: [
            SimpleCityWeather(
                city: SimpleCity(name: "Tokyo", timezone: "JST", localTime: "7:42AM"),
                currentTemp: 68,
                highTemp: 72,
                lowTemp: 58,
                conditions: SimpleConditions(
                    temperature: 68, feelsLike: 66, windSpeed: 8,
                    windDirection: "E", humidity: 70, precipProbability: 10, uvIndex: 4
                ),
                alertCount: 0
            ),
            SimpleCityWeather(
                city: SimpleCity(name: "London", timezone: "GMT", localTime: "10:42PM"),
                currentTemp: 55,
                highTemp: 58,
                lowTemp: 48,
                conditions: SimpleConditions(
                    temperature: 55, feelsLike: 52, windSpeed: 15,
                    windDirection: "W", humidity: 80, precipProbability: 60, uvIndex: 2
                ),
                alertCount: 2
            )
        ]
    )
}
