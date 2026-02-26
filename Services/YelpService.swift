//
//  YelpService.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import Foundation

class YelpService {
    private let apiKey = "4-U1BsQA9ezHzHnjTWu-m23iQUPHissAsHXB1etgR1WEReplwewkBWj3b4o9so-JuWrz-Slq0_EWntDo7HH65F9pc74OdiHNIPVlGBbxLtk7gwzN_mbGK0dBvcCLaXYx"
    
    func searchRestaurants(term: String, location: String) async throws -> [Restaurant] {
        let urlString = "https://api.yelp.com/v3/businesses/search?term=\(term)&location=\(location)&limit=20"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Yelp API Response: \(jsonString)")
        }
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(YelpSearchResponse.self, from: data)
        return response.businesses
    }
}
