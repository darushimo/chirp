import Foundation

enum MockWeatherData {
    static func generateHourlyData(
        startDate: Date = Date(),
        hours: Int = 168,
        baseTemp: Double = 70,
        tempVariation: Double = 15
    ) -> [HourlyWeather] {
        var data: [HourlyWeather] = []
        let calendar = Calendar.current

        for hour in 0..<hours {
            guard let timestamp = calendar.date(byAdding: .hour, value: hour, to: startDate) else { continue }

            let hourOfDay = calendar.component(.hour, from: timestamp)
            let dayProgress = Double(hourOfDay) / 24.0

            let tempOffset = sin(dayProgress * .pi * 2 - .pi / 2) * tempVariation
            let temperature = baseTemp + tempOffset + Double.random(in: -3...3)
            let feelsLike = temperature + Double.random(in: -5...5)

            let weather = HourlyWeather(
                timestamp: timestamp,
                temperature: temperature,
                feelsLike: feelsLike,
                humidity: Int.random(in: 30...90),
                precipitationProbability: Int.random(in: 0...100),
                uvIndex: Double.random(in: 0...11),
                windSpeed: Double.random(in: 0...25),
                windGusts: Double.random(in: 5...40),
                windDirection: Int.random(in: 0...359)
            )
            data.append(weather)
        }

        return data
    }

    static func sampleCityWeatherData(for city: City) -> CityWeatherData {
        CityWeatherData(
            city: city,
            hourlyData: generateHourlyData()
        )
    }

    static var newYorkWeather: CityWeatherData {
        sampleCityWeatherData(for: MockCities.newYork)
    }

    static var tokyoWeather: CityWeatherData {
        sampleCityWeatherData(for: MockCities.tokyo)
    }

    static var londonWeather: CityWeatherData {
        sampleCityWeatherData(for: MockCities.london)
    }

    static var allSampleWeather: [CityWeatherData] {
        [newYorkWeather, tokyoWeather, londonWeather]
    }
}
