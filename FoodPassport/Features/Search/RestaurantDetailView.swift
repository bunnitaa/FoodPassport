//
//  RestaurantDetailView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-07.
//

import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // image placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 250)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 10) {
                    // title + rating
                    Text(restaurant.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", restaurant.rating))
                            .fontWeight(.bold)
                        Text("(\(restaurant.reviewCount) reviews)")
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // info rows
                    Label(restaurant.address, systemImage: "map.fill")
                    Label(restaurant.price ?? "$$", systemImage: "dollarsign.circle.fill")
                    
                    Spacer()
                    
                    // action button for next iteration
                    Button(action: {
                        print("Open Stamp Modal")
                    }) {
                        Text("Stamp to Passport")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
