//
//  YelpService.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import Foundation

class YelpService {
    // dynamically fetches the key from the environment
    private var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["YELP_API_KEY"] as? String, !key.isEmpty else {
            fatalError("YELP_API_KEY is missing from Info.plist or Secrets.xcconfig")
        }
        return key
    }
    
    func searchRestaurants(term: String, location: String) async throws -> [Restaurant] {
            // categories filter to the end of this URL
            let urlString = "https://api.yelp.com/v3/businesses/search?term=\(term)&location=\(location)&limit=20&categories=restaurants,food,grocery"
            
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
