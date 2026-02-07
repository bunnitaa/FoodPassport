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
    // connect to db
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
