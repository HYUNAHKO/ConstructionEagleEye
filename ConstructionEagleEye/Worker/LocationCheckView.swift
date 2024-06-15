//
//  LocationCheckView.swift
//  ConstructionEagleEye
//
//  Created by snlcom on 6/14/24.
//
import SwiftUI
import CoreLocation

struct LocationCheckView: View {
    @StateObject private var userModel = UserModel()  // Direct initialization
    @StateObject private var locationManager = AttendanceManager(userModel: UserModel())  // Direct initialization with new UserModel instance

    var body: some View {
        VStack {
            Text("Location Check")
                .font(.largeTitle)
                .padding()

            if locationManager.locationAccessDenied {
                Text("Location access denied. Please enable it in settings.")
                    .foregroundColor(.red)
                    .padding()
            } else if let location = locationManager.currentLocation {
                Text("Current Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    .padding()
            } else {
                Text("Fetching location...")
                    .padding()
            }
        }
        .navigationTitle("Location Check")
        .onAppear {
            locationManager.startUpdatingLocation()
        }
    }
}

struct LocationCheckView_Previews: PreviewProvider {
    static var previews: some View {
        LocationCheckView()
    }
}





