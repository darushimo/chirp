import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settingsVM: SettingsViewModel

    @StateObject private var citySearchVM = CitySearchViewModel()
    @State private var showHeaderCityPicker = false

    var body: some View {
        NavigationView {
            ZStack {
                settingsVM.currentTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerLocationSection
                        unitsSection
                        themeSection
                        customColorsSection
                        resetSection
                    }
                    .padding()
                }
            }
            .navigationTitle("SETTINGS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("DONE") {
                        dismiss()
                    }
                    .font(.custom("JetBrainsMono-Bold", size: 12))
                    .foregroundColor(settingsVM.currentTheme.text)
                }
            }
        }
        .sheet(isPresented: $showHeaderCityPicker) {
            CityPickerView(slot: -1) { city in
                settingsVM.selectedHeaderCity = city
                settingsVM.headerLocationMode = .selectedCity
                showHeaderCityPicker = false
            }
            .environmentObject(settingsVM)
        }
    }

    private var headerLocationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("HEADER LOCATION")

            VStack(spacing: 8) {
                ForEach(HeaderLocationMode.allCases, id: \.self) { mode in
                    Button(action: {
                        if mode == .selectedCity {
                            showHeaderCityPicker = true
                        } else {
                            settingsVM.headerLocationMode = mode
                        }
                    }) {
                        HStack {
                            Image(systemName: settingsVM.headerLocationMode == mode ? "circle.fill" : "circle")
                                .font(.system(size: 12))
                                .foregroundColor(settingsVM.currentTheme.text)

                            Text(mode.displayName)
                                .font(.custom("JetBrainsMono-Regular", size: 12))
                                .foregroundColor(settingsVM.currentTheme.text)

                            if mode == .selectedCity, let city = settingsVM.selectedHeaderCity {
                                Text("(\(city.displayName.uppercased()))")
                                    .font(.custom("JetBrainsMono-Regular", size: 10))
                                    .foregroundColor(settingsVM.currentTheme.text.opacity(0.6))
                            }

                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding()
            .overlay(
                Rectangle()
                    .stroke(settingsVM.currentTheme.text, lineWidth: 1)
            )
        }
    }

    private var unitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("UNITS")

            VStack(spacing: 12) {
                HStack {
                    Text("TEMPERATURE")
                        .font(.custom("JetBrainsMono-Regular", size: 11))
                        .foregroundColor(settingsVM.currentTheme.text)

                    Spacer()

                    unitToggle(
                        options: TemperatureUnit.allCases,
                        selected: settingsVM.temperatureUnit,
                        label: { $0.symbol },
                        onSelect: { settingsVM.temperatureUnit = $0 }
                    )
                }

                HStack {
                    Text("SPEED")
                        .font(.custom("JetBrainsMono-Regular", size: 11))
                        .foregroundColor(settingsVM.currentTheme.text)

                    Spacer()

                    unitToggle(
                        options: SpeedUnit.allCases,
                        selected: settingsVM.speedUnit,
                        label: { $0.symbol },
                        onSelect: { settingsVM.speedUnit = $0 }
                    )
                }
            }
            .padding()
            .overlay(
                Rectangle()
                    .stroke(settingsVM.currentTheme.text, lineWidth: 1)
            )
        }
    }

    private func unitToggle<T: Hashable>(
        options: [T],
        selected: T,
        label: @escaping (T) -> String,
        onSelect: @escaping (T) -> Void
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button(action: { onSelect(option) }) {
                    Text(label(option))
                        .font(.custom("JetBrainsMono-Bold", size: 10))
                        .foregroundColor(selected == option ? settingsVM.currentTheme.background : settingsVM.currentTheme.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selected == option ? settingsVM.currentTheme.text : Color.clear)
                }
            }
        }
        .overlay(
            Rectangle()
                .stroke(settingsVM.currentTheme.text, lineWidth: 1)
        )
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("THEME")

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(Theme.presets) { theme in
                    Button(action: { settingsVM.selectPresetTheme(theme) }) {
                        Text(theme.name)
                            .font(.custom("JetBrainsMono-Bold", size: 10))
                            .foregroundColor(settingsVM.currentTheme.id == theme.id ? settingsVM.currentTheme.background : settingsVM.currentTheme.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(settingsVM.currentTheme.id == theme.id ? settingsVM.currentTheme.text : Color.clear)
                            .overlay(
                                Rectangle()
                                    .stroke(settingsVM.currentTheme.text, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    private var customColorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("CUSTOM COLORS")

            VStack(spacing: 8) {
                colorRow("BACKGROUND", color: $settingsVM.backgroundColor)
                colorRow("TEXT", color: $settingsVM.textColor)
                colorRow("TEMPERATURE", color: $settingsVM.temperatureColor)
                colorRow("WIND", color: $settingsVM.windColor)
                colorRow("PRECIPITATION", color: $settingsVM.precipitationColor)
                colorRow("ACCENT", color: $settingsVM.accentColor)
            }
            .padding()
            .overlay(
                Rectangle()
                    .stroke(settingsVM.currentTheme.text, lineWidth: 1)
            )
        }
    }

    private func colorRow(_ label: String, color: Binding<Color>) -> some View {
        HStack {
            Text(label)
                .font(.custom("JetBrainsMono-Regular", size: 11))
                .foregroundColor(settingsVM.currentTheme.text)

            Spacer()

            ColorPicker("", selection: color, supportsOpacity: false)
                .labelsHidden()
        }
    }

    private var resetSection: some View {
        Button(action: { settingsVM.resetToDefaults() }) {
            Text("RESET TO DEFAULTS")
                .font(.custom("JetBrainsMono-Bold", size: 12))
                .foregroundColor(settingsVM.currentTheme.temperature)
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(
                    Rectangle()
                        .stroke(settingsVM.currentTheme.temperature, lineWidth: 1)
                )
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.custom("JetBrainsMono-Bold", size: 12))
            .foregroundColor(settingsVM.currentTheme.text)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsViewModel())
    }
}
