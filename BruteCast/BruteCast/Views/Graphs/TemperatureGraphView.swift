import SwiftUI
import Charts

struct TemperatureGraphView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel

    let data: [HourlyWeather]
    let alerts: [WeatherAlert]
    let timeRange: TimeRange

    @State private var touchState = GraphTouchState()

    private var tempUnit: TemperatureUnit {
        settingsVM.temperatureUnit
    }

    var body: some View {
        ZStack {
            BaseGraphContainer(
                data: data,
                alerts: alerts,
                timeRange: timeRange,
                graphType: .temperature,
                touchState: $touchState
            ) {
                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Temp", point.temperature(in: tempUnit))
                        )
                        .foregroundStyle(settingsVM.currentTheme.temperature)
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }

                    ForEach(data) { point in
                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Feels", point.feelsLike(in: tempUnit))
                        )
                        .foregroundStyle(settingsVM.currentTheme.temperature.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 2]))
                    }
                }
                .chartYScale(domain: temperatureRange)
            }

            peakTroughLabels

            if touchState.isDragging, let index = touchState.selectedIndex, index < data.count {
                TouchDetailOverlay(
                    position: touchState.location,
                    content: temperatureDetail(for: data[index])
                )
            }
        }
    }

    private var temperatureRange: ClosedRange<Double> {
        let temps = data.flatMap { [
            $0.temperature(in: tempUnit),
            $0.feelsLike(in: tempUnit)
        ]}
        let min = (temps.min() ?? 0) - 5
        let max = (temps.max() ?? 100) + 5
        return min...max
    }

    @ViewBuilder
    private var peakTroughLabels: some View {
        GeometryReader { geometry in
            let peaks = calculatePeaksTroughs()

            ForEach(Array(peaks.enumerated()), id: \.offset) { index, peak in
                let xPos = xPosition(for: peak.date, in: geometry)
                let yPos = yPosition(for: peak.value, in: geometry)

                Text("\(Int(peak.value))\(tempUnit.symbol)")
                    .font(.custom("JetBrainsMono-Bold", size: 8))
                    .foregroundColor(settingsVM.currentTheme.temperature)
                    .position(x: xPos, y: peak.isPeak ? yPos - 10 : yPos + 10)
            }
        }
    }

    private func calculatePeaksTroughs() -> [(value: Double, date: Date, isPeak: Bool)] {
        guard data.count > 2 else { return [] }

        var results: [(value: Double, date: Date, isPeak: Bool)] = []

        for i in 1..<(data.count - 1) {
            let prev = data[i - 1].temperature(in: tempUnit)
            let curr = data[i].temperature(in: tempUnit)
            let next = data[i + 1].temperature(in: tempUnit)

            if curr > prev && curr > next {
                results.append((curr, data[i].timestamp, true))
            } else if curr < prev && curr < next {
                results.append((curr, data[i].timestamp, false))
            }
        }

        let filteredResults = filterPeaksByTime(results, minHours: timeRange == .fiveDays ? 12 : 6)
        return Array(filteredResults.prefix(timeRange.hours / 12 * 2))
    }

    private func filterPeaksByTime(_ peaks: [(value: Double, date: Date, isPeak: Bool)], minHours: Int) -> [(value: Double, date: Date, isPeak: Bool)] {
        var filtered: [(value: Double, date: Date, isPeak: Bool)] = []
        var lastDate: Date?

        for peak in peaks {
            if let last = lastDate {
                let hours = Calendar.current.dateComponents([.hour], from: last, to: peak.date).hour ?? 0
                if hours >= minHours {
                    filtered.append(peak)
                    lastDate = peak.date
                }
            } else {
                filtered.append(peak)
                lastDate = peak.date
            }
        }

        return filtered
    }

    private func xPosition(for date: Date, in geometry: GeometryProxy) -> CGFloat {
        guard let first = data.first?.timestamp, let last = data.last?.timestamp else { return 0 }
        let total = last.timeIntervalSince(first)
        let current = date.timeIntervalSince(first)
        return CGFloat(current / total) * geometry.size.width
    }

    private func yPosition(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let range = temperatureRange
        let normalized = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return geometry.size.height * (1 - CGFloat(normalized))
    }

    private func temperatureDetail(for weather: HourlyWeather) -> [(String, String)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE h:mma"
        return [
            (formatter.string(from: weather.timestamp).uppercased(), ""),
            ("\(Int(weather.temperature(in: tempUnit)))\(tempUnit.symbol)", "actual"),
            ("\(Int(weather.feelsLike(in: tempUnit)))\(tempUnit.symbol)", "feels")
        ]
    }
}

struct TemperatureGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let data = MockWeatherData.generateHourlyData(hours: 12)
        TemperatureGraphView(
            data: data,
            alerts: [MockAlerts.extremeColdWatch],
            timeRange: .twelveHours
        )
        .environmentObject(SettingsViewModel())
        .frame(height: 100)
        .padding()
        .background(Color.white)
        .previewLayout(.sizeThatFits)
    }
}
