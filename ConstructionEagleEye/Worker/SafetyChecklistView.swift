import SwiftUI
import CoreML
import UIKit
import Photos

struct SafetyChecklistView: View {
    @ObservedObject var attendanceManager: AttendanceManager
    @ObservedObject var imageViewModel: ImageViewModel = ImageViewModel()
    @State private var checklist: [String: Bool] = ["Helmet": false, "Safety Shoes": false]
    @State private var isImagePickerShowing = false
    @State private var showingPermissionAlert = false
    @State private var image: UIImage?
    @State private var feedbackMessage = ""
    @State private var isFeedbackPresented = false
    @State private var alertTitle = ""  // Local alert title state

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
                    title: Text(alertTitle),
                    message: Text(feedbackMessage),
                    dismissButton: .default(Text("확인"))
                )
            }
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
                } else {
                    showingPermissionAlert = true
                }
            }
        } else {
            showingPermissionAlert = true
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
            print("Submit checklist called")
            if checklist.values.allSatisfy({ $0 }) {
                print("All items checked")
                if let user = UserModel.shared.currentUser {
                    feedbackMessage = "\(user.name)님의 안전 장비가 확인되었습니다. 안전한 건설 작업하세요!"
                    alertTitle = "안전 장비 체크 완료"
                    print("User name: \(user.name)")
                } else {
                    feedbackMessage = "사용자 정보를 불러올 수 없습니다."
                    alertTitle = "오류"
                    print("User info not available")
                }
                isFeedbackPresented = true
                print("Alert should be presented now")
            } else {
                feedbackMessage = "안전 장비 체크리스트를 완료해주세요."
                alertTitle = "체크리스트 미완료"
                isFeedbackPresented = true
                print("Checklist not complete")
            }
        }
}
