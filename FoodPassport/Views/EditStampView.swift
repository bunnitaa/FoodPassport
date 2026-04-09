//
//  EditStampView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI
import PhotosUI

struct EditStampView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var stamp: Stamp
    
    @State private var rating: Double
    @State private var useDetailedRatings: Bool = false
    @State private var foodRating: Double = 3.0
    @State private var serviceRating: Double = 3.0
    @State private var valueRating: Double = 3.0
    
    @State private var notes: String
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data?
    
    // calculate average if detail rating is toggled on
    private var calculatedOverallRating: Double {
        if useDetailedRatings {
            return (foodRating + serviceRating + valueRating) / 3.0
        }
        return rating
    }
    
    // initialize the state variables with existing data directly from the database
    init(stamp: Stamp) {
        self.stamp = stamp
        _rating = State(initialValue: stamp.rating)
        _notes = State(initialValue: stamp.notes ?? "")
        _selectedPhotoData = State(initialValue: stamp.photoData)
        
        _useDetailedRatings = State(initialValue: stamp.hasDetailedRating)
        _foodRating = State(initialValue: stamp.hasDetailedRating ? stamp.foodRating : stamp.rating)
        _serviceRating = State(initialValue: stamp.hasDetailedRating ? stamp.serviceRating : stamp.rating)
        _valueRating = State(initialValue: stamp.hasDetailedRating ? stamp.valueRating : stamp.rating)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Restaurant Info")) {
                Text(stamp.restaurantName ?? "Unknown Restaurant")
                    .font(.headline)
                Text(stamp.address ?? "No Address Provided")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Update Rating")) {
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
                            Text("New Overall Average:")
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
            
            Section(header: Text("Update Notes")) {
                TextField("What did you think of the food?", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section(header: Text("Update Photo")) {
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Label(selectedPhotoData == nil ? "Select a Photo" : "Change Photo", systemImage: "photo")
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
            
            Button("Save Changes") {
                // use the calculated average for the final save
                let finalRatingToSave = calculatedOverallRating
                
                PersistenceController.shared.updateStamp(
                    stamp: stamp,
                    newRating: finalRatingToSave,
                    hasDetailedRating: useDetailedRatings,
                    newFoodRating: foodRating,
                    newServiceRating: serviceRating,
                    newValueRating: valueRating,
                    newNotes: notes.isEmpty ? nil : notes,
                    newPhotoData: selectedPhotoData,
                    context: viewContext
                )
                dismiss()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.vertical)
        }
        .navigationTitle("Edit Stamp")
        .navigationBarTitleDisplayMode(.inline)
    }
}
