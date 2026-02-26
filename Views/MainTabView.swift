//
//  MainTabView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            // Load the real PassportView
            PassportView()
                .tabItem {
                    Label("Passport", systemImage: "book.closed.fill")
                }
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
        }
    }
}
