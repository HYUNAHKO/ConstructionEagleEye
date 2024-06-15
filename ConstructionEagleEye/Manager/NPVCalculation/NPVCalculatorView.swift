import SwiftUI

struct NPVCalculatorView: View {
    @State private var financialMonths: [FinancialMonth] = []
    @State private var interestRate: Double = 1.0 // Monthly interest rate on overdraft
    @State private var npvDiscountRate: Double = 0.1 // NPV discount rate

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Financial Data Entry")) {
                    ForEach($financialMonths.indices, id: \.self) { index in
                        FinancialMonthView(financialMonth: $financialMonths[index])
                    }
                    Button("Add Month") {
                        addNewFinancialMonth()
                    }
                }
                
                Section(header: Text("Calculations")) {
                    if !financialMonths.isEmpty {
                        Button("Calculate NPV") {
                            calculateNPV()
                        }
                    }
                }
                
                if let last = financialMonths.last {
                    Text("Total NPV: \(last.npv, specifier: "%.2f")")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("NPV and Financial Overview")
                                    .font(.headline) // Here you can modify the appearance but not the size directly.
                            }
                        }
                    }
                }
    private func addNewFinancialMonth() {
        let newMonth = FinancialMonth(month: financialMonths.count + 1)
        financialMonths.append(newMonth)
    }

    private func calculateNPV() {
        var cumulativeCashFlow = 0.0
        for (index, month) in financialMonths.enumerated() {
            cumulativeCashFlow += month.calculateNetCashFlow()
            let discountedCashFlow = cumulativeCashFlow / pow(1 + npvDiscountRate, Double(index + 1))
            month.npv = discountedCashFlow
        }
    }
}

struct FinancialMonthView: View {
    @Binding var financialMonth: FinancialMonth

    var body: some View {
        VStack {
            Text("Month \(financialMonth.month)")
            HStack {
                TextField("Direct Cost", value: $financialMonth.directCost, formatter: NumberFormatter())
                TextField("Indirect Cost", value: $financialMonth.indirectCost, formatter: NumberFormatter())
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.decimalPad)
            Text("Total Cost: \(financialMonth.totalCost, specifier: "%.2f")")
        }
        .onAppear {
            financialMonth.updateCalculations()
        }
    }
}

class FinancialMonth: Identifiable, ObservableObject {
    let id = UUID()
    let month: Int
    @Published var directCost: Double = 0
    @Published var indirectCost: Double = 6000 // Fixed as $6000 per month
    @Published var totalCost: Double = 0
    @Published var npv: Double = 0

    init(month: Int) {
        self.month = month
    }

    func updateCalculations() {
        totalCost = directCost + indirectCost
        // Additional financial calculations can be added here
    }

    func calculateNetCashFlow() -> Double {
        // This is a placeholder for actual cash flow calculations
        return directCost + indirectCost // Simplified example
    }
}

struct NPVCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        NPVCalculatorView()
    }
}
