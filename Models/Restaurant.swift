//
//  Restaurant.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import Foundation

struct YelpSearchResponse: Codable {
    let businesses: [Restaurant]
}

// Helper struct to read Yelp's nested location data
struct RestaurantLocation: Codable {
    let displayAddress: [String]?
    
    enum CodingKeys: String, CodingKey {
        case displayAddress = "display_address"
    }
}

struct Restaurant: Identifiable, Codable {
    let id: String
    let name: String
    let imageUrl: String?
    let rating: Double?
    let location: RestaurantLocation?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl = "image_url"
        case rating
        case location
    }
    
    // Helper variable to format the array of address lines into a single readable string
    var displayAddress: String {
        location?.displayAddress?.joined(separator: ", ") ?? "No address available"
    }
    
    // Updated Mock Data
    static let mockData = [
        Restaurant(id: "1", name: "La Banquise", imageUrl: nil, rating: 4.5, location: RestaurantLocation(displayAddress: ["994 Rue Rachel E", "Montreal, QC H2J 2J3"])),
        Restaurant(id: "2", name: "Schwartz's Deli", imageUrl: nil, rating: 4.0, location: RestaurantLocation(displayAddress: ["3895 St Laurent Blvd", "Montreal, QC H2W 1X9"])),
        Restaurant(id: "3", name: "Joe Beef", imageUrl: nil, rating: 4.8, location: RestaurantLocation(displayAddress: ["2491 Notre-Dame St W", "Montreal, QC H3J 1N6"]))
    ]
}
