import SwiftUI

struct ManagerView: View {
    @State private var isNPVCalculatorPresented = false
    @Binding var user: UserModel.User?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let user = user {
                        Text("\(user.name) Manager")
                            .font(.title)
                            .bold()
                    }
                    Text("직원들의 안전보고 효율적 관리해요!")
                        .font(.subheadline)

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
                                Text(worker.email)
                                Spacer()
                                Button(action: {
                                    // Handle attendance check
                                }) {
                                    Text("출근 체크")
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 5)
                        }
                    }

                    Section(header: Text("CPM Network").font(.headline)) {
                        HStack {
                            NavigationLink(destination: MContentView()) {
                                Text("확인하기")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            Spacer()
                            Button(action: {
                                // Edit action
                            }) {
                                Text("수정하기")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }

                    Section(header: Text("NPV Calculator").font(.headline)) {
                        NavigationLink(destination: NPVCalculatorView(), isActive: $isNPVCalculatorPresented) {
                            Text("NPV Calculator")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Worker Mode")
        }
    }
}
