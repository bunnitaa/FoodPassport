//
//  TutorialView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-03-30.
//

import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    
    // automatically saves a true/false value to the device's UserDefaults
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    
    @State private var currentPage = 0
    
    // tutorial page content
    let pages = [
        TutorialPage(
            title: "Welcome to FoodPassport",
            description: "Your personal logbook for every amazing meal, hidden gem, and late-night snack.",
            iconName: "map.fill",
            color: .orange
        ),
        TutorialPage(
            title: "Discover & Stamp",
            description: "Search for restaurants and stamp them into your passport with detailed ratings and photos.",
            iconName: "checkmark.seal.fill",
            color: .green
        ),
        TutorialPage(
            title: "Track Your Journey",
            description: "Build a beautiful map of your culinary adventures and watch your stats grow.",
            iconName: "globe.americas.fill",
            color: .blue
        )
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    TutorialPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            Spacer()
            
            Button(action: {
                if currentPage < pages.count - 1 {
                    // go to the next page
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    // finish tutorial
                    hasSeenTutorial = true
                    dismiss()
                }
            }) {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .cornerRadius(15)
                    .padding(.horizontal, 30)
                    .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.bottom, 40)
        }
    }
}

struct TutorialPage {
    let title: String
    let description: String
    let iconName: String
    let color: Color
}

struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: page.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .foregroundColor(page.color)
                .padding(.bottom, 20)
            
            Text(page.title)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .lineSpacing(4)
            
            Spacer()
        }
    }
}
