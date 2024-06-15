//
//  AttendanceManager.swift
//  ConstructionEagleEye
//
//  Created by snlcom on 6/14/24.
//
import Foundation
import CoreLocation

class AttendanceManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var attendanceStatus: [String: Bool] = [:]
    @Published var currentLocation: CLLocation?
    @Published var isUpdatingLocation = false
    @Published var locationAccessDenied = false

    private var locationManager: CLLocationManager?
    private var userModel: UserModel // UserModel을 속성으로 사용

    // Updated coordinates for 연세대학교
    private let targetLocation = CLLocation(latitude: 37.56578, longitude: 126.9386)

    init(userModel: UserModel) {
        self.userModel = userModel
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
    }

    func startUpdatingLocation() {
        print("Starting location updates")
        locationManager?.startUpdatingLocation()
        isUpdatingLocation = true
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("No locations found")
            return
        }
        currentLocation = location
        isUpdatingLocation = false
        print("Location updated: \(location.coordinate)")

        if let currentUserEmail = userModel.currentUser?.email {
            markAttendance(for: currentUserEmail)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isUpdatingLocation = false
        print("Failed to find user's location: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            locationAccessDenied = true
            print("Location access denied")
        } else {
            print("Location access granted")
        }
    }

    func markAttendance(for email: String) {
        guard let location = currentLocation else {
            print("Current location is not available")
            return
        }
        let distance = location.distance(from: targetLocation)
        let isWithinRange = distance <= 500
        attendanceStatus[email] = isWithinRange
        print("Attendance marked for \(email): \(isWithinRange ? "Present" : "Absent")")
    }
}
