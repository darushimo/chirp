import SwiftUI

struct MainView: View {
    @EnvironmentObject var weatherVM: WeatherViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var locationService: LocationService

    @State private var showSettings = false
    @State private var showCityPicker = false
    @State private var editingCitySlot: Int?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                settingsVM.currentTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HeaderView(
                        showSettings: $showSettings,
                        selectedTimeRange: $weatherVM.selectedTimeRange
                    )
                    .frame(height: headerHeight(for: geometry))

                    Divider()
                        .background(settingsVM.currentTheme.text)

                    ForEach(0..<3, id: \.self) { index in
                        CityRowView(
                            cityIndex: index,
                            onEditTapped: {
                                editingCitySlot = index
                                showCityPicker = true
                            }
                        )
                        .frame(height: cityRowHeight(for: geometry))

                        if index < 2 {
                            Divider()
                                .background(settingsVM.currentTheme.text)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settingsVM)
        }
        .sheet(isPresented: $showCityPicker) {
            CityPickerView(
                slot: editingCitySlot ?? 0,
                onCitySelected: { city in
                    if let slot = editingCitySlot {
                        SettingsManager.shared.updateCity(at: slot, city: city)
                        Task {
                            await weatherVM.fetchWeather(for: city, slot: slot)
                        }
                    }
                    showCityPicker = false
                }
            )
            .environmentObject(settingsVM)
        }
        .task {
            await weatherVM.refreshAll()
        }
        .preferredColorScheme(settingsVM.currentTheme.background == Theme.dark.background ? .dark : .light)
    }

    private func headerHeight(for geometry: GeometryProxy) -> CGFloat {
        let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
        return safeHeight * 0.12
    }

    private func cityRowHeight(for geometry: GeometryProxy) -> CGFloat {
        let safeHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
        let headerSpace = safeHeight * 0.12
        let dividersSpace: CGFloat = 4
        return (safeHeight - headerSpace - dividersSpace) / 3
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let weatherVM = WeatherViewModel()
        let settingsVM = SettingsViewModel()
        let locationService = LocationService.shared

        MainView()
            .environmentObject(weatherVM)
            .environmentObject(settingsVM)
            .environmentObject(locationService)
    }
}
