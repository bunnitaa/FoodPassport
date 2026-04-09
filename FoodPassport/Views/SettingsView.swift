//
//  SettingsView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-03-30.
//

import SwiftUI
import CoreData
import FirebaseAuth

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // automatically saves user's theme preference to the device
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isLoggedIn") private var isLoggedIn = true
    
    @State private var showingClearAlert = false
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Enable Dark Mode", isOn: $isDarkMode)
                        .tint(.orange)
                }
                
                Section(header: Text("Data Management")) {
                    Button(role: .destructive) {
                        showingClearAlert = true
                    } label: {
                        HStack {
                            Text("Clear All Passport Data")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }
                }
                
                // testing section to reset the tutorial
                Section(header: Text("Developer / Testing")) {
                    Button(action: {
                        hasSeenTutorial = false
                    }) {
                        Text("Reset App Tutorial")
                            .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("FoodPassport Team").foregroundColor(.secondary)
                    }
                }
                
                // log out button section
                Section {
                    Button(role: .destructive) {
                        // Securely sign out of Firebase and kick user to WelcomeView
                        do {
                            try Auth.auth().signOut()
                            isLoggedIn = false
                        } catch {
                            print("Error signing out of Firebase: \(error.localizedDescription)")
                        }
                    } label: {
                        Text("Log Out")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Settings")
            // alert before wiping the database
            .alert("Are you sure?", isPresented: $showingClearAlert) {
                Button("Delete All", role: .destructive) {
                    clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your saved stamps and photos. This action cannot be undone.")
            }
        }
    }
    
    // coredata logic to safely wipe the entity
    private func clearAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Stamp.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(batchDeleteRequest)
            try viewContext.save()
        } catch {
            print("Error clearing database: \(error.localizedDescription)")
        }
    }
}
