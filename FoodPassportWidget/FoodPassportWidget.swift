//
//  FoodPassportWidget.swift
//  FoodPassportWidget
//
//  Created by Bunnita on 2026-03-27.
//

import WidgetKit
import SwiftUI

// widget memory state
struct SimpleEntry: TimelineEntry {
    let date: Date
    let lastMealName: String
    let lastMealAddress: String
    let lastMealRating: Double
    let lastMealNotes: String
}

// fetch variables
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), lastMealName: "La Banquise", lastMealAddress: "994 Rue Rachel E", lastMealRating: 4.5, lastMealNotes: "Amazing poutine!")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), lastMealName: "La Banquise", lastMealAddress: "994 Rue Rachel E", lastMealRating: 4.5, lastMealNotes: "Amazing poutine!")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.FoodPassport")
        
        let savedName = sharedDefaults?.string(forKey: "lastMealName") ?? "No meals stamped yet"
        let savedAddress = sharedDefaults?.string(forKey: "lastMealAddress") ?? ""
        let savedRating = sharedDefaults?.double(forKey: "lastMealRating") ?? 0.0
        let savedNotes = sharedDefaults?.string(forKey: "lastMealNotes") ?? ""
        
        let entry = SimpleEntry(date: Date(), lastMealName: savedName, lastMealAddress: savedAddress, lastMealRating: savedRating, lastMealNotes: savedNotes)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// UI
struct FoodPassportWidgetEntryView : View {
    var entry: Provider.Entry
    
    // hide the notes on small widget, but show them on medium widget
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "book.closed.fill")
                    .foregroundColor(.orange)
                Text("LAST STAMPED")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.gray)
            }
            
            // restaurant name
            Text(entry.lastMealName)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            if entry.lastMealRating > 0 {
                // rating & address
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", entry.lastMealRating))
                        .font(.caption)
                        .bold()
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(entry.lastMealAddress)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // notes (only displays if notes exist AND the widget is medium size)
                if !entry.lastMealNotes.isEmpty && family == .systemMedium {
                    Text("\"\(entry.lastMealNotes)\"")
                        .font(.caption)
                        .italic()
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            Spacer(minLength: 0)
        }
        .padding()
        .containerBackground(Color(UIColor.systemBackground), for: .widget)
    }
}

// configuration
@main
struct FoodPassportWidget: Widget {
    let kind: String = "FoodPassportWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FoodPassportWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Food Passport")
        .description("Shows the last restaurant you stamped.")
        // allow small & medium sized widget
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
