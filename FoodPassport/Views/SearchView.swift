//
//  SearchView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var searchText = ""
    @State private var locationText = "Montreal, QC" // default search area
    
    var body: some View {
        NavigationStack {
            List {
                // adress/city input field
                Section(header: Text("Search Area")) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.blue)
                        TextField("Enter city, neighborhood, or exact address", text: $locationText)
                            .submitLabel(.search)
                            .onSubmit {
                                triggerSearch()
                            }
                    }
                }
                
                // results
                Section(header: Text("Results")) {
                    if viewModel.isLoading {
                        ProgressView("Searching...")
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red)
                    } else if viewModel.restaurants.isEmpty && !searchText.isEmpty {
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
            // restaurant name input field
            .searchable(text: $searchText, prompt: "Find tacos, burgers, etc.")
            .onSubmit(of: .search) {
                triggerSearch()
            }
        }
    }
    
    // helper function to ensure both inputs trigger the exact same API call
    private func triggerSearch() {
        guard !searchText.isEmpty, !locationText.isEmpty else { return }
        viewModel.performSearch(term: searchText, location: locationText)
    }
}
