//
//  SafetyChecklistView.swift
//  ConstructionEagleEye
//
//  Created by snlcom on 6/14/24.
//
import SwiftUI
import CoreML
import UIKit

struct SafetyChecklistView: View {
    @ObservedObject var attendanceManager: AttendanceManager
    @ObservedObject var imageViewModel: ImageViewModel = ImageViewModel()
    @State private var checklist: [String: Bool] = ["Helmet": false, "Safety Shoes": false]
    @State private var isImagePickerShowing = false
    @State private var image: UIImage?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Safety Checklist")
                .font(.largeTitle)
                .padding()

            Button("Upload Image") {
                isImagePickerShowing = true
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .padding()
            }

            List {
                ForEach(checklist.keys.sorted(), id: \.self) { item in
                    HStack {
                        Text(item)
                        Spacer()
                        Image(systemName: checklist[item]! ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(checklist[item]! ? .green : .gray)
                    }
                }
            }

            Button("Submit Checklist") {
                submitChecklist()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .sheet(isPresented: $isImagePickerShowing, onDismiss: loadImage) {
            ImagePicker(image: $image)
        }
        .navigationTitle("Safety Checklist")
    }

    private func loadImage() {
        guard let image = image else { return }
        imageViewModel.classifyImage(image: image) { results in
            updateChecklist(with: results)
        }
    }

    private func updateChecklist(with results: [String]) {
        if results.contains(where: { $0.lowercased().contains("hat") }) {
            checklist["Helmet"] = true
        }
        if results.contains(where: { $0.lowercased().contains("shoe") }) {
            checklist["Safety Shoes"] = true
        }
    }

    private func submitChecklist() {
        if checklist.values.allSatisfy({ $0 }) {
            attendanceManager.markAttendance(for: "dazzly@gmail.com") // Dynamic user handling is recommended
            // Provide feedback to the user
        }
    }
}
