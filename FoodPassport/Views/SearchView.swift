//
//  SearchView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Search Area")) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.blue)
                        TextField("Enter city, neighborhood, or exact address", text: $viewModel.searchLocation)
                            .submitLabel(.search)
                            .onSubmit {
                                triggerSearch()
                            }
                    }
                }
                
                Section(header: Text("Results")) {
                    if viewModel.isLoading {
                        ProgressView("Searching...")
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red)
                    } else if viewModel.restaurants.isEmpty && !viewModel.searchText.isEmpty {
                        Text("No food locations found.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.restaurants) { restaurant in
                            NavigationLink(destination: AddStampView(restaurant: restaurant)) {
                                RestaurantRowView(restaurant: restaurant)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            // point to shared vm memory
            .searchable(text: $viewModel.searchText, prompt: "Find tacos, burgers, etc.")
            .onSubmit(of: .search) {
                triggerSearch()
            }
        }
    }
    
    private func triggerSearch() {
        guard !viewModel.searchLocation.isEmpty else { return }
        
        // if user just types a city but no food type, default to "restaurants"
        let term = viewModel.searchText.isEmpty ? "restaurants" : viewModel.searchText
        
        viewModel.performSearch(term: term, location: viewModel.searchLocation)
    }
}
