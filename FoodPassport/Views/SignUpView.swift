//
//  SignUpView.swift
//  FoodPassport
//
//  Created by Bunnita on 2026-03-30.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            TextField("Full Name", text: $fullName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                attemptSignUp()
            }) {
                Text("Sign Up")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        // error popup
        .alert("Registration Failed", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // validation logic with Firebase
    private func attemptSignUp() {
        if fullName.isEmpty || email.isEmpty {
            errorMessage = "Please fill out all fields."
            showingError = true
            return
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            showingError = true
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            showingError = true
            return
        }
        
        // real firebase network call
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showingError = true
            } else if let user = authResult?.user {
                // save the full name to user's firebase profile
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = fullName
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error saving name: \(error.localizedDescription)")
                    }
                    isLoggedIn = true        }
            }
        }
    }
}
