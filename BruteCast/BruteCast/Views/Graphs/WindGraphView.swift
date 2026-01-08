import SwiftUI
import Charts

struct WindGraphView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel

    let data: [HourlyWeather]
    let alerts: [WeatherAlert]
    let timeRange: TimeRange

    @State private var touchState = GraphTouchState()

    private var speedUnit: SpeedUnit {
        settingsVM.speedUnit
    }

    var body: some View {
        ZStack {
            BaseGraphContainer(
                data: data,
                alerts: alerts,
                timeRange: timeRange,
                graphType: .wind,
                touchState: $touchState
            ) {
                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Speed", point.windSpeed(in: speedUnit))
                        )
                        .foregroundStyle(settingsVM.currentTheme.wind)
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }

                    ForEach(data) { point in
                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Gusts", point.windGusts(in: speedUnit))
                        )
                        .foregroundStyle(settingsVM.currentTheme.wind.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 2]))
                    }
                }
                .chartYScale(domain: windRange)
            }

            directionArrows

            if touchState.isDragging, let index = touchState.selectedIndex, index < data.count {
                TouchDetailOverlay(
                    position: touchState.location,
                    content: windDetail(for: data[index])
                )
            }
        }
    }

    private var windRange: ClosedRange<Double> {
        let speeds = data.flatMap { [
            $0.windSpeed(in: speedUnit),
            $0.windGusts(in: speedUnit)
        ]}
        let max = (speeds.max() ?? 50) + 10
        return 0...max
    }

    @ViewBuilder
    private var directionArrows: some View {
        GeometryReader { geometry in
            let step = max(1, data.count / 12)
            let sampledData = stride(from: 0, to: data.count, by: step).map { data[$0] }

            ForEach(Array(sampledData.enumerated()), id: \.offset) { index, point in
                let xPos = xPosition(for: point.timestamp, in: geometry)

                Text(point.windDirectionArrow)
                    .font(.system(size: 8))
                    .foregroundColor(settingsVM.currentTheme.wind)
                    .position(x: xPos, y: 8)
            }
        }
    }

    private func xPosition(for date: Date, in geometry: GeometryProxy) -> CGFloat {
        guard let first = data.first?.timestamp, let last = data.last?.timestamp else { return 0 }
        let total = last.timeIntervalSince(first)
        let current = date.timeIntervalSince(first)
        return CGFloat(current / total) * geometry.size.width
    }

    private func windDetail(for weather: HourlyWeather) -> [(String, String)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE h:mma"
        return [
            (formatter.string(from: weather.timestamp).uppercased(), ""),
            ("\(weather.windDirectionCardinal) \(weather.windDirectionArrow)", ""),
            ("\(Int(weather.windSpeed(in: speedUnit))) \(speedUnit.symbol)", ""),
            ("\(Int(weather.windGusts(in: speedUnit)))", "gust")
        ]
    }
}

struct WindGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let data = MockWeatherData.generateHourlyData(hours: 12)
        WindGraphView(
            data: data,
            alerts: [MockAlerts.windAdvisory],
            timeRange: .twelveHours
        )
        .environmentObject(SettingsViewModel())
        .frame(height: 100)
        .padding()
        .background(Color.white)
        .previewLayout(.sizeThatFits)
    }
}
