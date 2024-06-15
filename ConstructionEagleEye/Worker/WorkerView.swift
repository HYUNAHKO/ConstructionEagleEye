import SwiftUI
import CoreLocation
import Combine

struct WorkerView: View {
    @EnvironmentObject var userModel: UserModel
    @StateObject var attendanceManager = AttendanceManager(userModel: UserModel.shared) // Adjusted to use shared instance correctly

    @State private var showLocationCheck = false
    @State private var attendanceStatusMessage = ""
    @State private var isSafetyChecklistPresented = false
    @State private var isLocationCheckPresented = false
    @State private var isNoticeBoardPresented = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = userModel.currentUser {
                        Text("\(user.name) (Worker)")
                            .font(.title)
                            .padding()
                    }

                    Section(header: Text("TODAY WORK").font(.headline)) {
                        HStack {
                            Text("연세대학교")
                            Spacer()
                            Button(action: {
                                attendanceManager.startUpdatingLocation()
                            }) {
                                VStack {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundColor(.blue)
                                    Text("출근 체크")
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Section(header: Text("안전 장비확인").font(.headline)) {
                        VStack {
                            Text("안전 장비 착용은 필수입니다. 완료 후 출근 인증이 가능합니다.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Button(action: {
                                isSafetyChecklistPresented = true
                            }) {
                                Image(systemName: "checkmark.seal")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.blue)
                            }
                            .sheet(isPresented: $isSafetyChecklistPresented) {
                                SafetyChecklistView(attendanceManager: attendanceManager)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Section(header: Text("공지사항 게시판").font(.headline)) {
                        VStack {
                            Text("공지사항을 확인해주세요.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Button(action: {
                                isNoticeBoardPresented = true
                            }) {
                                Image(systemName: "list.bullet")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.blue)
                            }
                            .sheet(isPresented: $isNoticeBoardPresented) {
                                NoticeBoardView()
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .navigationTitle("Worker Mode")
                .alert(isPresented: $showLocationCheck) {
                    Alert(title: Text("출근 상태"), message: Text(attendanceStatusMessage), dismissButton: .default(Text("확인")))
                }
                .onReceive(attendanceManager.$currentLocation) { location in
                    verifyAttendance(with: location)
                }
            }
        }
    }

    private func verifyAttendance(with location: CLLocation?) {
        guard let location = location,
              let user = userModel.currentUser,
              let userEmail = user.email else {
            attendanceStatusMessage = "사용자 정보를 확인할 수 없습니다."
            showLocationCheck = true
            return
        }

        let targetLocation = CLLocation(latitude: 37.56578, longitude: 126.9386) // 연세대학교 위치
        let distance = location.distance(from: targetLocation)

        if distance <= 500 {
            attendanceStatusMessage = "출근 완료"
            attendanceManager.attendanceStatus[userEmail] = true
        } else {
            attendanceStatusMessage = "출근 실패: 작업장 내 위치가 아닙니다"
            attendanceManager.attendanceStatus[userEmail] = false
        }
        showLocationCheck = true
    }
}

struct WorkerView_Previews: PreviewProvider {
    static var previews: some View {
        WorkerView()
            .environmentObject(UserModel())
            .environmentObject(AttendanceManager(userModel: UserModel()))
    }
}
