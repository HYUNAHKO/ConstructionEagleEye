import SwiftUI
import CoreML
import UIKit
import Photos

struct SafetyChecklistView: View {
    @ObservedObject var attendanceManager: AttendanceManager
    @EnvironmentObject var userModel: UserModel
    @ObservedObject var imageViewModel: ImageViewModel = ImageViewModel()
    @State private var checklist: [String: Bool] = ["Helmet": false, "Safety Shoes": false]
    @State private var isImagePickerShowing = false
    @State private var image: UIImage?
    @State private var feedbackMessage = ""
    @State private var isFeedbackPresented = false

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
            .alert(isPresented: $isFeedbackPresented) {
                Alert(
                    title: Text("안전 장비 체크 완료"),
                    message: Text(feedbackMessage),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
        .sheet(isPresented: $isImagePickerShowing, onDismiss: loadImage) {
            ImagePicker(image: $image)
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
            if let user = userModel.currentUser {
                feedbackMessage = "\(user.name)님의 안전 장비가 확인되었습니다. 안전한 건설 작업하세요!"
            } else {
                feedbackMessage = "사용자 정보를 불러올 수 없습니다."
            }
            isFeedbackPresented = true
        } else {
            feedbackMessage = "안전 장비 체크리스트를 완료해주세요."
            isFeedbackPresented = true
        }
    }
}
