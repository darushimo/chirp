import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let entry = WeatherEntry(
            date: Date(),
            data: AppGroup.loadWidgetData() ?? .placeholder
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!

        let entry = WeatherEntry(
            date: currentDate,
            data: AppGroup.loadWidgetData() ?? .placeholder
        )

        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}

struct WeatherEntry: TimelineEntry {
    let date: Date
    let data: WidgetWeatherEntry
}

struct BruteCastWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct BruteCastWidget: Widget {
    let kind: String = "BruteCastWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BruteCastWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("BruteCast")
        .description("Weather at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    BruteCastWidget()
} timeline: {
    WeatherEntry(date: .now, data: .placeholder)
}

#Preview(as: .systemMedium) {
    BruteCastWidget()
} timeline: {
    WeatherEntry(date: .now, data: .placeholder)
}

#Preview(as: .systemLarge) {
    BruteCastWidget()
} timeline: {
    WeatherEntry(date: .now, data: .placeholder)
}
