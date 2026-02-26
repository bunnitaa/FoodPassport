//
//  MapView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            Map {
                // Displays the user's current location (the blue dot)
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .navigationTitle("My Map")
            .onAppear {
                locationManager.requestLocationPermission()
            }
        }
    }
}
