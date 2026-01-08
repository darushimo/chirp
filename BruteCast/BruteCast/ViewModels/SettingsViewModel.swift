import Foundation
import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var temperatureUnit: TemperatureUnit
    @Published var speedUnit: SpeedUnit
    @Published var currentTheme: Theme
    @Published var headerLocationMode: HeaderLocationMode
    @Published var selectedHeaderCity: City?

    @Published var backgroundColor: Color
    @Published var textColor: Color
    @Published var temperatureColor: Color
    @Published var windColor: Color
    @Published var precipitationColor: Color
    @Published var accentColor: Color

    private let settingsManager: SettingsManager
    private var cancellables = Set<AnyCancellable>()

    init(settingsManager: SettingsManager = .shared) {
        self.settingsManager = settingsManager
        let settings = settingsManager.settings

        self.temperatureUnit = settings.temperatureUnit
        self.speedUnit = settings.speedUnit
        self.currentTheme = settings.theme
        self.headerLocationMode = settings.headerLocationMode
        self.selectedHeaderCity = settings.selectedHeaderCity

        self.backgroundColor = settings.theme.background
        self.textColor = settings.theme.text
        self.temperatureColor = settings.theme.temperature
        self.windColor = settings.theme.wind
        self.precipitationColor = settings.theme.precipitation
        self.accentColor = settings.theme.accent

        setupBindings()
    }

    private func setupBindings() {
        $temperatureUnit
            .dropFirst()
            .sink { [weak self] unit in
                self?.settingsManager.settings.temperatureUnit = unit
            }
            .store(in: &cancellables)

        $speedUnit
            .dropFirst()
            .sink { [weak self] unit in
                self?.settingsManager.settings.speedUnit = unit
            }
            .store(in: &cancellables)

        $headerLocationMode
            .dropFirst()
            .sink { [weak self] mode in
                self?.settingsManager.settings.headerLocationMode = mode
            }
            .store(in: &cancellables)

        $selectedHeaderCity
            .dropFirst()
            .sink { [weak self] city in
                self?.settingsManager.settings.selectedHeaderCity = city
            }
            .store(in: &cancellables)

        Publishers.CombineLatest3(
            $backgroundColor,
            $textColor,
            $temperatureColor
        )
        .combineLatest(
            Publishers.CombineLatest3(
                $windColor,
                $precipitationColor,
                $accentColor
            )
        )
        .dropFirst()
        .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
        .sink { [weak self] colors1, colors2 in
            self?.updateThemeColors(
                background: colors1.0,
                text: colors1.1,
                temperature: colors1.2,
                wind: colors2.0,
                precipitation: colors2.1,
                accent: colors2.2
            )
        }
        .store(in: &cancellables)
    }

    private func updateThemeColors(
        background: Color,
        text: Color,
        temperature: Color,
        wind: Color,
        precipitation: Color,
        accent: Color
    ) {
        let theme = Theme(
            id: currentTheme.id,
            name: "CUSTOM",
            backgroundColor: CodableColor(color: background),
            textColor: CodableColor(color: text),
            temperatureColor: CodableColor(color: temperature),
            windColor: CodableColor(color: wind),
            precipitationColor: CodableColor(color: precipitation),
            accentColor: CodableColor(color: accent)
        )
        currentTheme = theme
        settingsManager.settings.theme = theme
    }

    func selectPresetTheme(_ theme: Theme) {
        currentTheme = theme
        backgroundColor = theme.background
        textColor = theme.text
        temperatureColor = theme.temperature
        windColor = theme.wind
        precipitationColor = theme.precipitation
        accentColor = theme.accent
        settingsManager.settings.theme = theme
    }

    func resetToDefaults() {
        selectPresetTheme(.classic)
        temperatureUnit = .fahrenheit
        speedUnit = .mph
        headerLocationMode = .currentLocation
        selectedHeaderCity = nil
    }
}
