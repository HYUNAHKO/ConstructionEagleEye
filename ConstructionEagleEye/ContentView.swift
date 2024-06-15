//
//  ContentView.swift
//  ConstructionEagleEye
//
//  Created by snlcom on 5/30/24.
//
import SwiftUI

struct ContentView: View {
    @State private var isUserLoggedIn = false
    @State private var isLoading = true
    @State private var currentUserRole: UserModel.UserRole? // Optional to handle non-logged in state
    @State private var currentUser: UserModel.User?
    @StateObject private var userModel = UserModel() // Initialize UserModel
    @StateObject private var imageViewModel = ImageViewModel() // Initialize ImageViewModel
    
    var body: some View {
        if isLoading {
            LoadingView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.isLoading = false
                    }
                }
        } else if let role = currentUserRole, isUserLoggedIn {
            MainView(userRole: role, isUserLoggedIn: $isUserLoggedIn, currentUser: $currentUser)
                .environmentObject(imageViewModel) // Provide ImageViewModel to the environment
        } else {
            LoginView(currentUserRole: $currentUserRole, isUserLoggedIn: $isUserLoggedIn, currentUser: $currentUser)
                .environmentObject(imageViewModel) // Provide ImageViewModel to the environment
        }
    }
}


