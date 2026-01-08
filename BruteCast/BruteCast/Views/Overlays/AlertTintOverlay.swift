import SwiftUI

struct AlertTintOverlay: View {
    let alerts: [WeatherAlert]
    let timeRange: ClosedRange<Date>

    var body: some View {
        GeometryReader { geometry in
            ForEach(alerts, id: \.id) { alert in
                if let onset = alert.onset, let expires = alert.expires {
                    let startX = xPosition(for: onset, in: geometry)
                    let endX = xPosition(for: expires, in: geometry)

                    if startX < geometry.size.width && endX > 0 {
                        Rectangle()
                            .fill(Theme.alertTint)
                            .frame(width: max(0, endX - startX), height: geometry.size.height)
                            .position(x: (startX + endX) / 2, y: geometry.size.height / 2)
                    }
                }
            }
        }
    }

    private func xPosition(for date: Date, in geometry: GeometryProxy) -> CGFloat {
        let total = timeRange.upperBound.timeIntervalSince(timeRange.lowerBound)
        let current = date.timeIntervalSince(timeRange.lowerBound)
        let percentage = current / total
        return CGFloat(percentage) * geometry.size.width
    }
}

struct AlertTintOverlay_Previews: PreviewProvider {
    static var previews: some View {
        let now = Date()
        let later = Calendar.current.date(byAdding: .day, value: 5, to: now)!

        AlertTintOverlay(
            alerts: [MockAlerts.extremeColdWatch],
            timeRange: now...later
        )
        .frame(height: 100)
        .background(Color.white)
        .previewLayout(.sizeThatFits)
    }
}
