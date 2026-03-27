//
//  PassportView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI
import CoreData

// define the available sorting options
enum SortOption: String, CaseIterable {
    case newest = "Most Recent"
    case oldest = "Oldest"
    case highestRated = "Highest Rated"
    case lowestRated = "Lowest Rated"
}

struct PassportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Stamp.date, ascending: false)],
        animation: .default)
    private var stamps: FetchedResults<Stamp>
    
    // state variable to track current selection
    @State private var selectedSort: SortOption = .newest
    
    // computed property sorts the data based on the selection
    var sortedStamps: [Stamp] {
        switch selectedSort {
        case .newest:
            return stamps.sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
        case .oldest:
            return stamps.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
        case .highestRated:
            return stamps.sorted { $0.rating > $1.rating }
        case .lowestRated:
            return stamps.sorted { $0.rating < $1.rating }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if stamps.isEmpty {
                    Text("No stamps yet. Go search and add your first meal!")
                        .foregroundColor(.secondary)
                } else {
                    // update loop to use the dynamically sorted array
                    ForEach(sortedStamps) { stamp in
                        NavigationLink(destination: StampDetailView(stamp: stamp)) {
                            HStack(spacing: 12) {
                                if let photoData = stamp.photoData, let uiImage = UIImage(data: photoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Color.gray.opacity(0.3)
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(Image(systemName: "fork.knife").foregroundColor(.gray))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(stamp.restaurantName ?? "Unknown")
                                        .font(.headline)
                                    HStack(spacing: 2) {
                                        Text("Rating: \(String(format: "%.1f", stamp.rating))")
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteStamps)
                }
            }
            .navigationTitle("My Passport")
            // sort menu to the top right of the screen
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $selectedSort) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
    
    private func deleteStamps(offsets: IndexSet) {
        withAnimation {
            // map the deletion against the sorted array, not the raw fetch request
            offsets.map { sortedStamps[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting stamp: \(error)")
            }
        }
    }
}
