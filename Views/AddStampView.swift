//
//  AddStampView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI
import PhotosUI

struct AddStampView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let restaurant: Restaurant
    
    @State private var rating: Double = 3.0
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data? = nil
    @State private var notes: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Restaurant Info")) {
                Text(restaurant.name)
                    .font(.headline)
                Text(restaurant.displayAddress)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Your Rating")) {
                Slider(value: $rating, in: 1...5, step: 0.5)
                Text("Rating: \(String(format: "%.1f", rating)) ⭐️")
            }
            
            Section(header: Text("Personal Notes (Optional)")) {
                TextField("What did you think of the food?", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section(header: Text("Memory (Optional)")) {
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Label("Select a Photo of your meal", systemImage: "photo")
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedPhotoData = data
                        }
                    }
                }
                
                if let photoData = selectedPhotoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .cornerRadius(8)
                }
            }
            
            Button("Save Stamp") {
                PersistenceController.shared.saveStamp(
                    restaurantId: restaurant.id,
                    name: restaurant.name,
                    address: restaurant.displayAddress,
                    rating: rating,
                    notes: notes.isEmpty ? nil : notes, // Pass nil if they left it blank
                    photoData: selectedPhotoData,
                    context: viewContext
                )
                dismiss() // Close the form
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .buttonStyle(.borderedProminent)
            .padding(.vertical)
        }
        .navigationTitle("Add to Passport")
    }
}
