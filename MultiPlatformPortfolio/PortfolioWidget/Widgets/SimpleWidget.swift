//
//  SimpleWidget.swift
//  MultiPlatformPortfolio (iOS)
//
//  Created by Jordain on 05/10/2021.
//

import SwiftUI
import WidgetKit

struct SimpleWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Up next…")
                .font(.title)

            if let item = entry.items.first {
                Text(item.itemTitle)
            } else {
                Text("Nothing!")
            }
        }
    }
}

// MARK: - Widgets
struct SimpleWidget: Widget { // Determines how our widget should be configured
    let kind: String = "SimplePortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SimpleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Up next…")
        .description("Your #1 top-priority item.")
    }
}

struct PortfolioWidget_Previews: PreviewProvider {
 static var previews: some View {
     SimpleWidgetEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
