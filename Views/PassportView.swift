//
//  PassportView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI
import CoreData

struct PassportView: View {
    // Handle deletions
    @Environment(\.managedObjectContext) private var viewContext
    
    // Automatically fetches all stamps, sorted by newest first
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Stamp.date, ascending: false)],
        animation: .default)
    private var stamps: FetchedResults<Stamp>
    
    var body: some View {
        NavigationStack {
            List {
                if stamps.isEmpty {
                    Text("No stamps yet. Go search and add your first meal!")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(stamps) { stamp in
                        NavigationLink(destination: StampDetailView(stamp: stamp)) {
                            HStack(spacing: 12) {
                                // Thumbnail of the saved photo
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
                                    Text("Rating: \(String(format: "%.1f", stamp.rating)) ⭐️")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteStamps) // Enables swipe-to-delete
                }
            }
            .navigationTitle("My Passport")
        }
    }
    
    // Function to handle the permanent deletion from CoreData
    private func deleteStamps(offsets: IndexSet) {
        withAnimation {
            // Map the swiped index to the specific stamp and delete it
            offsets.map { stamps[$0] }.forEach(viewContext.delete)
            
            // Save the database context to apply the deletion
            do {
                try viewContext.save()
            } catch {
                print("Error deleting stamp: \(error)")
            }
        }
    }
}
