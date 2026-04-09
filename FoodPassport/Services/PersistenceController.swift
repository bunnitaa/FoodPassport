//
//  PersistenceController.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-02-26.
//

import CoreData
import FirebaseAuth
import WidgetKit

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

    func saveStamp(restaurantId: String, name: String, address: String?, latitude: Double, longitude: Double, rating: Double, hasDetailedRating: Bool, foodRating: Double, serviceRating: Double, valueRating: Double, notes: String?, photoData: Data?, context: NSManagedObjectContext) {
                let newStamp = Stamp(context: context)
                newStamp.id = UUID()
                newStamp.restaurantId = restaurantId
                newStamp.restaurantName = name
                newStamp.address = address
                newStamp.latitude = latitude
                newStamp.longitude = longitude
                newStamp.date = Date()
                newStamp.notes = notes
                newStamp.photoData = photoData
                newStamp.userId = Auth.auth().currentUser?.uid ?? "unknown"
                newStamp.rating = rating
                newStamp.hasDetailedRating = hasDetailedRating
                newStamp.foodRating = foodRating
                newStamp.serviceRating = serviceRating
                newStamp.valueRating = valueRating
                
                do {
                    try context.save()
                    
                    if let sharedDefaults = UserDefaults(suiteName: "group.FoodPassport") {
                        sharedDefaults.set(name, forKey: "lastMealName")
                        sharedDefaults.set(address, forKey: "lastMealAddress")
                        sharedDefaults.set(rating, forKey: "lastMealRating")
                        sharedDefaults.set(notes, forKey: "lastMealNotes")
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    
                    print("Successfully saved stamp for \(name)!")
                } catch {
                    print("Failed to save stamp: \(error.localizedDescription)")
                }
            }
    
    func updateStamp(stamp: Stamp, newRating: Double, hasDetailedRating: Bool, newFoodRating: Double, newServiceRating: Double, newValueRating: Double, newNotes: String?, newPhotoData: Data?, context: NSManagedObjectContext) {
            
            stamp.notes = newNotes
            stamp.photoData = newPhotoData
            stamp.editDate = Date()            
            stamp.rating = newRating
            stamp.hasDetailedRating = hasDetailedRating
            stamp.foodRating = newFoodRating
            stamp.serviceRating = newServiceRating
            stamp.valueRating = newValueRating
            
            do {
                try context.save()
                
                if let sharedDefaults = UserDefaults(suiteName: "group.FoodPassport") {
                    sharedDefaults.set(stamp.restaurantName, forKey: "lastMealName")
                    sharedDefaults.set(stamp.address, forKey: "lastMealAddress")
                    sharedDefaults.set(newRating, forKey: "lastMealRating")
                    sharedDefaults.set(newNotes, forKey: "lastMealNotes")
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
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
