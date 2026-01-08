import Foundation
import Combine
import SwiftUI

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var headerWeather: CityWeatherData?
    @Published var headerAlerts: CityAlerts?
    @Published var cityWeatherData: [CityWeatherData] = []
    @Published var cityAlerts: [CityAlerts] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var selectedTimeRange: TimeRange = .twelveHours
    @Published var lastRefresh: Date?

    private let weatherService: WeatherServiceProtocol
    private let alertService: AlertServiceProtocol
    private let locationService: LocationService
    private let settingsManager: SettingsManager

    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?

    init(
        weatherService: WeatherServiceProtocol = WeatherService.shared,
        alertService: AlertServiceProtocol = AlertService.shared,
        locationService: LocationService = .shared,
        settingsManager: SettingsManager = .shared
    ) {
        self.weatherService = weatherService
        self.alertService = alertService
        self.locationService = locationService
        self.settingsManager = settingsManager

        setupBindings()
        setupAutoRefresh()
    }

    private func setupBindings() {
        locationService.$currentCity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] city in
                guard let self = self,
                      let city = city,
                      self.settingsManager.settings.headerLocationMode == .currentLocation else { return }
                Task {
                    await self.fetchHeaderWeather(for: city)
                }
            }
            .store(in: &cancellables)
    }

    private func setupAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.refreshAll()
            }
        }
    }

    func refreshAll() async {
        isLoading = true
        error = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchHeaderData() }

            for city in self.settingsManager.settings.validSelectedCities {
                group.addTask { await self.fetchCityData(for: city) }
            }
        }

        lastRefresh = Date()
        settingsManager.settings.lastRefresh = lastRefresh
        isLoading = false
    }

    private func fetchHeaderData() async {
        let city: City?

        switch settingsManager.settings.headerLocationMode {
        case .currentLocation:
            city = locationService.currentCity
        case .selectedCity:
            city = settingsManager.settings.selectedHeaderCity
        }

        guard let city = city else { return }
        await fetchHeaderWeather(for: city)
    }

    private func fetchHeaderWeather(for city: City) async {
        do {
            async let weatherTask = weatherService.fetchWeather(for: city)
            async let alertsTask = alertService.fetchAlerts(for: city)

            let (weather, alerts) = try await (weatherTask, alertsTask)
            headerWeather = weather
            headerAlerts = alerts
        } catch {
            self.error = error
        }
    }

    private func fetchCityData(for city: City) async {
        do {
            async let weatherTask = weatherService.fetchWeather(for: city)
            async let alertsTask = alertService.fetchAlerts(for: city)

            let (weather, alerts) = try await (weatherTask, alertsTask)

            if let index = cityWeatherData.firstIndex(where: { $0.city.id == city.id }) {
                cityWeatherData[index] = weather
            } else {
                cityWeatherData.append(weather)
            }

            if let index = cityAlerts.firstIndex(where: { $0.city.id == city.id }) {
                cityAlerts[index] = alerts
            } else {
                cityAlerts.append(alerts)
            }
        } catch {
            self.error = error
        }
    }

    func fetchWeather(for city: City, slot: Int) async {
        do {
            let weather = try await weatherService.fetchWeather(for: city)
            let alerts = try await alertService.fetchAlerts(for: city)

            while cityWeatherData.count <= slot {
                cityWeatherData.append(CityWeatherData(city: .placeholder, hourlyData: []))
            }
            while cityAlerts.count <= slot {
                cityAlerts.append(CityAlerts(city: .placeholder, alerts: []))
            }

            cityWeatherData[slot] = weather
            cityAlerts[slot] = alerts
        } catch {
            self.error = error
        }
    }

    func weather(for city: City) -> CityWeatherData? {
        cityWeatherData.first { $0.city.id == city.id }
    }

    func alerts(for city: City) -> CityAlerts? {
        cityAlerts.first { $0.city.id == city.id }
    }

    func removeCityData(at index: Int) {
        guard index < cityWeatherData.count else { return }
        cityWeatherData.remove(at: index)
        if index < cityAlerts.count {
            cityAlerts.remove(at: index)
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }
}
