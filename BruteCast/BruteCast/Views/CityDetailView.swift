import SwiftUI

struct CityDetailView: View {
    @EnvironmentObject var weatherVM: WeatherViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedCityIndex: Int
    let onEditTapped: (Int) -> Void

    private var cities: [City?] {
        SettingsManager.shared.settings.selectedCities
    }

    private var validCityIndices: [Int] {
        cities.indices.filter { cities[$0] != nil }
    }

    var body: some View {
        ZStack {
            settingsVM.currentTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Divider()
                    .background(settingsVM.currentTheme.text)

                TabView(selection: $selectedCityIndex) {
                    ForEach(0..<3, id: \.self) { index in
                        if cities[index] != nil {
                            CityDetailPageView(
                                cityIndex: index,
                                onEditTapped: { onEditTapped(index) }
                            )
                            .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("BACK")
                        .font(.custom("JetBrainsMono-Bold", size: 12))
                }
                .foregroundColor(settingsVM.currentTheme.accent)
            }

            Spacer()

            timeRangeToggle
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var timeRangeToggle: some View {
        HStack(spacing: 0) {
            ForEach(TimeRange.allCases) { range in
                Button(action: { weatherVM.selectedTimeRange = range }) {
                    Text(range.rawValue)
                        .font(.custom("JetBrainsMono-Bold", size: 11))
                        .foregroundColor(weatherVM.selectedTimeRange == range ? settingsVM.currentTheme.background : settingsVM.currentTheme.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(weatherVM.selectedTimeRange == range ? settingsVM.currentTheme.text : Color.clear)
                }
            }
        }
        .overlay(
            Rectangle()
                .stroke(settingsVM.currentTheme.text, lineWidth: 1)
        )
    }
}

struct CityDetailPageView: View {
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
                .padding(.horizontal, 16)
                .padding(.top, 8)

            if let weather = weatherData {
                VStack(spacing: 16) {
                    graphSection(title: "TEMPERATURE") {
                        TemperatureGraphView(
                            data: weather.data(for: weatherVM.selectedTimeRange),
                            alerts: alertsData?.alerts(for: .temperature) ?? [],
                            timeRange: weatherVM.selectedTimeRange
                        )
                    }

                    graphSection(title: "WIND") {
                        WindGraphView(
                            data: weather.data(for: weatherVM.selectedTimeRange),
                            alerts: alertsData?.alerts(for: .wind) ?? [],
                            timeRange: weatherVM.selectedTimeRange
                        )
                    }

                    graphSection(title: "PRECIPITATION") {
                        PrecipitationGraphView(
                            data: weather.data(for: weatherVM.selectedTimeRange),
                            alerts: alertsData?.alerts(for: .precipitation) ?? [],
                            timeRange: weatherVM.selectedTimeRange
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else {
                emptyState
            }

            Spacer()
        }
    }

    private var cityHeader: some View {
        HStack(spacing: 8) {
            if let city = city {
                Text(city.name.uppercased())
                    .font(.custom("JetBrainsMono-Bold", size: 18))
                    .foregroundColor(settingsVM.currentTheme.text)

                if let alerts = alertsData, !alerts.activeAlerts.isEmpty {
                    alertBadge(count: alerts.activeAlerts.count, alerts: alerts.sortedAlerts)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(city.currentLocalTimeWithZone)
                        .font(.custom("JetBrainsMono-Regular", size: 11))
                        .foregroundColor(settingsVM.currentTheme.text.opacity(0.7))

                    if let country = city.country {
                        Text(country.uppercased())
                            .font(.custom("JetBrainsMono-Regular", size: 9))
                            .foregroundColor(settingsVM.currentTheme.text.opacity(0.5))
                    }
                }
            }

            Button(action: onEditTapped) {
                Text("EDIT")
                    .font(.custom("JetBrainsMono-Regular", size: 10))
                    .foregroundColor(settingsVM.currentTheme.accent)
                    .underline()
            }
        }
    }

    @ViewBuilder
    private func alertBadge(count: Int, alerts: [WeatherAlert]) -> some View {
        Button(action: { showAlertPopover = true }) {
            HStack(spacing: 3) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(alerts.first?.severity.color ?? .yellow)

                if count > 1 {
                    Text("\(count)")
                        .font(.custom("JetBrainsMono-Bold", size: 11))
                        .foregroundColor(settingsVM.currentTheme.text)
                }
            }
        }
        .popover(isPresented: $showAlertPopover) {
            AlertPopoverView(alerts: alerts)
                .environmentObject(settingsVM)
        }
    }

    @ViewBuilder
    private func graphSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("JetBrainsMono-Bold", size: 10))
                .foregroundColor(settingsVM.currentTheme.text.opacity(0.5))

            content()
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.2)
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Button(action: onEditTapped) {
                Text("+ SELECT CITY")
                    .font(.custom("JetBrainsMono-Bold", size: 16))
                    .foregroundColor(settingsVM.currentTheme.text.opacity(0.3))
            }
            Spacer()
        }
    }
}

struct CityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let weatherVM = WeatherViewModel()
        let settingsVM = SettingsViewModel()

        CityDetailView(
            selectedCityIndex: .constant(0),
            onEditTapped: { _ in }
        )
        .environmentObject(weatherVM)
        .environmentObject(settingsVM)
    }
}
