import SwiftUI

struct SignUpView: View {
    @Binding var isUserLoggedIn: Bool
    @State private var name = "" // 이름 필드 추가
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var certificationNumber = ""
    @State private var isManager = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    @ObservedObject var userModel: UserModel 

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Name", text: $name) // 이름 필드 추가
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Text("이메일 형식: example@domain.com")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Text("비밀번호 형식: 최소 8자 이상, 알파벳과 숫자 포함")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                Toggle(isOn: $isManager) {
                    Text("Register as Manager")
                }
                .padding()

                if isManager {
                    TextField("Certification Number", text: $certificationNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }

                Button("Create Account") {
                    signUp()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Sign Up Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarTitle("Sign Up")
        }
    }

    private func signUp() {
        guard !name.isEmpty else {
            alertMessage = "이름을 입력해 주세요"
            showAlert = true
            return
        }
        
        guard userModel.isValidEmail(id: email) else {
            alertMessage = "이메일 형식을 확인해 주세요"
            showAlert = true
            return
        }

        guard userModel.isValidPassword(pwd: password) else {
            alertMessage = "비밀번호 형식을 확인해 주세요"
            showAlert = true
            return
        }

        guard password == confirmPassword else {
            alertMessage = "비밀번호가 일치하지 않습니다"
            showAlert = true
            return
        }

        if isManager {
            guard certificationNumber == "1234" else {
                alertMessage = "인증 번호가 잘못되었습니다"
                showAlert = true
                return
            }
        }

        let role = isManager ? UserModel.UserRole.manager : UserModel.UserRole.worker
        if userModel.registerUser(name: name, email: email, password: password, role: role) {
            alertMessage = "회원 가입 성공! 로그인을 진행해주세요."
            showAlert = true
            isUserLoggedIn = true
        } else {
            alertMessage = "이미 등록된 이메일이거나 회원 가입에 실패했습니다."
            showAlert = true
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(isUserLoggedIn: .constant(false), userModel: UserModel())
    }
}
