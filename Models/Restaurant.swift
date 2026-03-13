//
//  Restaurant.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import Foundation

struct Restaurant: Identifiable {
    let id: String
    let name: String
    let displayAddress: String
    let latitude: Double
    let longitude: Double
    let rating: Double?
    let imageUrl: String?
    
    // fallback data 
    static let mockData = [
        Restaurant(id: "1", name: "La Banquise", displayAddress: "994 Rue Rachel E, Montreal, QC", latitude: 45.5254, longitude: -73.5747, rating: 4.5, imageUrl: nil),
        Restaurant(id: "2", name: "Schwartz's Deli", displayAddress: "3895 St Laurent Blvd, Montreal, QC", latitude: 45.5163, longitude: -73.5776, rating: 4.0, imageUrl: nil),
        Restaurant(id: "3", name: "Joe Beef", displayAddress: "2491 Notre-Dame St W, Montreal, QC", latitude: 45.4831, longitude: -73.5753, rating: 4.8, imageUrl: nil)
    ]
}
