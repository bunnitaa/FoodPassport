//
//  AddStampView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI
import PhotosUI
import CoreData

struct AddStampView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let restaurant: Restaurant
    
    // standard rating
    @State private var rating: Double = 3.0
    
    // detail ratings options
    @State private var useDetailedRatings: Bool = false
    @State private var foodRating: Double = 3.0
    @State private var serviceRating: Double = 3.0
    @State private var valueRating: Double = 3.0
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data? = nil
    @State private var notes: String = ""
    
    // calculate average if detail rating on
    private var calculatedOverallRating: Double {
        if useDetailedRatings {
            return (foodRating + serviceRating + valueRating) / 3.0
        }
        return rating
    }
    
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
                Toggle("Use Detailed Rating", isOn: $useDetailedRatings)
                    .tint(.orange)
                
                if useDetailedRatings {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Food: \(String(format: "%.1f", foodRating))")
                        Slider(value: $foodRating, in: 1...5, step: 0.5)
                        
                        Text("Service: \(String(format: "%.1f", serviceRating))")
                        Slider(value: $serviceRating, in: 1...5, step: 0.5)
                        
                        Text("Value: \(String(format: "%.1f", valueRating))")
                        Slider(value: $valueRating, in: 1...5, step: 0.5)
                        
                        Divider()
                        
                        HStack {
                            Text("Overall Average:")
                                .bold()
                            Spacer()
                            Text(String(format: "%.1f", calculatedOverallRating))
                                .bold()
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                } else {
                    Slider(value: $rating, in: 1...5, step: 0.5)
                    HStack {
                        Text("Rating: \(String(format: "%.1f", rating))")
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
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
                // dynamically save calculated rating
                let finalRatingToSave = calculatedOverallRating
                
                PersistenceController.shared.saveStamp(
                    restaurantId: restaurant.id,
                    name: restaurant.name,
                    address: restaurant.displayAddress,
                    latitude: restaurant.latitude,
                    longitude: restaurant.longitude,
                    rating: finalRatingToSave,
                    hasDetailedRating: useDetailedRatings,
                    foodRating: foodRating,
                    serviceRating: serviceRating,
                    valueRating: valueRating,
                    notes: notes.isEmpty ? nil : notes,
                    photoData: selectedPhotoData,
                    context: viewContext
                )
                
                dismiss()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.vertical)
        }
        .navigationTitle("Add to Passport")
    }
}
