//
//  PersistenceController.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FoodPassport")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func saveStamp(restaurantId: String, name: String, address: String?, latitude: Double, longitude: Double, rating: Double, notes: String?, photoData: Data?, context: NSManagedObjectContext) {
            let newStamp = Stamp(context: context)
            newStamp.id = UUID()
            newStamp.restaurantId = restaurantId
            newStamp.restaurantName = name
            newStamp.address = address
            
            // save the coordinates to the db
            newStamp.latitude = latitude
            newStamp.longitude = longitude
            
            newStamp.rating = rating
            newStamp.date = Date()
            newStamp.photoData = photoData
            newStamp.notes = notes
            
            do {
                try context.save()
                print("Successfully saved stamp for \(name)!")
            } catch {
                print("Failed to save stamp: \(error.localizedDescription)")
            }
        }
    
    func updateStamp(stamp: Stamp, newRating: Double, newNotes: String?, newPhotoData: Data?, context: NSManagedObjectContext) {
        stamp.rating = newRating
        stamp.notes = newNotes
        stamp.photoData = newPhotoData
        stamp.editDate = Date()
        
        do {
            try context.save()
            print("Successfully updated stamp for \(stamp.restaurantName ?? "Unknown")!")
        } catch {
            print("Failed to update stamp: \(error.localizedDescription)")
        }
    }
    
    func fetchStamps(context: NSManagedObjectContext) -> [Stamp] {
        let request: NSFetchRequest<Stamp> = Stamp.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Stamp.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching stamps: \(error)")
            return []
        }
    }
}
