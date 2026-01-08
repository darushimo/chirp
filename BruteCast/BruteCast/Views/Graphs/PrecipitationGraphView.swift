import SwiftUI
import Charts

struct PrecipitationGraphView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel

    let data: [HourlyWeather]
    let alerts: [WeatherAlert]
    let timeRange: TimeRange

    @State private var touchState = GraphTouchState()

    var body: some View {
        ZStack {
            BaseGraphContainer(
                data: data,
                alerts: alerts,
                timeRange: timeRange,
                graphType: .precipitation,
                touchState: $touchState
            ) {
                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Precip", point.precipitationProbability)
                        )
                        .foregroundStyle(settingsVM.currentTheme.precipitation)
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }

                    ForEach(data) { point in
                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Humidity", point.humidity)
                        )
                        .foregroundStyle(settingsVM.currentTheme.precipitation.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 2]))
                    }

                    ForEach(data) { point in
                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("UV", scaledUV(point.uvIndex))
                        )
                        .foregroundStyle(settingsVM.currentTheme.accent)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [2, 2]))
                    }
                }
                .chartYScale(domain: 0...100)
            }

            yAxisLabels

            if touchState.isDragging, let index = touchState.selectedIndex, index < data.count {
                TouchDetailOverlay(
                    position: touchState.location,
                    content: precipDetail(for: data[index])
                )
            }
        }
    }

    private func scaledUV(_ uv: Double) -> Int {
        Int(min(uv / 11.0 * 100, 100))
    }

    @ViewBuilder
    private var yAxisLabels: some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 4) {
                    legendItem(color: settingsVM.currentTheme.precipitation, label: "PRECIP", dashed: false)
                    legendItem(color: settingsVM.currentTheme.precipitation.opacity(0.4), label: "HUMID", dashed: true)
                    legendItem(color: settingsVM.currentTheme.accent, label: "UV", dashed: true)
                }
                .frame(height: 12)
                Spacer()
            }
        }
    }

    private func legendItem(color: Color, label: String, dashed: Bool) -> some View {
        HStack(spacing: 2) {
            if dashed {
                Rectangle()
                    .fill(color)
                    .frame(width: 6, height: 1)
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 2, height: 1)
                Rectangle()
                    .fill(color)
                    .frame(width: 6, height: 1)
            } else {
                Rectangle()
                    .fill(color)
                    .frame(width: 14, height: 1)
            }
            Text(label)
                .font(.custom("JetBrainsMono-Regular", size: 6))
                .foregroundColor(settingsVM.currentTheme.text.opacity(0.5))
        }
    }

    private func precipDetail(for weather: HourlyWeather) -> [(String, String)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE h:mma"
        return [
            (formatter.string(from: weather.timestamp).uppercased(), ""),
            ("\(weather.precipitationProbability)%", "precip"),
            ("\(weather.humidity)%", "humid"),
            ("\(Int(weather.uvIndex))", "UV")
        ]
    }
}

struct PrecipitationGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let data = MockWeatherData.generateHourlyData(hours: 12)
        PrecipitationGraphView(
            data: data,
            alerts: [MockAlerts.floodWatch],
            timeRange: .twelveHours
        )
        .environmentObject(SettingsViewModel())
        .frame(height: 100)
        .padding()
        .background(Color.white)
        .previewLayout(.sizeThatFits)
    }
}
