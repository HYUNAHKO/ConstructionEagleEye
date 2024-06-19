import SwiftUI

struct ReportWritingView: View {
    @State private var reportTitle: String = ""
    @State private var reportContent: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Submit Work Report")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            TextField("Report Title", text: $reportTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextEditor(text: $reportContent)
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding()

            Button(action: submitReport) {
                Text("Submit Report")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Report Submission"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            Spacer()
        }
        .padding()
        .navigationBarTitle("Submit Work Report", displayMode: .inline)
    }

    private func submitReport() {
        guard !reportTitle.isEmpty else {
            alertMessage = "Please enter the report title"
            showAlert = true
            return
        }

        guard !reportContent.isEmpty else {
            alertMessage = "Please enter the report content"
            showAlert = true
            return
        }

        // 여기에 보고서 제출 로직을 추가합니다.
        alertMessage = "The report has been successfully submitted"
        showAlert = true
    }
}
