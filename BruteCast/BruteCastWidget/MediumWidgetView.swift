import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: WeatherEntry

    var body: some View {
        HStack(spacing: 12) {
            headerSection
                .frame(maxWidth: .infinity)

            Divider()
                .background(Color.primary.opacity(0.3))

            citiesSection
                .frame(maxWidth: .infinity)
        }
        .padding(12)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("BRUTECAST")
                    .font(.custom("JetBrainsMono-Bold", size: 8))
                    .foregroundColor(.primary)

                Spacer()

                if entry.data.headerAlertCount > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.red)
                        Text("\(entry.data.headerAlertCount)")
                            .font(.custom("JetBrainsMono-Bold", size: 8))
                            .foregroundColor(.primary)
                    }
                }
            }

            Spacer()

            if let city = entry.data.headerCity,
               let conditions = entry.data.headerConditions {
                Text(city.name.uppercased())
                    .font(.custom("JetBrainsMono-Bold", size: 10))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(conditions.temperature))°")
                        .font(.custom("JetBrainsMono-Bold", size: 28))
                        .foregroundColor(.primary)
                }

                HStack(spacing: 6) {
                    Label("\(Int(conditions.windSpeed))", systemImage: "wind")
                        .font(.custom("JetBrainsMono-Regular", size: 9))
                        .foregroundColor(.secondary)

                    Label("\(conditions.precipProbability)%", systemImage: "drop.fill")
                        .font(.custom("JetBrainsMono-Regular", size: 9))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(entry.data.headerCity?.localTime ?? "--")
                .font(.custom("JetBrainsMono-Regular", size: 8))
                .foregroundColor(.secondary)
        }
    }

    private var citiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(entry.data.cities) { cityWeather in
                cityRow(cityWeather)
            }

            if entry.data.cities.isEmpty {
                Text("NO CITIES")
                    .font(.custom("JetBrainsMono-Regular", size: 9))
                    .foregroundColor(.secondary)
                Text("Open app to add cities")
                    .font(.custom("JetBrainsMono-Regular", size: 8))
                    .foregroundColor(.tertiary)
            }

            Spacer()
        }
    }

    private func cityRow(_ weather: SimpleCityWeather) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(weather.city.name.uppercased())
                        .font(.custom("JetBrainsMono-Bold", size: 9))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if weather.alertCount > 0 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 7))
                            .foregroundColor(.orange)
                    }
                }

                Text(weather.city.localTime)
                    .font(.custom("JetBrainsMono-Regular", size: 7))
                    .foregroundColor(.tertiary)
            }

            Spacer()

            Text("\(Int(weather.currentTemp))°")
                .font(.custom("JetBrainsMono-Bold", size: 14))
                .foregroundColor(.primary)
        }
    }
}

struct MediumWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidgetView(entry: WeatherEntry(date: .now, data: .placeholder))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
