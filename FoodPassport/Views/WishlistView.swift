//
//  WishlistView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-04-12.
//

import SwiftUI
import CoreData
import FirebaseAuth

struct WishlistView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // fetch only items flagged as wishlist for the current user
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Stamp.date, ascending: false)],
        predicate: NSPredicate(format: "userId == %@ AND isWishlist == YES", Auth.auth().currentUser?.uid ?? ""),
        animation: .default)
    private var wishlistItems: FetchedResults<Stamp>
    
    // state to trigger the AddStampView sheet
    @State private var restaurantToStamp: Restaurant?
    
    var body: some View {
        NavigationStack {
            List {
                if wishlistItems.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bookmark.slash")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Your wishlist is empty.")
                            .font(.headline)
                        Text("Find a place on the map and bookmark it for later!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(wishlistItems) { stamp in
                        HStack(spacing: 12) {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(stamp.restaurantName ?? "Unknown")
                                    .font(.headline)
                                Text(stamp.address ?? "No Address")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            // stamp button
                            Button(action: {
                                // convert the coredata stamp back into a temporary Restaurant object
                                let restaurant = Restaurant(
                                    id: stamp.restaurantId ?? UUID().uuidString,
                                    name: stamp.restaurantName ?? "Unknown",
                                    displayAddress: stamp.address ?? "",
                                    latitude: stamp.latitude,
                                    longitude: stamp.longitude,
                                    rating: nil,
                                    imageUrl: nil
                                )
                                restaurantToStamp = restaurant
                            }) {
                                Text("Stamp")
                                    .font(.caption)
                                    .bold()
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle()) // prevents the whole row from becoming clickable
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("To-Try List")
            // presents the AddStamp form when the button is clicked
            .sheet(item: $restaurantToStamp) { restaurant in
                AddStampView(restaurant: restaurant)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { wishlistItems[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}
