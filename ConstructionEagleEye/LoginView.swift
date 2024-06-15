import SwiftUI

extension Color {
    static let navy = Color(red: 0.0, green: 0.0, blue: 128.0)
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var currentUserRole: UserModel.UserRole?
    @Binding var isUserLoggedIn: Bool
    @Binding var currentUser: UserModel.User?

    let userModel = UserModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🦅 CEE 🦅 ")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.navy)
                    .padding()
                
                // 각 글자에 색상 적용
                HStack(spacing: 0) {
                    Text("C")
                        .foregroundColor(.navy) // C에 navy
                    Text("onstruction ")
                        .foregroundColor(.black)
                    Text("E")
                        .foregroundColor(.navy) // E에 navy
                    Text("agle ")
                        .foregroundColor(.black)
                    Text("E")
                        .foregroundColor(.navy) // E에 navy
                    Text("ye")
                        .foregroundColor(.black)
                }
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.navy)
                .padding()
                
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
                
                NavigationLink("Sign Up", destination: SignUpView(isUserLoggedIn: $isUserLoggedIn, userModel: userModel))
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
        
        if let user = userModel.loginCheck(id: email, pwd: password) {
            alertMessage = "로그인 성공"
            showAlert = true
            DispatchQueue.main.async {
                currentUserRole = user.role  // UserRole 직접 할당
                currentUser = user
                isUserLoggedIn = true
            }
        } else {
            alertMessage = "아이디나 비밀번호가 다릅니다."
            showAlert = true
        }
    }
}
