import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isShowingSignUp = false
    @Binding var isUserLoggedIn: Bool

    let userModel = UserModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("CEE : Construction Eagle Eye")
                    .font(<#T##font: Font?##Font?#>)
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Login") {
                    handleLogin()
                }
                .padding()

                NavigationLink("Sign Up", destination: SignUpView(isUserLoggedIn: $isUserLoggedIn), isActive: $isShowingSignUp)
                    .padding()

                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Login Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarTitle("Login")
        }
    }


    
    func handleLogin() {
        if !userModel.isValidEmail(id: email) {
            alertMessage = "이메일 형식을 확인해 주세요"
            showAlert = true
            return
        }
        
        if !userModel.isValidPassword(pwd: password) {
            alertMessage = "비밀번호 형식을 확인해 주세요"
            showAlert = true
            return
        }
        
        if userModel.loginCheck(id: email, pwd: password) {
            alertMessage = "로그인 성공"
            showAlert = true
            // Navigate to main view or other actions
            self.isUserLoggedIn = true //로그인 상태 업데이트
        } else {
            alertMessage = "아이디나 비밀번호가 다릅니다."
            showAlert = true
        }
    }
}
