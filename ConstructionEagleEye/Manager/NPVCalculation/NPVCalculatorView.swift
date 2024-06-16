import SwiftUI

struct NPVCalculatorView: View {
    @State private var financialMonths: [FinancialMonth] = []
    @State private var npvDiscountRate: Double = 0.1 // NPV 할인율
    @State private var totalNPV: Double = 0.0
    @State private var nextMonth: Int = 1 // 다음 추가할 월
    @State private var monthlyInterestRate: Double = 0.03 // 월별 이자율

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("재무 데이터 입력")) {
                    ForEach($financialMonths.indices, id: \.self) { index in
                        FinancialMonthInputView(financialMonth: $financialMonths[index], financialMonths: $financialMonths, nextMonth: $nextMonth, monthlyInterestRate: $monthlyInterestRate)
                    }
                    Button("월 추가") {
                        addNewFinancialMonth()
                    }
                    Button("마지막 월 삭제") {
                        deleteLastFinancialMonth()
                    }
                    .disabled(financialMonths.isEmpty) // 월이 없을 때는 버튼 비활성화
                }
                
                Section(header: Text("계산")) {
                    if !financialMonths.isEmpty {
                        Button("NPV 계산") {
                            calculateNPV()
                        }
                    }
                }
                
                Section(header: Text("월별 데이터")) {
                    ForEach(financialMonths) { month in
                        VStack(alignment: .leading) {
                            Text("월 \(month.month)")
                            Text("directCost: \(month.directCost, specifier: "%.2f")")
                            Text("indirectCost: \(month.indirectCost, specifier: "%.2f")")
                            Text("마크업: \(month.markup, specifier: "%.2f")")
                            Text("subtotal: \(month.subtotal, specifier: "%.2f")")
                            Text("markup: \(month.calculatedMarkup, specifier: "%.2f")")
                            Text("total billed: \(month.totalBilled, specifier: "%.2f")")
                            Text("retainage withheld: \(month.retainageWithheld, specifier: "%.2f")")
                            Text("payment received: \(month.paymentReceived, specifier: "%.2f")")
                            Text("total cost to date: \(month.totalCostToDate, specifier: "%.2f")")
                            Text("total amount billed to date: \(month.totalAmountBilledToDate, specifier: "%.2f")")
                            Text("total paid to date: \(month.totalPaidToDate, specifier: "%.2f")")
                            Text("overdraft end of month: \(month.overdraftEndOfMonth, specifier: "%.2f")")
                            Text("interest on overdraft balance: \(month.interestOnOverdraftBalance, specifier: "%.2f")")
                            Text("cash outflow: \(month.cashOutflow, specifier: "%.2f")") // 추가된 항목
                            Text("cash inflow: \(month.cashInflow, specifier: "%.2f")") // 추가된 항목
                            Text("total amount financed: \(month.totalAmountFinanced, specifier: "%.2f")")
                        }
                        .padding(.bottom, 5)
                    }
                }
                
                Text("총 NPV: \(totalNPV, specifier: "%.2f")")
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("NPV 및 재무 개요")
                        .font(.headline)
                }
            }
        }
    }

    private func addNewFinancialMonth() {
        let newMonth = FinancialMonth(month: nextMonth)
        if let lastMonth = financialMonths.last {
            newMonth.previousTotalBilled = lastMonth.totalBilled
            newMonth.previousRetainageWithheld = lastMonth.retainageWithheld
            newMonth.previousPaymentReceived = lastMonth.paymentReceived
            newMonth.previousTotalCostToDate = lastMonth.totalCostToDate
            newMonth.previousTotalAmountBilledToDate = lastMonth.totalAmountBilledToDate
            newMonth.previousTotalPaidToDate = lastMonth.totalPaidToDate
            newMonth.previousOverdraftEndOfMonth = lastMonth.overdraftEndOfMonth
            newMonth.previousTotalAmountFinanced = lastMonth.totalAmountFinanced
        }
        financialMonths.append(newMonth)
        nextMonth += 1 // 다음 월로 자동 증가
        updateAllCalculations()
    }

    private func deleteLastFinancialMonth() {
        if !financialMonths.isEmpty {
            financialMonths.removeLast()
            nextMonth -= 1 // 월 번호 감소
            updateAllCalculations()
        }
    }

    private func calculateNPV() {
        totalNPV = 0.0
        for (index, month) in financialMonths.enumerated() {
            let npvComponent = (month.cashInflow - month.cashOutflow) / pow(1 + monthlyInterestRate, Double(index + 1))
            month.npv = npvComponent
            totalNPV += npvComponent
        }
    }

    private func updateAllCalculations() {
        for month in financialMonths {
            month.updateCalculations(financialMonths: financialMonths, nextMonth: nextMonth, monthlyInterestRate: monthlyInterestRate)
        }
    }
}

struct FinancialMonthInputView: View {
    @Binding var financialMonth: FinancialMonth
    @Binding var financialMonths: [FinancialMonth]
    @Binding var nextMonth: Int
    @Binding var monthlyInterestRate: Double
    @State private var decimalFormatter = NumberFormatter.decimalFormatter

