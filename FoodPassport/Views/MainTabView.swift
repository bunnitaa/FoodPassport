//
//  MainTabView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var searchViewModel = SearchViewModel()
    
    var body: some View {
        TabView {
            SearchView(viewModel: searchViewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            MapView(viewModel: searchViewModel)
                .tabItem {
                    Label("Passport Map", systemImage: "map")
                }
                
            PassportView()
                .tabItem {
                    Label("My Stamps", systemImage: "book.closed")
                }
        }
        .tint(.orange)
    }
}
