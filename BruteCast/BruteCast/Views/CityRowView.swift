import SwiftUI

struct CityRowView: View {
    @EnvironmentObject var weatherVM: WeatherViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel

    let cityIndex: Int
    let onEditTapped: () -> Void

    @State private var showAlertPopover = false

    private var city: City? {
        let cities = SettingsManager.shared.settings.selectedCities
        guard cityIndex < cities.count else { return nil }
        return cities[cityIndex]
    }

    private var weatherData: CityWeatherData? {
        guard cityIndex < weatherVM.cityWeatherData.count else { return nil }
        return weatherVM.cityWeatherData[cityIndex]
    }

    private var alertsData: CityAlerts? {
        guard cityIndex < weatherVM.cityAlerts.count else { return nil }
        return weatherVM.cityAlerts[cityIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            cityHeader

            if let weather = weatherData {
                GeometryReader { geometry in
                    VStack(spacing: 2) {
                        TemperatureGraphView(
                            data: weather.data(for: weatherVM.selectedTimeRange),
                            alerts: alertsData?.alerts(for: .temperature) ?? [],
                            timeRange: weatherVM.selectedTimeRange
                        )
                        .frame(height: (geometry.size.height - 4) / 3)

                        WindGraphView(
                            data: weather.data(for: weatherVM.selectedTimeRange),
                            alerts: alertsData?.alerts(for: .wind) ?? [],
                            timeRange: weatherVM.selectedTimeRange
                        )
                        .frame(height: (geometry.size.height - 4) / 3)

                        PrecipitationGraphView(
                            data: weather.data(for: weatherVM.selectedTimeRange),
                            alerts: alertsData?.alerts(for: .precipitation) ?? [],
                            timeRange: weatherVM.selectedTimeRange
                        )
                        .frame(height: (geometry.size.height - 4) / 3)
                    }
                }
            } else {
                emptyState
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private var cityHeader: some View {
        HStack(spacing: 6) {
            if let city = city {
                Text(city.name.uppercased())
                    .font(.custom("JetBrainsMono-Bold", size: 11))
                    .foregroundColor(settingsVM.currentTheme.text)

                if let alerts = alertsData, !alerts.activeAlerts.isEmpty {
                    alertBadge(count: alerts.activeAlerts.count, alerts: alerts.sortedAlerts)
                }

                Spacer()

                Text(city.currentLocalTimeWithZone)
                    .font(.custom("JetBrainsMono-Regular", size: 9))
                    .foregroundColor(settingsVM.currentTheme.text.opacity(0.7))
            } else {
                Text("TAP TO ADD CITY")
                    .font(.custom("JetBrainsMono-Regular", size: 11))
                    .foregroundColor(settingsVM.currentTheme.text.opacity(0.5))

                Spacer()
            }

            Button(action: onEditTapped) {
                Text("EDIT")
                    .font(.custom("JetBrainsMono-Regular", size: 9))
                    .foregroundColor(settingsVM.currentTheme.accent)
                    .underline()
            }
            .accessibilityLabel("Edit city")
        }
        .frame(height: 24)
    }

    @ViewBuilder
    private func alertBadge(count: Int, alerts: [WeatherAlert]) -> some View {
        Button(action: { showAlertPopover = true }) {
            HStack(spacing: 2) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 9))
                    .foregroundColor(alerts.first?.severity.color ?? .yellow)

                if count > 1 {
                    Text("\(count)")
                        .font(.custom("JetBrainsMono-Bold", size: 9))
                        .foregroundColor(settingsVM.currentTheme.text)
                }
            }
        }
        .popover(isPresented: $showAlertPopover) {
            AlertPopoverView(alerts: alerts)
                .environmentObject(settingsVM)
        }
        .accessibilityLabel("\(count) weather alerts")
    }

    private var emptyState: some View {
        Button(action: onEditTapped) {
            VStack {
                Spacer()
                Text("+ ADD CITY")
                    .font(.custom("JetBrainsMono-Bold", size: 14))
                    .foregroundColor(settingsVM.currentTheme.text.opacity(0.3))
                Spacer()
            }
        }
        .accessibilityLabel("Add a city")
    }
}

struct CityRowView_Previews: PreviewProvider {
    static var previews: some View {
        let weatherVM = WeatherViewModel()
        let settingsVM = SettingsViewModel()

        weatherVM.cityWeatherData = [MockWeatherData.newYorkWeather]
        weatherVM.cityAlerts = [MockAlerts.newYorkAlerts]

        SettingsManager.shared.updateCity(at: 0, city: MockCities.newYork)

        return CityRowView(cityIndex: 0, onEditTapped: {})
            .environmentObject(weatherVM)
            .environmentObject(settingsVM)
            .frame(height: 200)
            .background(Color.white)
            .previewLayout(.sizeThatFits)
    }
}
