//
//  SearchViewModel.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let googleService = GooglePlacesService()
    
    func performSearch(term: String, location: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                self.restaurants = try await googleService.searchRestaurants(term: term, location: location)
                self.isLoading = false
            } catch {
                print("API Failed: \(error.localizedDescription). Loading offline mock data.")
                self.restaurants = Restaurant.mockData
                self.isLoading = false
            }
        }
    }
}
