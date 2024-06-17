import SwiftUI
import CoreLocation
import Combine

struct WorkerView: View {
    @EnvironmentObject var userModel: UserModel
    @StateObject var attendanceManager = AttendanceManager(userModel: UserModel.shared)

    @State private var showLocationCheck = false
    @State private var attendanceStatusMessage = ""
    @State private var isSafetyChecklistPresented = false
    @State private var isLocationCheckPresented = false
    @State private var isNoticeBoardPresented = false
    @State private var openWeatherResponse: OpenWeatherResponse?
    @State private var isLoadingWeather = true
    var weatherDataDownload = WeatherDataDownload()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = userModel.currentUser {
                        Text("\(user.name) (Worker)")
                            .font(.title)
                            .padding()
                    }

                    if let weatherResponse = openWeatherResponse {
                        WeatherView(openWeatherResponse: weatherResponse)
                    } else if isLoadingWeather {
                        ProgressView()
                            .onAppear {
                                fetchWeather()
                            }
                    } else {
                        Text("날씨 정보를 불러올 수 없습니다.")
                    }

                    workSection
                    safetyEquipmentCheckSection
                    noticeBoardSection

                    // 긴급 전화 버튼
                    Button(action: makeEmergencyCall) {
                        Label("긴급 전화", systemImage: "phone.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding()

                    Spacer()
                }
                .navigationTitle("Worker Mode")
                .alert(isPresented: $showLocationCheck) {
                    Alert(title: Text("출근 상태"), message: Text(attendanceStatusMessage), dismissButton: .default(Text("확인")))
                }
            }
        }
    }

    private var workSection: some View {
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
            .onReceive(attendanceManager.$currentLocation) { location in
                verifyAttendance(with: location)
            }
        }
        .padding(.horizontal)
    }

    private var safetyEquipmentCheckSection: some View {
        Section(header: Text("안전 장비확인").font(.headline)) {
            VStack {
                Text("건설 현장에서 안전 장비 착용은 필수입니다.")
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
    }

    private var noticeBoardSection: some View {
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
    }

    private func verifyAttendance(with location: CLLocation?) {
        guard let location = location,
              let user = userModel.currentUser,
              let userEmail = user.email else {
            attendanceStatusMessage = "출근 체크를 반드시 해주세요."
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
        print("Attendance checked: \(attendanceStatusMessage)")
    }

    private func fetchWeather() {
        guard let location = attendanceManager.currentLocation else {
            isLoadingWeather = false
            print("Location not available")
            return
        }
        Task {
            do {
                print("Fetching weather for location: \(location)")
                openWeatherResponse = try await weatherDataDownload.getWeather(location: location.coordinate)
                isLoadingWeather = false
            } catch {
                print("Failed to fetch weather data: \(error)")
                isLoadingWeather = false
            }
        }
    }

    private func makeEmergencyCall() { //실제로 simulator에서 전화가 걸릴 수가 없음. 실제 ios 디바이스와 연결해서만 구현되는 기능
        guard let url = URL(string: "tel://119") else {
            print("Invalid URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    print("Failed to open URL")
                }
            }
        } else {
            print("Cannot open URL, possibly due to restrictions")
        }
    }

}

struct WorkerView_Previews: PreviewProvider {
    static var previews: some View {
        WorkerView()
            .environmentObject(UserModel())
            .environmentObject(AttendanceManager(userModel: UserModel.shared))
    }
}
