import SwiftUI

struct ManagerView: View {
    @State private var isNPCVCalculatorPresented = false
    @ObservedObject var userModel = UserModel.shared // Use shared instance
    @StateObject private var attendanceManager = AttendanceManager(userModel: UserModel.shared)

    @State private var showAttendanceAlert = false
    @State private var attendanceAlertMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let user = userModel.currentUser { // Corrected from `user` to `userModel.currentUser`
                        Text("\(user.name) Manager")
                            .font(.title)
                            .bold()
                            .padding(.top)
                    }
                    Text("직원들의 안전보고 효율적 관리해요!")
                        .font(.subheadline)
                        .padding()

                    Section(header: Text("TODAY WORK").font(.headline)) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Concreting")
                                .padding()
                            NavigationLink(destination: MContentView()) {
                                Text("CPM Calculation")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Section(header: Text("Worker State").font(.headline)) {
                        ForEach(UserModel().users.filter { $0.role == .worker }, id: \.email) { worker in
                            HStack {
                                Text(worker.name)
                                Spacer()
                                Button(action: {
                                    if let email = worker.email, let status = attendanceManager.attendanceStatus[email] {
                                        attendanceAlertMessage = "\(worker.name)님이 출근하셨습니다."
                                    } else {
                                        attendanceAlertMessage = "\(worker.name)님이 아직 출근하지 않았습니다."
                                    }
                                    showAttendanceAlert = true
                                }) {
                                    Text("출근 체크")
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                            }
                            .padding()
                        }
                        .alert(isPresented: $showAttendanceAlert) {
                            Alert(title: Text("출근 상태"), message: Text(attendanceAlertMessage), dismissButton: .default(Text("확인")))
                        }
                    }
                    .padding(.horizontal)

                    Section(header: Text("  CPM Network").font(.headline)) {
                        NavigationLink(destination: MContentView()) {
                            Text("Calculation")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .padding()
                    }

                    Section(header: Text("  NPV Calculator").font(.headline)) {
                        NavigationLink(destination: NPVCalculatorView()) {
                            Text("NPV Calculator")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .padding()
                    }
                }
                .padding()
                .navigationBarTitle("Manager Mode", displayMode: .inline)
            }
        }
    }
}
