//
//  RestaurantRowView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI

struct RestaurantRowView: View {
    let restaurant: Restaurant
    
    var body: some View {
        HStack(spacing: 12) {
            // The Yelp Image Thumbnail
            if let imageUrlString = restaurant.imageUrl, let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView() // Shows a spinner while downloading
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // Fallback gray box if Yelp has no image for this place
                Color.gray.opacity(0.3)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .font(.headline)
                
                Text(restaurant.displayAddress)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                
                if let rating = restaurant.rating {
                    HStack(spacing: 2) {
                        Text("Rating: \(String(format: "%.1f", rating))")
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RestaurantRowView(restaurant: Restaurant.mockData[0])
}