    var body: some View {
        VStack {
            Text("월 \(financialMonth.month)")
            HStack {
                TextField("directCost", value: $financialMonth.directCost, formatter: decimalFormatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                TextField("indirectCost", value: $financialMonth.indirectCost, formatter: decimalFormatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                TextField("마크업", value: $financialMonth.markup, formatter: decimalFormatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }
        }
        .onChange(of: financialMonth.directCost) { _ in
            financialMonth.updateCalculations(financialMonths: financialMonths, nextMonth: nextMonth, monthlyInterestRate: monthlyInterestRate)
        }
        .onChange(of: financialMonth.indirectCost) { _ in
            financialMonth.updateCalculations(financialMonths: financialMonths, nextMonth: nextMonth, monthlyInterestRate: monthlyInterestRate)
        }
        .onChange(of: financialMonth.markup) { _ in
            financialMonth.updateCalculations(financialMonths: financialMonths, nextMonth: nextMonth, monthlyInterestRate: monthlyInterestRate)
        }
    }
}

struct FinancialMonthView: View {
    @Binding var financialMonth: FinancialMonth

    var body: some View {
        VStack {
            Text("월 \(financialMonth.month)")
            Text("directCost: \(financialMonth.directCost, specifier: "%.2f")")
            Text("indirectCost: \(financialMonth.indirectCost, specifier: "%.2f")")
            Text("마크업: \(financialMonth.markup, specifier: "%.2f")")
            Text("subtotal: \(financialMonth.subtotal, specifier: "%.2f")")
            Text("markup: \(financialMonth.calculatedMarkup, specifier: "%.2f")")
            Text("total billed: \(financialMonth.totalBilled, specifier: "%.2f")")
            Text("retainage withheld: \(financialMonth.retainageWithheld, specifier: "%.2f")")
            Text("payment received: \(financialMonth.paymentReceived, specifier: "%.2f")")
            Text("total cost to date: \(financialMonth.totalCostToDate, specifier: "%.2f")")
            Text("total amount billed to date: \(financialMonth.totalAmountBilledToDate, specifier: "%.2f")")
            Text("total paid to date: \(financialMonth.totalPaidToDate, specifier: "%.2f")")
            Text("overdraft end of month: \(financialMonth.overdraftEndOfMonth, specifier: "%.2f")")
            Text("interest on overdraft balance: \(financialMonth.interestOnOverdraftBalance, specifier: "%.2f")")
            Text("cash outflow: \(financialMonth.cashOutflow, specifier: "%.2f")") // 추가된 항목
            Text("cash inflow: \(financialMonth.cashInflow, specifier: "%.2f")") // 추가된 항목
            Text("total amount financed: \(financialMonth.totalAmountFinanced, specifier: "%.2f")")
        }
    }
}

class FinancialMonth: Identifiable, ObservableObject {
    let id = UUID()
    let month: Int
    @Published var directCost: Double = 0
    @Published var indirectCost: Double = 0 // 고정된 비용 ($6000 월별)
    @Published var markup: Double = 0 // 마크업
    @Published var subtotal: Double = 0
    @Published var calculatedMarkup: Double = 0 // 마크업 금액
    @Published var totalBilled: Double = 0
    @Published var retainageWithheld: Double = 0
    @Published var paymentReceived: Double = 0
    @Published var totalCostToDate: Double = 0
    @Published var totalAmountBilledToDate: Double = 0
    @Published var totalPaidToDate: Double = 0
    @Published var overdraftEndOfMonth: Double = 0
    @Published var interestOnOverdraftBalance: Double = 0
    @Published var cashOutflow: Double = 0 // 추가된 항목
    @Published var cashInflow: Double = 0 // 추가된 항목
    @Published var totalAmountFinanced: Double = 0
    @Published var previousTotalBilled: Double = 0
    @Published var previousRetainageWithheld: Double = 0
    @Published var previousPaymentReceived: Double = 0
    @Published var previousTotalCostToDate: Double = 0
    @Published var previousTotalAmountBilledToDate: Double = 0
    @Published var previousTotalPaidToDate: Double = 0
    @Published var previousOverdraftEndOfMonth: Double = 0
    @Published var previousTotalAmountFinanced: Double = 0
    @Published var npv: Double = 0

    init(month: Int) {
        self.month = month
        // updateCalculations() 호출 제거
    }

    func updateCalculations(financialMonths: [FinancialMonth], nextMonth: Int, monthlyInterestRate: Double) {
        subtotal = directCost + indirectCost
        calculatedMarkup = subtotal * (markup / 100)
        totalBilled = subtotal + calculatedMarkup
        retainageWithheld = totalBilled * 0.1
        if month == nextMonth - 1 { // 마지막 달일 경우
            let totalRetainageWithheld = financialMonths.reduce(0) { $0 + $1.retainageWithheld }
            paymentReceived = previousTotalBilled - previousRetainageWithheld + totalRetainageWithheld
        } else {
            paymentReceived = previousTotalBilled - previousRetainageWithheld
        }
        totalCostToDate = previousTotalCostToDate + subtotal
        totalAmountBilledToDate = previousTotalAmountBilledToDate + totalBilled
        totalPaidToDate = previousTotalPaidToDate + paymentReceived
        overdraftEndOfMonth = previousTotalAmountFinanced + subtotal - previousPaymentReceived
        interestOnOverdraftBalance = overdraftEndOfMonth * 0.01 // 이자율 1%로 고정
        cashOutflow = subtotal + interestOnOverdraftBalance // cash outflow 값 설정
        cashInflow = paymentReceived // cash inflow 값 설정
        totalAmountFinanced = overdraftEndOfMonth + interestOnOverdraftBalance
        // 추가적인 재무 계산을 여기에 추가할 수 있음
    }

    func calculateNetCashFlow() -> Double {
        // 실제 현금 흐름 계산을 위한 자리표시자
        return subtotal + calculatedMarkup // 간단한 예제
    }
}

extension NumberFormatter {
    static var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

struct NPVCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        NPVCalculatorView()
    }
}

