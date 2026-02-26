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
    
    private let yelpService = YelpService()
    
    func performSearch(term: String, location: String = "Montreal") {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                self.restaurants = try await yelpService.searchRestaurants(term: term, location: location)
                self.isLoading = false
            } catch {
                self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}
