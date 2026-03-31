//
//  MainTabView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//
import SwiftUI

struct MainTabView: View {
    @StateObject private var searchViewModel = SearchViewModel()
    
    // read dark mode setting from device memory
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        TabView {
            // search tab
            SearchView(viewModel: searchViewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            // map tab
            MapView(viewModel: searchViewModel)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            // passport tab
            PassportView()
                .tabItem {
                    Label("Passport", systemImage: "book.closed")
                }
            // profile Tab
            ProfileStatsView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                
            // settings tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(.orange)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
