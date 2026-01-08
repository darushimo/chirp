import SwiftUI

@main
struct BruteCastApp: App {
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var locationService = LocationService.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(weatherViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(locationService)
                .onAppear {
                    locationService.requestPermission()
                }
        }
    }
}
