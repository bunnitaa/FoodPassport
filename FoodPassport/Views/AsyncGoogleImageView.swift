//
//  AsyncGoogleImageView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-04-12.
//

import SwiftUI

struct AsyncGoogleImageView: View {
    let urlString: String
    @State private var image: UIImage? = nil
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else if isLoading {
                ProgressView()
            } else {
                // fallback if the image completely fails
                Color.gray.opacity(0.3)
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        // manually inject the Bundle ID so Google doesn't block the image
        request.setValue(Bundle.main.bundleIdentifier ?? "com.bunnita.FoodPassport", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                self.image = UIImage(data: data)
            } else {
                print("Google blocked the image request. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
        } catch {
            print("Failed to load image: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
