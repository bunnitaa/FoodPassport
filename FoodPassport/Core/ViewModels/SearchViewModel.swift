//
//  SearchViewModel.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-01-28.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    // Published property updates UI automatically when changes
    @Published var restaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    init() {
        // load mock data
        self.restaurants = getMockData()
    }
    
    // to replace with real API call after
    func search() {
            // if search empty = show all
            if searchText.isEmpty {
                self.restaurants = self.getMockData()
                self.errorMessage = nil
                return
            }
            
            isLoading = true
            errorMessage = nil
            
            // simulating network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isLoading = false
                
                // filter the mock data based on search text
                let results = self.getMockData().filter {
                    $0.name.localizedCaseInsensitiveContains(self.searchText)
                }
                
                self.restaurants = results
                
                if self.restaurants.isEmpty {
                    self.errorMessage = "No restaurants found for '\(self.searchText)'"
                }
            }
        }
    
    // temp mock data
    private func getMockData() -> [Restaurant] {
        return [
            Restaurant(id: "1", name: "Joe's Pizza", rating: 4.5, price: "$$", address: "123 Main St, Montreal"),
            Restaurant(id: "2", name: "Sushi Shop", rating: 3.8, price: "$$$", address: "456 St-Catherine, Montreal"),
            Restaurant(id: "3", name: "La Banquise", rating: 5.0, price: "$", address: "994 Rue Rachel E, Montreal"),
            Restaurant(id: "4", name: "Schwartz's Deli", rating: 4.8, price: "$$", address: "3895 St-Laurent, Montreal")
        ]
    }
}
