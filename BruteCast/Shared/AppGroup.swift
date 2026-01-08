import Foundation

enum AppGroup {
    static let identifier = "group.com.brutecast.app"

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }

    static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }

    static func saveWidgetData(_ entry: WidgetWeatherEntry) {
        guard let userDefaults = userDefaults else { return }
        if let encoded = try? JSONEncoder().encode(entry) {
            userDefaults.set(encoded, forKey: "widget_weather_data")
        }
    }

    static func loadWidgetData() -> WidgetWeatherEntry? {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: "widget_weather_data"),
              let entry = try? JSONDecoder().decode(WidgetWeatherEntry.self, from: data) else {
            return nil
        }
        return entry
    }
}

extension CityWeatherData {
    func toSimpleCityWeather(alertCount: Int = 0) -> SimpleCityWeather {
        let current = currentConditions ?? hourlyData.first
        let temps = hourlyData.prefix(24).map { $0.temperature }
        let high = temps.max() ?? 0
        let low = temps.min() ?? 0

        return SimpleCityWeather(
            city: SimpleCity(
                name: city.displayName,
                timezone: city.timezoneAbbreviation,
                localTime: city.currentLocalTime
            ),
            currentTemp: current?.temperature ?? 0,
            highTemp: high,
            lowTemp: low,
            conditions: SimpleConditions(
                temperature: current?.temperature ?? 0,
                feelsLike: current?.feelsLike ?? 0,
                windSpeed: current?.windSpeed ?? 0,
                windDirection: current?.windDirectionCardinal ?? "N",
                humidity: current?.humidity ?? 0,
                precipProbability: current?.precipitationProbability ?? 0,
                uvIndex: current?.uvIndex ?? 0
            ),
            alertCount: alertCount
        )
    }
}
