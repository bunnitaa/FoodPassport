//
//  FoodPassportApp.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-01-28.
//

import SwiftUI
import CoreData

@main
struct FoodPassportApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
