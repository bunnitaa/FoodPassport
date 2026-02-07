//
//  SearchView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-01-28.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                // loading & error states
                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // lust
                List(viewModel.restaurants) { restaurant in
                    NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                        
                        HStack(spacing: 12) {
                            // image placeholder
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "fork.knife")
                                        .foregroundColor(.gray)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(restaurant.name)
                                    .font(.headline)
                                
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    Text(String(format: "%.1f", restaurant.rating))
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    
                                    Text("•")
                                        .foregroundColor(.gray)
                                    
                                    Text(restaurant.price ?? "$$")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Text(restaurant.address)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)
                        
                    } // end of navlink
                }
                .listStyle(.plain)
            }
            .navigationTitle("Find Food")
            .searchable(text: $viewModel.searchText, prompt: "Search (e.g., Pizza, Sushi)")
            .onSubmit(of: .search) {
                viewModel.search()
            }
            .onChange(of: viewModel.searchText) { newValue in
                if newValue.isEmpty {
                    viewModel.search()
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
