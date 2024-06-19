import Foundation
import CoreLocation

class AttendanceManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var attendanceStatus: [String: Bool] = [:]
    @Published var currentLocation: CLLocation?
    @Published var isUpdatingLocation = false
    @Published var locationAccessDenied = false

    private var locationManager: CLLocationManager?
    private var userModel: UserModel
    private let targetLocation = CLLocation(latitude: 37.56578, longitude: 126.9386)

    init(userModel: UserModel) {
        self.userModel = userModel
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.startUpdatingLocation()
    }

    var currentUserEmail: String? {
        return userModel.currentUser?.email
    }

    func startUpdatingLocation() {
        isUpdatingLocation = true
        locationManager?.startUpdatingLocation()
    }

    func requestSingleLocationUpdate() {
        isUpdatingLocation = true
        locationManager?.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            isUpdatingLocation = false
            return
        }
        currentLocation = location
        isUpdatingLocation = false

        if let currentUserEmail = currentUserEmail {
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
