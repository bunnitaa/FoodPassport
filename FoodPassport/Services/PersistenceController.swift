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
            
            // check if this restaurant is on the wishlist and delete it first
            let fetchRequest: NSFetchRequest<Stamp> = Stamp.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "restaurantId == %@ AND isWishlist == YES AND userId == %@", restaurantId, Auth.auth().currentUser?.uid ?? "")
            
            do {
                let existingWishlistItems = try context.fetch(fetchRequest)
                for item in existingWishlistItems {
                    context.delete(item) // wipe the wishlist ghost
                }
            } catch {
                print("Failed to clean up old wishlist item: \(error)")
            }
            
            // create the permanent stamp
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
            
            // explicitly ensure this is NOT a wishlist item
            newStamp.isWishlist = false
            
            do {
                try context.save()
                
                // NEW: Tell the widget to sync
                refreshWidgetData(context: context)
                
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
            
            // NEW: Tell the widget to sync
            refreshWidgetData(context: context)
            
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
        
    func saveToWishlist(restaurant: Restaurant, context: NSManagedObjectContext) {
        let newStamp = Stamp(context: context)
        newStamp.id = UUID()
        newStamp.restaurantId = restaurant.id
        newStamp.restaurantName = restaurant.name
        newStamp.address = restaurant.displayAddress
        newStamp.latitude = restaurant.latitude
        newStamp.longitude = restaurant.longitude
        newStamp.date = Date()
        newStamp.userId = Auth.auth().currentUser?.uid ?? "unknown"
        newStamp.isWishlist = true
        
        // default the other values
        newStamp.rating = 0.0
        newStamp.hasDetailedRating = false
        newStamp.foodRating = 0.0
        newStamp.serviceRating = 0.0
        newStamp.valueRating = 0.0
        
        do {
            try context.save()
            print("Successfully added \(restaurant.name) to Wishlist!")
        } catch {
            print("Failed to add to wishlist: \(error.localizedDescription)")
        }
    }

    // widget sync helper
    func refreshWidgetData(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Stamp> = Stamp.fetchRequest()
        // find ONLY real stamps (no wishlists) for current user
        request.predicate = NSPredicate(format: "userId == %@ AND isWishlist == NO", Auth.auth().currentUser?.uid ?? "unknown")
        // sort by newest first and only grab the top 1
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Stamp.date, ascending: false)]
        request.fetchLimit = 1

        if let sharedDefaults = UserDefaults(suiteName: "group.FoodPassport") {
            do {
                let recentStamps = try context.fetch(request)
                
                if let lastStamp = recentStamps.first {
                    // update widget with the new most recent meal
                    sharedDefaults.set(lastStamp.restaurantName, forKey: "lastMealName")
                    sharedDefaults.set(lastStamp.address, forKey: "lastMealAddress")
                    sharedDefaults.set(lastStamp.rating, forKey: "lastMealRating")
                    sharedDefaults.set(lastStamp.notes, forKey: "lastMealNotes")
                } else {
                    // passport is completely empty = clear the widget data
                    sharedDefaults.removeObject(forKey: "lastMealName")
                    sharedDefaults.removeObject(forKey: "lastMealAddress")
                    sharedDefaults.removeObject(forKey: "lastMealRating")
                    sharedDefaults.removeObject(forKey: "lastMealNotes")
                }
                
                // tell the iPhone home screen to refresh
                WidgetCenter.shared.reloadAllTimelines()
                print("Widget successfully synced with the database!")
                
            } catch {
                print("Failed to sync widget: \(error)")
            }
        }
    }
}
