//
//  MapView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    @State private var selectedRestaurant: Restaurant?
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    var body: some View {
        Map(position: $position) {
            ForEach(viewModel.restaurants) { restaurant in
                
                Annotation(restaurant.name, coordinate: CLLocationCoordinate2D(
                    latitude: restaurant.latitude,
                    longitude: restaurant.longitude
                )) {
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                        .onTapGesture {
                            selectedRestaurant = restaurant
                        }
                }
            }
            
            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
        }
        .onAppear { updateBounds() }
        .onChange(of: viewModel.restaurants.count) { _ in updateBounds() }
        
        .sheet(item: $selectedRestaurant) { restaurant in
            VStack(spacing: 20) {
                Text(restaurant.name)
                    .font(.title2)
                    .bold()
                
                Text(restaurant.displayAddress)
                    .foregroundColor(.gray)
                
                Button(action: {
                    print("Ready to save to passport")
                }) {
                    Text("Stamp my Passport")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .presentationDetents([.fraction(0.3)])
        }
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
