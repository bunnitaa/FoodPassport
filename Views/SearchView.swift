//
//  SearchView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    ProgressView("Searching...")
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                } else {
                    // Loop through the results
                    ForEach(viewModel.restaurants) { restaurant in
                        // Wrap the row in a NavigationLink
                        NavigationLink(destination: AddStampView(restaurant: restaurant)) {
                            RestaurantRowView(restaurant: restaurant)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search restaurants (e.g. Tacos)")
            .onSubmit(of: .search) {
                viewModel.performSearch(term: searchText)
            }
        }
    }
}
