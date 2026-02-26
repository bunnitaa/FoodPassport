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
    
    @ObservedObject var stamp: Stamp // Observes the live database object
    
    @State private var rating: Double
    @State private var notes: String
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data?
    
    // Initialize the state variables with the existing stamp data
    init(stamp: Stamp) {
        self.stamp = stamp
        _rating = State(initialValue: stamp.rating)
        _notes = State(initialValue: stamp.notes ?? "")
        _selectedPhotoData = State(initialValue: stamp.photoData)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Update Rating")) {
                Slider(value: $rating, in: 1...5, step: 0.5)
                Text("Rating: \(String(format: "%.1f", rating)) ⭐️")
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
                PersistenceController.shared.updateStamp(
                    stamp: stamp,
                    newRating: rating,
                    newNotes: notes.isEmpty ? nil : notes,
                    newPhotoData: selectedPhotoData,
                    context: viewContext
                )
                dismiss()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .buttonStyle(.borderedProminent)
            .padding(.vertical)
        }
        .navigationTitle("Edit Stamp")
        .navigationBarTitleDisplayMode(.inline)
    }
}
