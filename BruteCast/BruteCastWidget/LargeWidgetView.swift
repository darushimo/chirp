import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: WeatherEntry

    var body: some View {
        VStack(spacing: 8) {
            headerSection

            Divider()
                .background(Color.primary.opacity(0.3))

            ForEach(entry.data.cities) { cityWeather in
                cityDetailRow(cityWeather)

                if cityWeather.id != entry.data.cities.last?.id {
                    Divider()
                        .background(Color.primary.opacity(0.2))
                }
            }

            if entry.data.cities.isEmpty {
                Spacer()
                Text("NO CITIES CONFIGURED")
                    .font(.custom("JetBrainsMono-Regular", size: 10))
                    .foregroundColor(.secondary)
                Text("Open app to add cities")
                    .font(.custom("JetBrainsMono-Regular", size: 9))
                    .foregroundStyle(.tertiary)
                Spacer()
            }

            Spacer()
        }
        .padding(12)
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("BRUTECAST")
                        .font(.custom("JetBrainsMono-Bold", size: 10))
                        .foregroundColor(.primary)

                    if entry.data.headerAlertCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.red)
                            Text("\(entry.data.headerAlertCount)")
                                .font(.custom("JetBrainsMono-Bold", size: 9))
                                .foregroundColor(.primary)
                        }
                    }
                }

                if let city = entry.data.headerCity {
                    Text(city.name.uppercased())
                        .font(.custom("JetBrainsMono-Regular", size: 9))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if let conditions = entry.data.headerConditions {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(conditions.temperature))°F")
                        .font(.custom("JetBrainsMono-Bold", size: 24))
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        Label("\(Int(conditions.windSpeed))", systemImage: "wind")
                            .font(.custom("JetBrainsMono-Regular", size: 9))
                            .foregroundColor(.secondary)

                        Label("\(conditions.precipProbability)%", systemImage: "drop.fill")
                            .font(.custom("JetBrainsMono-Regular", size: 9))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private func cityDetailRow(_ weather: SimpleCityWeather) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(weather.city.name.uppercased())
                        .font(.custom("JetBrainsMono-Bold", size: 11))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if weather.alertCount > 0 {
                        HStack(spacing: 1) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.orange)
                            if weather.alertCount > 1 {
                                Text("\(weather.alertCount)")
                                    .font(.custom("JetBrainsMono-Bold", size: 8))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }

                Text("\(weather.city.localTime) \(weather.city.timezone)")
                    .font(.custom("JetBrainsMono-Regular", size: 8))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(weather.currentTemp))°")
                    .font(.custom("JetBrainsMono-Bold", size: 18))
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    Text("H:\(Int(weather.highTemp))°")
                        .font(.custom("JetBrainsMono-Regular", size: 8))
                        .foregroundColor(.secondary)

                    Text("L:\(Int(weather.lowTemp))°")
                        .font(.custom("JetBrainsMono-Regular", size: 8))
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 2) {
                    Image(systemName: "wind")
                        .font(.system(size: 8))
                    Text("\(Int(weather.conditions.windSpeed))")
                        .font(.custom("JetBrainsMono-Regular", size: 9))
                }
                .foregroundColor(.secondary)

                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 8))
                    Text("\(weather.conditions.precipProbability)%")
                        .font(.custom("JetBrainsMono-Regular", size: 9))
                }
                .foregroundColor(.secondary)
            }
            .frame(width: 50)
        }
        .padding(.vertical, 4)
    }
}

struct LargeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        LargeWidgetView(entry: WeatherEntry(date: .now, data: .placeholder))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
