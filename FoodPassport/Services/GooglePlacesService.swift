//
//  GooglePlacesService.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-03-12.
//

import Foundation

private struct GooglePlacesResponse: Codable {
    let places: [GooglePlace]?
}

private struct GooglePlace: Codable {
    let id: String
    let displayName: GoogleDisplayName
    let formattedAddress: String?
    let location: GoogleLocation?
    let rating: Double?
    let photos: [GooglePhoto]?
}

private struct GoogleDisplayName: Codable {
    let text: String
}

private struct GoogleLocation: Codable {
    let latitude: Double
    let longitude: Double
}

private struct GooglePhoto: Codable {
    let name: String
}

class GooglePlacesService {
    private var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["GOOGLE_API_KEY"] as? String, !key.isEmpty else {
            fatalError("GOOGLE_API_KEY is missing from Info.plist or Secrets.xcconfig")
        }
        return key
    }
    
    func searchRestaurants(term: String, location: String) async throws -> [Restaurant] {
        let urlString = "https://places.googleapis.com/v1/places:searchText"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(Bundle.main.bundleIdentifier ?? "com.bunnita.FoodPassport", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // tells Google exactly which pieces of data we want to download
        request.setValue("places.id,places.displayName.text,places.formattedAddress,places.location,places.rating,places.photos", forHTTPHeaderField: "X-Goog-FieldMask")
        
        let query = "\(term) in \(location)"
        let body: [String: Any] = ["textQuery": query]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown Error"
            print("Google API Error: \(errorString)")
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let googleResponse = try decoder.decode(GooglePlacesResponse.self, from: data)
        
        // translate Google data into app's format
        let restaurants = googleResponse.places?.map { place -> Restaurant in
            var photoUrl: String? = nil
            
            // google requires the API key to download the actual image file
            if let photoName = place.photos?.first?.name {
                photoUrl = "https://places.googleapis.com/v1/\(photoName)/media?maxHeightPx=400&maxWidthPx=400&key=\(apiKey)"
            }
            
            return Restaurant(
                id: place.id,
                name: place.displayName.text,
                displayAddress: place.formattedAddress ?? "No address provided",
                latitude: place.location?.latitude ?? 0.0,
                longitude: place.location?.longitude ?? 0.0,
                rating: place.rating,
                imageUrl: photoUrl
            )
        } ?? []
        
        return restaurants
    }
}
