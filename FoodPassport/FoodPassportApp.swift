//
//  FoodPassportApp.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import SwiftUI
import CoreData

@main
struct FoodPassportApp: App {
    // Initialize the CoreData controller
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                // Inject the database context into the SwiftUI environment
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
