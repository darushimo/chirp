import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var weatherVM: WeatherViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var locationService: LocationService

    @Binding var showSettings: Bool
    @Binding var selectedTimeRange: TimeRange

    var body: some View {
        HStack(spacing: 8) {
            Button(action: { showSettings = true }) {
                Text("BRUTECAST")
                    .font(.custom("JetBrainsMono-Bold", size: 14))
                    .foregroundColor(settingsVM.currentTheme.text)
                    .underline()
            }
            .accessibilityLabel("Open settings")

            Button(action: { Task { await weatherVM.refreshAll() } }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(settingsVM.currentTheme.text)
            }
            .accessibilityLabel("Refresh weather data")

            Spacer()

            alertsSection

            Spacer()

            currentConditionsSection

            timeRangeToggle
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var alertsSection: some View {
        if let alerts = weatherVM.headerAlerts, !alerts.activeAlerts.isEmpty {
            let topAlert = alerts.sortedAlerts.first!
            Button(action: {
                if let url = topAlert.weatherKitURL {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(topAlert.severity.color)

                    Text(topAlert.shortName)
                        .font(.custom("JetBrainsMono-Regular", size: 9))
                        .foregroundColor(settingsVM.currentTheme.text)
                        .lineLimit(1)
                }
            }
            .accessibilityLabel("Weather alert: \(topAlert.shortName)")
        }
    }

    @ViewBuilder
    private var currentConditionsSection: some View {
        if let weather = weatherVM.headerWeather,
           let current = weather.currentConditions {
            let tempUnit = settingsVM.temperatureUnit
            let temp = Int(current.temperature(in: tempUnit))

            HStack(spacing: 4) {
                Text("\(temp)\(tempUnit.symbol)")
                    .font(.custom("JetBrainsMono-Bold", size: 12))
                    .foregroundColor(settingsVM.currentTheme.text)

                Text(conditionText(for: current))
                    .font(.custom("JetBrainsMono-Regular", size: 10))
                    .foregroundColor(settingsVM.currentTheme.text)
                    .lineLimit(1)
            }
        } else if locationService.authorizationStatus == .denied {
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("ENABLE LOCATION")
                    .font(.custom("JetBrainsMono-Regular", size: 10))
                    .foregroundColor(settingsVM.currentTheme.accent)
                    .underline()
            }
        } else if weatherVM.isLoading {
            ProgressView()
                .scaleEffect(0.7)
        }
    }

    private var timeRangeToggle: some View {
        HStack(spacing: 2) {
            ForEach(TimeRange.allCases) { range in
                Button(action: { selectedTimeRange = range }) {
                    Text(range.rawValue)
                        .font(.custom("JetBrainsMono-Bold", size: 10))
                        .foregroundColor(selectedTimeRange == range ? settingsVM.currentTheme.background : settingsVM.currentTheme.text)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(
                            selectedTimeRange == range ? settingsVM.currentTheme.text : Color.clear
                        )
                        .overlay(
                            Rectangle()
                                .stroke(settingsVM.currentTheme.text, lineWidth: 1)
                        )
                }
                .accessibilityLabel("\(range.rawValue) time range")
            }
        }
    }

    private func conditionText(for weather: HourlyWeather) -> String {
        let speedUnit = settingsVM.speedUnit
        let windSpeed = Int(weather.windSpeed(in: speedUnit))

        if windSpeed > 20 {
            return "WINDY"
        } else if weather.precipitationProbability > 60 {
            return "RAIN"
        } else if weather.humidity > 80 {
            return "HUMID"
        } else if weather.uvIndex > 8 {
            return "SUNNY"
        } else {
            return "CLEAR"
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let weatherVM = WeatherViewModel()
        let settingsVM = SettingsViewModel()

        HeaderView(
            showSettings: .constant(false),
            selectedTimeRange: .constant(.twelveHours)
        )
        .environmentObject(weatherVM)
        .environmentObject(settingsVM)
        .environmentObject(LocationService.shared)
        .background(Color.white)
        .previewLayout(.sizeThatFits)
    }
}
