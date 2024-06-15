import SwiftUI

struct ManagerView: View {
    @State private var isNPCVCalculatorPresented = false
    @Binding var user: UserModel.User?
    @StateObject private var attendanceManager: AttendanceManager
    @State private var showAttendanceAlert = false
    @State private var attendanceAlertMessage = ""
    
    init(user: Binding<UserModel.User?>) {
            _user = user
            let userModel = UserModel()  // Assuming UserModel isn't a singleton
            _attendanceManager = StateObject(wrappedValue: AttendanceManager(userModel: userModel))
        }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let user = user {
                        Text("\(user.name) Manager")
                            .font(.title)
                            .bold()
                            .padding([.top, .horizontal])
                    }
                    Text("직원들의 안전보고 효율적 관리해요!")
                        .font(.subheadline)
                        .padding(.bottom, 10)

                    Section(header: Text("TODAY WORK").font(.headline)) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Concreting")
                                .padding(.bottom, 5)
                            NavigationLink(destination: MContentView()) {
                                Text("CPM Calculation")
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }

                    Section(header: Text("Worker State").font(.headline)) {
                        ForEach(UserModel().users.filter { $0.role == .worker }, id: \.email) { worker in
                            HStack {
                                Text(worker.name)
                                Spacer()
                                Button(action: {
                                    // Safely unwrap email and check attendance status
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
                            .padding(.vertical, 5)
                        }
                        .alert(isPresented: $showAttendanceAlert) {
                            Alert(title: Text("출근 상태"), message: Text(attendanceAlertMessage), dismissButton: .default(Text("확인")))
                        }
                    }


                    Section(header: Text("CPM Network").font(.headline)) {
                        HStack {
                            NavigationLink(destination: MContentView()) {
                                Text("Calculation")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            Spacer()
                        }
                    }

                    Section(header: Text("NPV Calculator").font(.headline)) {
                        NavigationLink(destination: NPVCalculatorView()) {
                            Text("NPV Calculator")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .navigationBarTitle("Manager Mode", displayMode: .inline)
            }
        }
    }
}
