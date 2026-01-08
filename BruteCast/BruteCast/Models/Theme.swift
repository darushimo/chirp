import SwiftUI

struct Theme: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    var backgroundColor: CodableColor
    var textColor: CodableColor
    var temperatureColor: CodableColor
    var windColor: CodableColor
    var precipitationColor: CodableColor
    var accentColor: CodableColor

    init(
        id: UUID = UUID(),
        name: String,
        backgroundColor: CodableColor,
        textColor: CodableColor,
        temperatureColor: CodableColor,
        windColor: CodableColor,
        precipitationColor: CodableColor,
        accentColor: CodableColor
    ) {
        self.id = id
        self.name = name
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.temperatureColor = temperatureColor
        self.windColor = windColor
        self.precipitationColor = precipitationColor
        self.accentColor = accentColor
    }

    var background: Color { backgroundColor.color }
    var text: Color { textColor.color }
    var temperature: Color { temperatureColor.color }
    var wind: Color { windColor.color }
    var precipitation: Color { precipitationColor.color }
    var accent: Color { accentColor.color }

    static let alertTint = Color(red: 1.0, green: 0, blue: 0.4).opacity(0.15)
}

struct CodableColor: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double

    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.opacity = Double(a)
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

extension Theme {
    static let classic = Theme(
        name: "CLASSIC",
        backgroundColor: CodableColor(red: 1, green: 1, blue: 1),
        textColor: CodableColor(red: 0, green: 0, blue: 0),
        temperatureColor: CodableColor(red: 1, green: 0, blue: 0),
        windColor: CodableColor(red: 0, green: 0, blue: 1),
        precipitationColor: CodableColor(red: 0, green: 0.6, blue: 0),
        accentColor: CodableColor(red: 1, green: 0.8, blue: 0)
    )

    static let dark = Theme(
        name: "DARK",
        backgroundColor: CodableColor(red: 0, green: 0, blue: 0),
        textColor: CodableColor(red: 1, green: 1, blue: 1),
        temperatureColor: CodableColor(red: 1, green: 0.3, blue: 0.3),
        windColor: CodableColor(red: 0.4, green: 0.6, blue: 1),
        precipitationColor: CodableColor(red: 0.3, green: 0.8, blue: 0.3),
        accentColor: CodableColor(red: 1, green: 0.9, blue: 0.2)
    )

    static let mono = Theme(
        name: "MONO",
        backgroundColor: CodableColor(red: 1, green: 1, blue: 1),
        textColor: CodableColor(red: 0, green: 0, blue: 0),
        temperatureColor: CodableColor(red: 0.2, green: 0.2, blue: 0.2),
        windColor: CodableColor(red: 0.4, green: 0.4, blue: 0.4),
        precipitationColor: CodableColor(red: 0.6, green: 0.6, blue: 0.6),
        accentColor: CodableColor(red: 0.3, green: 0.3, blue: 0.3)
    )

    static let highContrast = Theme(
        name: "HI-CON",
        backgroundColor: CodableColor(red: 0, green: 0, blue: 0),
        textColor: CodableColor(red: 1, green: 1, blue: 0),
        temperatureColor: CodableColor(red: 1, green: 0, blue: 1),
        windColor: CodableColor(red: 0, green: 1, blue: 1),
        precipitationColor: CodableColor(red: 0, green: 1, blue: 0),
        accentColor: CodableColor(red: 1, green: 1, blue: 1)
    )

    static let colorBlindSafe = Theme(
        name: "CB-SAFE",
        backgroundColor: CodableColor(red: 1, green: 1, blue: 1),
        textColor: CodableColor(red: 0, green: 0, blue: 0),
        temperatureColor: CodableColor(red: 0.9, green: 0.6, blue: 0),
        windColor: CodableColor(red: 0, green: 0.45, blue: 0.7),
        precipitationColor: CodableColor(red: 0, green: 0.6, blue: 0.5),
        accentColor: CodableColor(red: 0.8, green: 0.4, blue: 0)
    )

    static let presets: [Theme] = [classic, dark, mono, highContrast, colorBlindSafe]
}
