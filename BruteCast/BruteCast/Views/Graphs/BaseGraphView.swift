import SwiftUI
import Charts

struct GraphTouchState {
    var isDragging: Bool = false
    var location: CGPoint = .zero
    var selectedIndex: Int?
}

protocol GraphDataPoint: Identifiable {
    var timestamp: Date { get }
}

extension HourlyWeather: GraphDataPoint {}

struct BaseGraphContainer<Content: View>: View {
    @EnvironmentObject var settingsVM: SettingsViewModel

    let data: [HourlyWeather]
    let alerts: [WeatherAlert]
    let timeRange: TimeRange
    let graphType: GraphType
    @Binding var touchState: GraphTouchState
    let content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                alertOverlay(geometry: geometry)

                content()
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: xAxisDesiredCount)) { value in
                            AxisValueLabel(format: xAxisFormat)
                                .font(.custom("JetBrainsMono-Regular", size: 7))
                                .foregroundStyle(settingsVM.currentTheme.text.opacity(0.6))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                            AxisValueLabel()
                                .font(.custom("JetBrainsMono-Regular", size: 7))
                                .foregroundStyle(settingsVM.currentTheme.text.opacity(0.6))
                        }
                    }

                if touchState.isDragging {
                    touchOverlay(geometry: geometry)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        touchState.isDragging = true
                        touchState.location = value.location
                        touchState.selectedIndex = calculateIndex(for: value.location, in: geometry)
                    }
                    .onEnded { _ in
                        touchState.isDragging = false
                    }
            )
        }
    }

    private var xAxisDesiredCount: Int {
        switch timeRange {
        case .twelveHours: return 4
        case .thirtySixHours: return 6
        case .fiveDays: return 5
        }
    }

    private var xAxisFormat: Date.FormatStyle {
        switch timeRange {
        case .twelveHours: return .dateTime.hour()
        case .thirtySixHours: return .dateTime.hour()
        case .fiveDays: return .dateTime.weekday(.abbreviated)
        }
    }

    @ViewBuilder
    private func alertOverlay(geometry: GeometryProxy) -> some View {
        let relevantAlerts = alerts.filter { $0.affectedGraphType == graphType }

        ForEach(relevantAlerts, id: \.id) { alert in
            if let onset = alert.onset, let expires = alert.expires {
                let startX = xPosition(for: onset, in: geometry)
                let endX = xPosition(for: expires, in: geometry)

                if startX < geometry.size.width && endX > 0 {
                    Rectangle()
                        .fill(Theme.alertTint)
                        .frame(width: max(0, endX - startX))
                        .position(x: (startX + endX) / 2, y: geometry.size.height / 2)
                }
            }
        }
    }

    @ViewBuilder
    private func touchOverlay(geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(settingsVM.currentTheme.text.opacity(0.3))
            .frame(width: 1)
            .position(x: touchState.location.x, y: geometry.size.height / 2)
    }

    private func xPosition(for date: Date, in geometry: GeometryProxy) -> CGFloat {
        guard let first = data.first?.timestamp, let last = data.last?.timestamp else { return 0 }
        let totalDuration = last.timeIntervalSince(first)
        let dateDuration = date.timeIntervalSince(first)
        return CGFloat(dateDuration / totalDuration) * geometry.size.width
    }

    private func calculateIndex(for location: CGPoint, in geometry: GeometryProxy) -> Int? {
        guard !data.isEmpty else { return nil }
        let percentage = location.x / geometry.size.width
        let index = Int(Double(data.count - 1) * max(0, min(1, percentage)))
        return index
    }
}
