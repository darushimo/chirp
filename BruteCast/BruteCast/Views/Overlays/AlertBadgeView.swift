import SwiftUI

struct AlertBadgeView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel

    let alerts: [WeatherAlert]
    let onTap: () -> Void

    private var topAlert: WeatherAlert? {
        alerts.sorted { $0.severity.priority > $1.severity.priority }.first
    }

    var body: some View {
        if !alerts.isEmpty, let alert = topAlert {
            Button(action: onTap) {
                HStack(spacing: 2) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(alert.severity.color)

                    if alerts.count > 1 {
                        Text("\(alerts.count)")
                            .font(.custom("JetBrainsMono-Bold", size: 9))
                            .foregroundColor(settingsVM.currentTheme.text)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }
            .accessibilityLabel("\(alerts.count) weather alert\(alerts.count > 1 ? "s" : "")")
        }
    }
}

struct AlertBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AlertBadgeView(
                alerts: [MockAlerts.extremeColdWatch],
                onTap: {}
            )

            AlertBadgeView(
                alerts: [MockAlerts.extremeColdWatch, MockAlerts.windAdvisory],
                onTap: {}
            )

            AlertBadgeView(
                alerts: [],
                onTap: {}
            )
        }
        .environmentObject(SettingsViewModel())
        .padding()
        .background(Color.white)
        .previewLayout(.sizeThatFits)
    }
}
