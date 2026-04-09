//
//  PassportView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI
import CoreData
import FirebaseAuth

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
        predicate: NSPredicate(format: "userId == %@", Auth.auth().currentUser?.uid ?? ""),
        animation: .default)
    private var stamps: FetchedResults<Stamp>
    
    @State private var selectedSort: SortOption = .newest
    
    // filter states
    @State private var showingFilters = false
    @State private var filterCriteria = FilterCriteria()
    
    // apply filters first, then sort the results
    var filteredAndSortedStamps: [Stamp] {
            let filtered = stamps.filter { stamp in
                // round both numbers to 1 decimal place so the math matches the UI
                let displayRating = (stamp.rating * 10).rounded() / 10.0
                let filterRating = (filterCriteria.minimumRating * 10).rounded() / 10.0
                
                let meetsRating = displayRating >= filterRating
                let meetsPhoto = filterCriteria.requiresPhoto ? (stamp.photoData != nil) : true
                let meetsDetailed = filterCriteria.requiresDetailedRating ? stamp.hasDetailedRating : true
                
                return meetsRating && meetsPhoto && meetsDetailed
            }
            
            switch selectedSort {
            case .newest:
                return filtered.sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
            case .oldest:
                return filtered.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
            case .highestRated:
                return filtered.sorted { $0.rating > $1.rating }
            case .lowestRated:
                return filtered.sorted { $0.rating < $1.rating }
            }
        }
    
    var body: some View {
        NavigationStack {
            List {
                if stamps.isEmpty {
                    Text("No stamps yet. Go search and add your first meal!")
                        .foregroundColor(.secondary)
                } else if filteredAndSortedStamps.isEmpty {
                    // feedback if filters are too strict
                    Text("No stamps match your current filters.")
                        .foregroundColor(.secondary)
                        .padding(.vertical)
                } else {
                    // use the filtered array
                    ForEach(filteredAndSortedStamps) { stamp in
                        NavigationLink(destination: StampDetailView(stamp: stamp)) {
                            StampRow(stamp: stamp)
                        }
                    }
                    .onDelete(perform: deleteStamps)
                }
            }
            .navigationTitle("My Passport")
            .toolbar {
                // filter button on the leading edge
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            // fill the icon so user knows filters are currently active
                            .symbolVariant(filterCriteria.minimumRating > 1.0 || filterCriteria.requiresPhoto || filterCriteria.requiresDetailedRating ? .fill : .none)
                    }
                }
                
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
            // filter sheet
            .sheet(isPresented: $showingFilters) {
                PassportFilterView(criteria: $filterCriteria)
            }
        }
    }
    
    private func deleteStamps(offsets: IndexSet) {
        withAnimation {
            // delte from the filtered array to avoid index out-of-bounds crashes
            offsets.map { filteredAndSortedStamps[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

// subview to observe individual stamp changes
struct StampRow: View {
    @ObservedObject var stamp: Stamp
    
    var body: some View {
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
            }
        }
        .padding(.vertical, 4)
    }
}
