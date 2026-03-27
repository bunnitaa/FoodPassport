//
//  StampDetailView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI

struct StampDetailView: View {
    // Allows the view to instantly update when the stamp is edited
    @ObservedObject var stamp: Stamp
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let photoData = stamp.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .padding(.horizontal)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 250)
                        .overlay(Text("No Photo").foregroundColor(.secondary))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(stamp.restaurantName ?? "Unknown Restaurant")
                        .font(.largeTitle)
                        .bold()
                    
                    if let address = stamp.address {
                        Text(address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Text("Rating: \(String(format: "%.1f", stamp.rating))")
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    .font(.title3)
                    .padding(.top, 4)
                        .font(.title3)
                        .padding(.top, 4)
                    
                    if let notes = stamp.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("My Notes")
                                .font(.headline)
                                .padding(.top, 8)
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider().padding(.vertical)
                    
                    // Displays both the original date and the edit date
                    VStack(alignment: .leading, spacing: 4) {
                        if let date = stamp.date {
                            Text("First stamped: \(date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if let editDate = stamp.editDate {
                            Text("Last edited: \(editDate.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Meal Details")
        .navigationBarTitleDisplayMode(.inline)
        // Adds the Edit button to the top right of the screen
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        // Slides up the edit form when the button is pressed
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditStampView(stamp: stamp)
            }
        }
    }
}
