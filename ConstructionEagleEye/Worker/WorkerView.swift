import SwiftUI
import CoreLocation
import Combine
import CoreLocationUI

struct WorkerView: View {
    @EnvironmentObject var userModel: UserModel
    @StateObject var attendanceManager = AttendanceManager(userModel: UserModel.shared)
    @EnvironmentObject var locationManager: LocationManager
    @State private var showLocationCheck = false
    @State private var attendanceStatusMessage = ""
    @State private var isSafetyChecklistPresented = false
    @State private var isNoticeBoardPresented = false
    @State private var openWeatherResponse: OpenWeatherResponse?
    @State private var isLoadingWeather = true
    var weatherDataDownload = WeatherDataDownload()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = userModel.currentUser {
                        Text("\(user.name) (Worker)").font(.title).padding()
                    }

                    if let location = locationManager.location {
                        if let  openWeatherResponse = openWeatherResponse {
                                       WeatherView(openWeatherResponse: openWeatherResponse)
                        } else {
                                ProgressView()
                                    .task {
                                    openWeatherResponse = try? await weatherDataDownload.getWeather(location: location)
                                    }
                                   }
                    } else if !locationManager.locationPermissionGranted {
                        VStack {
                            Text("Location permission not granted.")
                                .foregroundColor(.red)
                                .padding()
                            LocationButton(.shareCurrentLocation) {
                                locationManager.requestLocation()
                            }
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .padding()
                        }
                    } else {
                        Text("Unable to load weather data.")
                        Button("Retry") {
                            fetchWeather()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }

                    workSection
                    safetyEquipmentCheckSection
                    noticeBoardSection

                    Button(action: makeEmergencyCall) {
                        Label("Emergency Call", systemImage: "phone.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding()

                    Spacer()
                }
                .onChange(of: locationManager.location) { _ in
                    fetchWeather()
                }
                .navigationTitle("Worker Mode")
                .alert(isPresented: $showLocationCheck) {
                    Alert(title: Text("Attendance Status"), message: Text(attendanceStatusMessage), dismissButton: .default(Text("OK")))
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
        Section(header: Text("안전 장비 확인").font(.headline).padding()) {
            VStack(spacing: 20) {
                Text("현장에서 안전 장비 착용은 필수입니다.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .center)

                Button(action: {
                    isSafetyChecklistPresented = true
                }) {
                    Label {
                        Text("안전 장비 확인")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.vertical, 8) // 상하 패딩 추가
                            .frame(width: 200) // 버튼 너비 조정
                    } icon: {
                        Image(systemName: "checkmark.shield")
                            .imageScale(.large) // 아이콘 크기 조정
                            .foregroundColor(.white)
                    }
                    .padding() // Label 주변에 패딩 추가
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .sheet(isPresented: $isSafetyChecklistPresented) {
                    SafetyChecklistView(attendanceManager: attendanceManager)
                        .environmentObject(userModel)
                }
            }
            .padding()
            .frame(width: 300) // 섹션 전체 너비 조정
            .background(Color(.systemGray5))
            .cornerRadius(12)
            .shadow(color: .gray, radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }




    private var noticeBoardSection: some View {
        Section(header: Text("공지사항 게시판").font(.headline).padding()) {
            VStack(spacing: 20) {
                Text("작업 시작 전 공지사항 꼭 확인해주세요.")
                    .font(.subheadline) // 조금 더 크고 눈에 띄는 폰트 스타일로 변경
                    .foregroundColor(.secondary) // 보다 읽기 쉬운 색상으로 변경
                    .padding(.vertical, 10)

                Button(action: {
                    isNoticeBoardPresented = true
                }) {
                    HStack {
                        Image(systemName: "list.bullet.rectangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                        Text("공지사항 보기")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .sheet(isPresented: $isNoticeBoardPresented) {
                    NoticeBoardView()
                }
            }
            .padding()
            .background(Color(.systemGray5)) // 밝은 회색 배경
            .cornerRadius(12)
            .shadow(color: .gray, radius: 5, x: 0, y: 2)
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
        }

    func fetchWeather() {
            guard let location = locationManager.location else {
                print("Location not available")
                return
            }
            isLoadingWeather = true
            Task {
                do {
                    let response = try await weatherDataDownload.getWeather(location: location)
                    openWeatherResponse = response
                    isLoadingWeather = false
                } catch {
                    print("Failed to fetch weather: \(error)")
                    isLoadingWeather = false
                }
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



struct WorkerView_Previews: PreviewProvider {
    static var previews: some View {
        WorkerView()
            .environmentObject(UserModel())
            .environmentObject(AttendanceManager(userModel: UserModel.shared))
    }
}
