import SwiftUI

struct MainView: View {
    let userRole: UserModel.UserRole
    @Binding var isUserLoggedIn: Bool
    @Binding var currentUser: UserModel.User?

    var body: some View {
        ZStack {
            Image("EagleLogo")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("ConstructionEagleEye")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .padding()

                if userRole == .manager {
                    ManagerView()
                } else if userRole == .worker {
                    WorkerView()
                }

                Button("Logout") {
                    isUserLoggedIn = false
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10)
            }
        }
        .onAppear {
            // Fetch the current user
            currentUser = UserModel().users.first { $0.email == "현재 로그인한 사용자의 이메일" }
        }
    }
}
