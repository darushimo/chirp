import Foundation

struct HourlyWeather: Identifiable, Codable, Equatable {
    let id: UUID
    let timestamp: Date
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let precipitationProbability: Int
    let uvIndex: Double
    let windSpeed: Double
    let windGusts: Double
    let windDirection: Int

    init(
        id: UUID = UUID(),
        timestamp: Date,
        temperature: Double,
        feelsLike: Double,
        humidity: Int,
        precipitationProbability: Int,
        uvIndex: Double,
        windSpeed: Double,
        windGusts: Double,
        windDirection: Int
    ) {
        self.id = id
        self.timestamp = timestamp
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.humidity = humidity
        self.precipitationProbability = precipitationProbability
        self.uvIndex = uvIndex
        self.windSpeed = windSpeed
        self.windGusts = windGusts
        self.windDirection = windDirection
    }

    var windDirectionArrow: String {
        let directions = ["↓", "↙", "←", "↖", "↑", "↗", "→", "↘"]
        let index = Int((Double(windDirection) + 22.5) / 45.0) % 8
        return directions[index]
    }

    var windDirectionCardinal: String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((Double(windDirection) + 22.5) / 45.0) % 8
        return directions[index]
    }

    func temperature(in unit: TemperatureUnit) -> Double {
        switch unit {
        case .fahrenheit:
            return temperature
        case .celsius:
            return (temperature - 32) * 5 / 9
        }
    }

    func feelsLike(in unit: TemperatureUnit) -> Double {
        switch unit {
        case .fahrenheit:
            return feelsLike
        case .celsius:
            return (feelsLike - 32) * 5 / 9
        }
    }

    func windSpeed(in unit: SpeedUnit) -> Double {
        switch unit {
        case .mph:
            return windSpeed
        case .kmh:
            return windSpeed * 1.60934
        }
    }

    func windGusts(in unit: SpeedUnit) -> Double {
        switch unit {
        case .mph:
            return windGusts
        case .kmh:
            return windGusts * 1.60934
        }
    }
}

enum TemperatureUnit: String, Codable, CaseIterable {
    case fahrenheit = "F"
    case celsius = "C"

    var symbol: String {
        switch self {
        case .fahrenheit: return "°F"
        case .celsius: return "°C"
        }
    }
}

enum SpeedUnit: String, Codable, CaseIterable {
    case mph
    case kmh

    var symbol: String {
        switch self {
        case .mph: return "mph"
        case .kmh: return "km/h"
        }
    }
}

struct CityWeatherData: Identifiable, Codable {
    let id: UUID
    let city: City
    let hourlyData: [HourlyWeather]
    let lastUpdated: Date

    init(id: UUID = UUID(), city: City, hourlyData: [HourlyWeather], lastUpdated: Date = Date()) {
        self.id = id
        self.city = city
        self.hourlyData = hourlyData
        self.lastUpdated = lastUpdated
    }

    var currentConditions: HourlyWeather? {
        let now = Date()
        return hourlyData.min(by: { abs($0.timestamp.timeIntervalSince(now)) < abs($1.timestamp.timeIntervalSince(now)) })
    }

    func data(for range: TimeRange) -> [HourlyWeather] {
        let now = Date()
        let endDate: Date

        switch range {
        case .twelveHours:
            endDate = now.addingTimeInterval(12 * 3600)
        case .thirtySixHours:
            endDate = now.addingTimeInterval(36 * 3600)
        case .fiveDays:
            endDate = now.addingTimeInterval(120 * 3600)
        }

        return hourlyData.filter { $0.timestamp >= now && $0.timestamp <= endDate }
    }

    var temperaturePeaksAndTroughs: [(value: Double, date: Date, isPeak: Bool)] {
        guard hourlyData.count > 2 else { return [] }

        var results: [(value: Double, date: Date, isPeak: Bool)] = []
        let data = hourlyData.sorted { $0.timestamp < $1.timestamp }

        for i in 1..<(data.count - 1) {
            let prev = data[i - 1].temperature
            let curr = data[i].temperature
            let next = data[i + 1].temperature

            if curr > prev && curr > next {
                results.append((curr, data[i].timestamp, true))
            } else if curr < prev && curr < next {
                results.append((curr, data[i].timestamp, false))
            }
        }

        let calendar = Calendar.current
        var filteredResults: [(value: Double, date: Date, isPeak: Bool)] = []
        var lastDate: Date?

        for result in results {
            if let last = lastDate {
                let hoursDiff = calendar.dateComponents([.hour], from: last, to: result.date).hour ?? 0
                if hoursDiff >= 6 {
                    filteredResults.append(result)
                    lastDate = result.date
                }
            } else {
                filteredResults.append(result)
                lastDate = result.date
            }
        }

        return filteredResults
    }
}

enum TimeRange: String, CaseIterable, Identifiable {
    case twelveHours = "12H"
    case thirtySixHours = "36H"
    case fiveDays = "5D"

    var id: String { rawValue }

    var hours: Int {
        switch self {
        case .twelveHours: return 12
        case .thirtySixHours: return 36
        case .fiveDays: return 120
        }
    }
}
