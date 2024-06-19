import SwiftUI

struct MainView: View {
    let userRole: UserModel.UserRole
    @Binding var isUserLoggedIn: Bool
    @Binding var currentUser: UserModel.User?
    @EnvironmentObject var userModel: UserModel
    @StateObject var locationManager = LocationManager()

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
                        .environmentObject(userModel)
                        .environmentObject(locationManager)
                } else if userRole == .worker {
                    WorkerView()
                        .environmentObject(userModel)
                        .environmentObject(locationManager)
                }

                Button("Logout") {
                    isUserLoggedIn = false
                    userModel.currentUser = nil
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10)
            }
        }
        .onAppear {
            if let email = currentUser?.email {
                userModel.fetchCurrentUser(email: email)
            }
        }
    }
}
