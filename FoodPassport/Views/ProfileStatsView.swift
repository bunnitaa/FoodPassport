//
//  ProfileStatsView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-03-30.
//

import SwiftUI
import CoreData
import FirebaseAuth

struct ProfileStatsView: View {
    // fetch stamps filtered by the current user ID
    @FetchRequest(
        entity: Stamp.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "userId == %@", Auth.auth().currentUser?.uid ?? "")
    ) private var savedStamps: FetchedResults<Stamp>
    
    @State private var displayName: String = "Explorer"
    @State private var email: String = ""

    private var totalStamps: Int { savedStamps.count }
    
    private var averageRating: Double {
        guard totalStamps > 0 else { return 0.0 }
        let total = savedStamps.reduce(0) { $0 + $1.rating }
        return total / Double(totalStamps)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // profile header
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.orange)
                        .padding(.top, 40)
                    
                    Text(displayName)
                        .font(.largeTitle)
                        .bold()
                    
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // stat blocks
                HStack(spacing: 20) {
                    StatBox(title: "Total Stamps", value: "\(totalStamps)", icon: "book.closed.fill")
                    StatBox(title: "Avg Rating", value: String(format: "%.1f", averageRating), icon: "star.fill")
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Profile")
            .onAppear {
                // load actual user data from firebase on appear
                if let user = Auth.auth().currentUser {
                    self.displayName = user.displayName ?? "New User"
                    self.email = user.email ?? ""
                }
            }
        }
    }
}

// MARK: - UI Component for the Stat Boxes
// This is the part that was missing!
struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
