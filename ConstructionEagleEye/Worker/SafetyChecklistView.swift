import SwiftUI
import CoreML
import UIKit
import Photos

struct SafetyChecklistView: View {
    @ObservedObject var attendanceManager: AttendanceManager
    @ObservedObject var imageViewModel: ImageViewModel = ImageViewModel()
    @State private var checklist: [String: Bool] = ["Helmet": false, "Safety Shoes": false]
    @State private var isImagePickerShowing = false
    @State private var showingPermissionAlert = false  // 권한 거부 경고창을 위한 상태
    @State private var image: UIImage?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Safety Checklist")
                .font(.largeTitle)
                .padding()

            Button("Upload Image") {
                checkPhotoLibraryAuthorization()
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
        .alert(isPresented: $showingPermissionAlert) {
            Alert(
                title: Text("권한 거부됨"),
                message: Text("갤러리 접근 권한을 허용해 주세요. 설정 > 개인정보 보호에서 변경할 수 있습니다."),
                dismissButton: .default(Text("확인"))
            )
        }
        .navigationTitle("Safety Checklist")
    }

    private func checkPhotoLibraryAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            isImagePickerShowing = true
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    DispatchQueue.main.async {
                        self.isImagePickerShowing = true
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.showingPermissionAlert = true
            }
        }
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
