import Foundation

struct AppSettings: Codable, Equatable {
    var temperatureUnit: TemperatureUnit
    var speedUnit: SpeedUnit
    var theme: Theme
    var headerLocationMode: HeaderLocationMode
    var selectedHeaderCity: City?
    var selectedCities: [City?]
    var lastRefresh: Date?

    init(
        temperatureUnit: TemperatureUnit = .fahrenheit,
        speedUnit: SpeedUnit = .mph,
        theme: Theme = .classic,
        headerLocationMode: HeaderLocationMode = .currentLocation,
        selectedHeaderCity: City? = nil,
        selectedCities: [City?] = [nil, nil, nil],
        lastRefresh: Date? = nil
    ) {
        self.temperatureUnit = temperatureUnit
        self.speedUnit = speedUnit
        self.theme = theme
        self.headerLocationMode = headerLocationMode
        self.selectedHeaderCity = selectedHeaderCity
        self.selectedCities = selectedCities
        self.lastRefresh = lastRefresh
    }

    var validSelectedCities: [City] {
        selectedCities.compactMap { $0 }
    }

    var lastRefreshString: String? {
        guard let lastRefresh = lastRefresh else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastRefresh, relativeTo: Date())
    }

    static let `default` = AppSettings()
}

enum HeaderLocationMode: String, Codable, CaseIterable {
    case currentLocation = "current"
    case selectedCity = "selected"

    var displayName: String {
        switch self {
        case .currentLocation: return "CURRENT LOCATION"
        case .selectedCity: return "SELECT CITY"
        }
    }
}

final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let userDefaults = UserDefaults.standard
    private let settingsKey = "app_settings"

    @Published var settings: AppSettings {
        didSet {
            save()
        }
    }

    private init() {
        if let data = userDefaults.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = .default
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }
    }

    func updateCity(at index: Int, city: City?) {
        guard index >= 0 && index < 3 else { return }
        var cities = settings.selectedCities
        while cities.count <= index {
            cities.append(nil)
        }
        cities[index] = city
        settings.selectedCities = cities
    }

    func resetToDefaults() {
        settings = .default
    }
}
