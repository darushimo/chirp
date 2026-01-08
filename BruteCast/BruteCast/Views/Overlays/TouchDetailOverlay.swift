import SwiftUI

struct TouchDetailOverlay: View {
    @EnvironmentObject var settingsVM: SettingsViewModel

    let position: CGPoint
    let content: [(String, String)]

    var body: some View {
        GeometryReader { geometry in
            let overlayWidth: CGFloat = 80
            let overlayHeight = CGFloat(content.count * 16 + 12)

            let xPos = min(max(overlayWidth / 2 + 8, position.x), geometry.size.width - overlayWidth / 2 - 8)
            let yPos = max(overlayHeight + 8, position.y - 20)

            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(content.enumerated()), id: \.offset) { index, item in
                    detailRow(value: item.0, label: item.1, isFirst: index == 0)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(settingsVM.currentTheme.background)
            .overlay(
                Rectangle()
                    .stroke(settingsVM.currentTheme.text, lineWidth: 1)
            )
            .position(x: xPos, y: yPos - overlayHeight / 2)
        }
    }

    @ViewBuilder
    private func detailRow(value: String, label: String, isFirst: Bool) -> some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.custom(isFirst ? "JetBrainsMono-Bold" : "JetBrainsMono-Regular", size: isFirst ? 10 : 11))
                .foregroundColor(settingsVM.currentTheme.text)

            if !label.isEmpty {
                Text(label)
                    .font(.custom("JetBrainsMono-Regular", size: 8))
                    .foregroundColor(settingsVM.currentTheme.text.opacity(0.5))
            }
        }
    }
}

struct TouchDetailOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.white

            TouchDetailOverlay(
                position: CGPoint(x: 150, y: 100),
                content: [
                    ("TUE 2:00PM", ""),
                    ("72°F", "actual"),
                    ("68°F", "feels")
                ]
            )
            .environmentObject(SettingsViewModel())
        }
        .frame(width: 300, height: 200)
        .previewLayout(.sizeThatFits)
    }
}
