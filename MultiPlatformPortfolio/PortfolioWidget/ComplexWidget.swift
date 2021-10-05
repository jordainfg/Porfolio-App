//
//  ComplexWidget.swift
//  MultiPlatformPortfolio (iOS)
//
//  Created by Jordain on 05/10/2021.
//

import SwiftUI
import WidgetKit

struct PortfolioWidgetMultipleEntryView: View {
    let entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    var items: ArraySlice<Item> {
        let itemCount: Int

        switch widgetFamily {
        case .systemSmall:
            itemCount = 1
        case .systemMedium:
            itemCount = 2
        case .systemLarge:
            itemCount = 4
        default:
            itemCount = 2
        }

        return entry.items.prefix(itemCount)
    }
    var body: some View {
        VStack(spacing: 5) {
            ForEach(items) { item in
                HStack {
                    Color(item.project?.color ?? "Light Blue")
                        .frame(width: 5)
                        .clipShape(Capsule())

                    VStack(alignment: .leading) {
                        Text(item.itemTitle)
                            .font(.headline)

                        if let projectTitle = item.project?.projectTitle {
                            Text(projectTitle)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()
                }
            }
        }
        .padding(20)
    }
}

struct ComplexPortfolioWidget: Widget { // Determines how our widget should be configured
    let kind: String = "ComplexPortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PortfolioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Up next…")
        .description("Your most important items.")
    }
}

struct ComplexPortfolioWidget_Previews: PreviewProvider {
 static var previews: some View {
     PortfolioWidgetMultipleEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
