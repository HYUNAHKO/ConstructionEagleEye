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
    @State private var currentUserRole: UserModel.UserRole?
    @State private var currentUser: UserModel.User?
    @StateObject private var userModel = UserModel()
    @StateObject private var imageViewModel = ImageViewModel()

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
                .environmentObject(userModel)  // Ensure the UserModel is provided
                .environmentObject(imageViewModel)
        } else {
            LoginView(currentUserRole: $currentUserRole, isUserLoggedIn: $isUserLoggedIn, currentUser: $currentUser)
                .environmentObject(userModel)  // Ensure the UserModel is provided
                .environmentObject(imageViewModel)
        }
    }
}
