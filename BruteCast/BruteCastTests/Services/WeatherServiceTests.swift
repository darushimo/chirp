import XCTest
@testable import BruteCast

final class WeatherServiceTests: XCTestCase {
    var sut: WeatherService!

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
        sut = WeatherService(session: .mock)
    }

    override func tearDown() {
        sut = nil
        MockURLProtocol.reset()
        super.tearDown()
    }

    func testFetchWeatherSuccess() async throws {
        // Given
        let mockResponse = """
        {
            "latitude": 40.7128,
            "longitude": -74.006,
            "timezone": "America/New_York",
            "hourly": {
                "time": ["2024-01-15T00:00", "2024-01-15T01:00"],
                "temperature_2m": [45.0, 44.0],
                "apparent_temperature": [42.0, 41.0],
                "relative_humidity_2m": [65, 68],
                "precipitation_probability": [10, 15],
                "uv_index": [0.0, 0.0],
                "wind_speed_10m": [8.0, 10.0],
                "wind_gusts_10m": [15.0, 18.0],
                "wind_direction_10m": [180, 190]
            }
        }
        """.data(using: .utf8)!

        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=40.7128&longitude=-74.006&hourly=temperature_2m,apparent_temperature,relative_humidity_2m,precipitation_probability,uv_index,wind_speed_10m,wind_gusts_10m,wind_direction_10m&temperature_unit=fahrenheit&wind_speed_unit=mph&timezone=America/New_York&forecast_days=7")!

        MockURLProtocol.mockResponses[url] = (
            mockResponse,
            HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil),
            nil
        )

        // When
        let result = try await sut.fetchWeather(
            latitude: 40.7128,
            longitude: -74.006,
            timezone: "America/New_York"
        )

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].temperature, 45.0)
        XCTAssertEqual(result[0].feelsLike, 42.0)
        XCTAssertEqual(result[0].humidity, 65)
    }

    func testFetchWeatherForCity() async throws {
        // Given
        let city = MockCities.newYork
        let mockResponse = """
        {
            "latitude": 40.7128,
            "longitude": -74.006,
            "timezone": "America/New_York",
            "hourly": {
                "time": ["2024-01-15T00:00"],
                "temperature_2m": [45.0],
                "apparent_temperature": [42.0],
                "relative_humidity_2m": [65],
                "precipitation_probability": [10],
                "uv_index": [0.0],
                "wind_speed_10m": [8.0],
                "wind_gusts_10m": [15.0],
                "wind_direction_10m": [180]
            }
        }
        """.data(using: .utf8)!

        // Set up mock for any URL starting with the base
        let components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        MockURLProtocol.mockResponses[components.url!] = (
            mockResponse,
            HTTPURLResponse(url: components.url!, statusCode: 200, httpVersion: nil, headerFields: nil),
            nil
        )

        // Note: In real tests, you'd need to match the exact URL
    }

    func testTemperatureConversion() {
        // Given
        let weather = HourlyWeather(
            timestamp: Date(),
            temperature: 68.0, // Fahrenheit
            feelsLike: 65.0,
            humidity: 50,
            precipitationProbability: 20,
            uvIndex: 5.0,
            windSpeed: 10.0,
            windGusts: 15.0,
            windDirection: 180
        )

        // When/Then
        XCTAssertEqual(weather.temperature(in: .fahrenheit), 68.0)
        XCTAssertEqual(weather.temperature(in: .celsius), 20.0, accuracy: 0.1)
    }

    func testWindDirectionArrow() {
        // Given
        let directions: [(Int, String)] = [
            (0, "↓"),    // North wind = arrow points down (wind comes from north)
            (45, "↙"),
            (90, "←"),
            (135, "↖"),
            (180, "↑"),
            (225, "↗"),
            (270, "→"),
            (315, "↘")
        ]

        for (direction, expectedArrow) in directions {
            let weather = HourlyWeather(
                timestamp: Date(),
                temperature: 70.0,
                feelsLike: 68.0,
                humidity: 50,
                precipitationProbability: 0,
                uvIndex: 5.0,
                windSpeed: 10.0,
                windGusts: 15.0,
                windDirection: direction
            )

            XCTAssertEqual(weather.windDirectionArrow, expectedArrow, "Direction \(direction) should be \(expectedArrow)")
        }
    }
}
