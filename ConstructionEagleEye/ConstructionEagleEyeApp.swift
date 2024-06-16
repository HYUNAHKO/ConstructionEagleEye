//
//  ConstructionEagleEyeApp.swift
//  ConstructionEagleEye
//
//  Created by snlcom on 5/30/24.
//

import SwiftUI
import SwiftData

@main
struct ConstructionEagleEyeApp: App {
    let container: ModelContainer
    @StateObject var attendanceManager = AttendanceManager(userModel: UserModel.shared)

    init() {
        do {
            container = try ModelContainer(for: Activity.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .environmentObject(attendanceManager)
                
        }
    }
}

