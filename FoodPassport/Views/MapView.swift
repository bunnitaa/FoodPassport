//
//  MapView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI
import MapKit
import CoreData

struct MapView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    @FetchRequest(
        entity: Stamp.entity(),
        sortDescriptors: []
    ) private var savedStamps: FetchedResults<Stamp>
    
    @State private var selectedRestaurant: Restaurant?
    @State private var restaurantToSave: Restaurant?
    
    // controls the city search bar
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    private var allDisplayableRestaurants: [Restaurant] {
        var uniqueRestaurants: [String: Restaurant] = [:]
        
        for stamp in savedStamps {
            if let id = stamp.restaurantId, let name = stamp.restaurantName {
                uniqueRestaurants[id] = Restaurant(
                    id: id,
                    name: name,
                    displayAddress: stamp.address ?? "Unknown Address",
                    latitude: stamp.latitude,
                    longitude: stamp.longitude,
                    rating: stamp.rating,
                    imageUrl: nil
                )
            }
        }
        
        for restaurant in viewModel.restaurants {
            uniqueRestaurants[restaurant.id] = restaurant
        }
        
        return Array(uniqueRestaurants.values)
    }
    
    var body: some View {
        Map(position: $position) {
            ForEach(allDisplayableRestaurants) { restaurant in
                Annotation(restaurant.name, coordinate: CLLocationCoordinate2D(
                    latitude: restaurant.latitude,
                    longitude: restaurant.longitude
                )) {
                    VStack(spacing: 0) {
                        if selectedRestaurant?.id == restaurant.id {
                            MapCalloutCard(
                                restaurant: restaurant,
                                isStamped: isRestaurantStamped(restaurant.id),
                                onStamp: { restaurantToSave = restaurant }
                            )
                            
                            Image(systemName: "arrowtriangle.down.fill")
                                .foregroundColor(.white)
                                .offset(y: -2)
                        }
                        
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .background(isRestaurantStamped(restaurant.id) ? Color.green : Color.orange)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .onTapGesture {
                                withAnimation(.spring) {
                                    if selectedRestaurant?.id == restaurant.id {
                                        selectedRestaurant = nil
                                    } else {
                                        selectedRestaurant = restaurant
                                    }
                                }
                            }
                    }
                    .zIndex(selectedRestaurant?.id == restaurant.id ? 1 : 0)
                }
            }
            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
        }
        // city search bar
        .safeAreaInset(edge: .top) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search a city (e.g. Laval)...", text: $viewModel.searchLocation)
                    .submitLabel(.search)
                    .onSubmit {
                        // move the camera
                        searchForLocation(query: viewModel.searchLocation)
                        
                        // fetch the google places data for new city
                        let term = viewModel.searchText.isEmpty ? "restaurants" : viewModel.searchText
                        viewModel.performSearch(term: term, location: viewModel.searchLocation)
                    }
                
                if !viewModel.searchLocation.isEmpty {
                    Button(action: { viewModel.searchLocation = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(UIColor.systemBackground).opacity(0.95))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .onAppear { updateBounds() }
        .onChange(of: viewModel.restaurants.count) { updateBounds() }
        .sheet(item: $restaurantToSave) { restaurant in
            AddStampView(restaurant: restaurant)
        }
    }
    
    private func searchForLocation(query: String) {
        guard !query.isEmpty else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let coordinate = response?.mapItems.first?.location.coordinate else { return }
            
            withAnimation(.easeInOut(duration: 1.0)) {
                position = .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                ))
            }
        }
    }
    
    private func isRestaurantStamped(_ id: String) -> Bool {
        savedStamps.contains { $0.restaurantId == id }
    }
    
    private func updateBounds() {
        guard !viewModel.restaurants.isEmpty else { return }
        let coordinates = viewModel.restaurants.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
        if let first = coordinates.first {
            position = .region(MKCoordinateRegion(
                center: first,
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            ))
        }
    }
}

struct MapCalloutCard: View {
    let restaurant: Restaurant
    let isStamped: Bool
    let onStamp: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrl = restaurant.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                         .aspectRatio(contentMode: .fill)
                         .frame(height: 100)
                         .clipped()
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 100)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(restaurant.displayAddress)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                if isStamped {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Stamped in Passport")
                            .font(.caption).bold()
                    }
                    .foregroundColor(.green)
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 5)
            
            Button(action: onStamp) {
                Text(isStamped ? "Stamp Again" : "Stamp Passport")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .frame(width: 220)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.bottom, 5)
    }
}
