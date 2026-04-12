//
//  SearchView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    // access core data from this view
    @Environment(\.managedObjectContext) private var viewContext
    
    // pptional state to show a quick confirmation toast/alert
    @State private var showingWishlistAlert = false
    @State private var justAddedRestaurantName = ""
    
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
                            // swipe actions added here!
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    addToWishlist(restaurant: restaurant)
                                } label: {
                                    Label("To-Try", systemImage: "bookmark.fill")
                                }
                                .tint(.blue)
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
            // alert to let the user know the swipe worked
            .alert("Added to Wishlist!", isPresented: $showingWishlistAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("\(justAddedRestaurantName) is now on your To-Try list.")
            }
        }
    }
    
    private func triggerSearch() {
        guard !viewModel.searchLocation.isEmpty else { return }
        
        // if user just types a city but no food type, default to "restaurants"
        let term = viewModel.searchText.isEmpty ? "restaurants" : viewModel.searchText
        
        viewModel.performSearch(term: term, location: viewModel.searchLocation)
    }
    
    // helper function to trigger the save
    private func addToWishlist(restaurant: Restaurant) {
        PersistenceController.shared.saveToWishlist(restaurant: restaurant, context: viewContext)
        justAddedRestaurantName = restaurant.name
        showingWishlistAlert = true
    }
}
