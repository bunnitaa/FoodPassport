//
//  Restaurant.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-01-28.
//

import Foundation

// Yelp API structure
struct Restaurant: Identifiable, Decodable {
    let id: String
    let name: String
    let imageUrl: String?
    let rating: Double
    let reviewCount: Int
    let price: String?
    let address: String
    
    // CodingKeys help decode JSON from Yelp
    enum CodingKeys: String, CodingKey {
        case id, name, rating, price
        case imageUrl = "image_url"
        case reviewCount = "review_count"
        case location
    }
    
    // flatten address
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        rating = try container.decode(Double.self, forKey: .rating)
        reviewCount = try container.decode(Int.self, forKey: .reviewCount)
        price = try container.decodeIfPresent(String.self, forKey: .price)
        
        // Flatten address from Yelp's nested "location" object
        let locationContainer = try container.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        let addressArray = try locationContainer.decodeIfPresent([String].self, forKey: .displayAddress) ?? []
        address = addressArray.joined(separator: ", ")
    }
    
    enum LocationKeys: String, CodingKey {
        case displayAddress = "display_address"
    }
    
    // MOCK DATA INIT  (For now only)
    init(id: String, name: String, rating: Double, price: String, address: String) {
        self.id = id
        self.name = name
        self.imageUrl = "https://example.com/image"
        self.rating = rating
        self.reviewCount = 100
        self.price = price
        self.address = address
    }
}
