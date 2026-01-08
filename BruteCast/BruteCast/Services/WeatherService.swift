import Foundation

protocol WeatherServiceProtocol {
    func fetchWeather(for city: City) async throws -> CityWeatherData
    func fetchWeather(latitude: Double, longitude: Double, timezone: String) async throws -> [HourlyWeather]
}

final class WeatherService: WeatherServiceProtocol {
    static let shared = WeatherService()

    private let session: URLSession
    private let baseURL = "https://api.open-meteo.com/v1/forecast"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchWeather(for city: City) async throws -> CityWeatherData {
        let hourlyData = try await fetchWeather(
            latitude: city.latitude,
            longitude: city.longitude,
            timezone: city.timezone
        )
        return CityWeatherData(city: city, hourlyData: hourlyData)
    }

    func fetchWeather(latitude: Double, longitude: Double, timezone: String) async throws -> [HourlyWeather] {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "hourly", value: "temperature_2m,apparent_temperature,relative_humidity_2m,precipitation_probability,uv_index,wind_speed_10m,wind_gusts_10m,wind_direction_10m"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "wind_speed_unit", value: "mph"),
            URLQueryItem(name: "timezone", value: timezone),
            URLQueryItem(name: "forecast_days", value: "7")
        ]

        guard let url = components.url else {
            throw WeatherServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherServiceError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        return parseHourlyData(from: decoded)
    }

    private func parseHourlyData(from response: OpenMeteoResponse) -> [HourlyWeather] {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]

        var hourlyWeather: [HourlyWeather] = []

        for i in 0..<min(168, response.hourly.time.count) {
            guard let timestamp = dateFormatter.date(from: response.hourly.time[i]) else { continue }

            let weather = HourlyWeather(
                timestamp: timestamp,
                temperature: response.hourly.temperature_2m[i],
                feelsLike: response.hourly.apparent_temperature[i],
                humidity: response.hourly.relative_humidity_2m[i],
                precipitationProbability: response.hourly.precipitation_probability[i],
                uvIndex: response.hourly.uv_index[i],
                windSpeed: response.hourly.wind_speed_10m[i],
                windGusts: response.hourly.wind_gusts_10m[i],
                windDirection: response.hourly.wind_direction_10m[i]
            )
            hourlyWeather.append(weather)
        }

        return hourlyWeather
    }
}

enum WeatherServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode weather data"
        case .noData:
            return "No weather data available"
        }
    }
}

struct OpenMeteoResponse: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let hourly: HourlyData

    struct HourlyData: Codable {
        let time: [String]
        let temperature_2m: [Double]
        let apparent_temperature: [Double]
        let relative_humidity_2m: [Int]
        let precipitation_probability: [Int]
        let uv_index: [Double]
        let wind_speed_10m: [Double]
        let wind_gusts_10m: [Double]
        let wind_direction_10m: [Int]
    }
}
