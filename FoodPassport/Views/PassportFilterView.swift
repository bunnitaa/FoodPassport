//
//  PassportFilterView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-03-30.
//

import SwiftUI

// bundle all filter settings together
struct FilterCriteria {
    var minimumRating: Double = 1.0
    var requiresPhoto: Bool = false
    var requiresDetailedRating: Bool = false
}

struct PassportFilterView: View {
    @Environment(\.dismiss) private var dismiss
    
    // connects the filter sheet directly to the PassportView's data
    @Binding var criteria: FilterCriteria
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Minimum Rating")) {
                    Slider(value: $criteria.minimumRating, in: 1...5, step: 0.5)
                        .tint(.orange)
                    
                    HStack {
                        Text("\(String(format: "%.1f", criteria.minimumRating)) Stars & Up")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
                
                Section(header: Text("Content Requirements")) {
                    Toggle("Must Have a Photo", isOn: $criteria.requiresPhoto)
                        .tint(.orange)
                    
                    Toggle("Has Detailed Ratings", isOn: $criteria.requiresDetailedRating)
                        .tint(.orange)
                }
                
                Button("Apply Filters") {
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.vertical)
            }
            .navigationTitle("Filter Passport")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        // reset all criteria to default
                        criteria = FilterCriteria()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}
