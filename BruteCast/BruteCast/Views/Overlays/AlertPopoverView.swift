import SwiftUI

struct AlertPopoverView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.dismiss) var dismiss

    let alerts: [WeatherAlert]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ALERTS")
                .font(.custom("JetBrainsMono-Bold", size: 12))
                .foregroundColor(settingsVM.currentTheme.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            Divider()
                .background(settingsVM.currentTheme.text)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(alerts, id: \.id) { alert in
                        alertRow(alert)

                        if alert.id != alerts.last?.id {
                            Divider()
                                .background(settingsVM.currentTheme.text.opacity(0.3))
                        }
                    }
                }
            }
        }
        .frame(minWidth: 250, maxWidth: 300)
        .background(settingsVM.currentTheme.background)
    }

    private func alertRow(_ alert: WeatherAlert) -> some View {
        Button(action: {
            if let url = alert.weatherKitURL {
                UIApplication.shared.open(url)
            }
            dismiss()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(alert.severity.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(alert.event.uppercased())
                        .font(.custom("JetBrainsMono-Bold", size: 11))
                        .foregroundColor(settingsVM.currentTheme.text)
                        .lineLimit(2)

                    if let expires = alert.expires {
                        Text("UNTIL \(formatDate(expires))")
                            .font(.custom("JetBrainsMono-Regular", size: 9))
                            .foregroundColor(settingsVM.currentTheme.text.opacity(0.6))
                    }
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10))
                    .foregroundColor(settingsVM.currentTheme.text.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .accessibilityLabel("View \(alert.event) alert details")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE h:mma"
        return formatter.string(from: date).uppercased()
    }
}

struct AlertPopoverView_Previews: PreviewProvider {
    static var previews: some View {
        AlertPopoverView(
            alerts: [MockAlerts.extremeColdWatch, MockAlerts.windAdvisory]
        )
        .environmentObject(SettingsViewModel())
        .previewLayout(.sizeThatFits)
    }
}
