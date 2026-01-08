import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: WeatherEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("BRUTECAST")
                    .font(.custom("JetBrainsMono-Bold", size: 8))
                    .foregroundColor(.primary)

                Spacer()

                if entry.data.headerAlertCount > 0 {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.red)
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
                        .font(.custom("JetBrainsMono-Bold", size: 32))
                        .foregroundColor(.primary)

                    Text("F")
                        .font(.custom("JetBrainsMono-Regular", size: 12))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 8) {
                    Label("\(Int(conditions.windSpeed))", systemImage: "wind")
                        .font(.custom("JetBrainsMono-Regular", size: 9))
                        .foregroundColor(.secondary)

                    Label("\(conditions.precipProbability)%", systemImage: "drop.fill")
                        .font(.custom("JetBrainsMono-Regular", size: 9))
                        .foregroundColor(.secondary)
                }
            } else {
                Text("NO DATA")
                    .font(.custom("JetBrainsMono-Regular", size: 10))
                    .foregroundColor(.secondary)

                Text("Open app to configure")
                    .font(.custom("JetBrainsMono-Regular", size: 8))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            HStack {
                Text(entry.data.headerCity?.localTime ?? "--")
                    .font(.custom("JetBrainsMono-Regular", size: 8))
                    .foregroundColor(.secondary)

                Spacer()

                Text(entry.data.headerCity?.timezone ?? "")
                    .font(.custom("JetBrainsMono-Regular", size: 8))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(entry: WeatherEntry(date: .now, data: .placeholder))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
