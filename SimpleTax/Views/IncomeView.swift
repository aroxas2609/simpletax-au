import SwiftUI

struct IncomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var income: Income
    
    init() {
        _income = State(initialValue: Income())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Income Details")) {
                HStack {
                    Text("Salary/Wages")
                    Spacer()
                    TextField("0", value: $income.salary, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Interest Income")
                    Spacer()
                    TextField("0", value: $income.interest, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Dividend Income")
                    Spacer()
                    TextField("0", value: $income.dividends, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Rental Income")
                    Spacer()
                    TextField("0", value: $income.rental, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Other Income")
                    Spacer()
                    TextField("0", value: $income.other, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section(header: Text("Summary")) {
                HStack {
                    Text("Total Income")
                    Spacer()
                    Text(income.total, format: .currency(code: "AUD"))
                        .fontWeight(.semibold)
                }
            }
            
            Section {
                NavigationLink(destination: DeductionsView()) {
                    HStack {
                        Text("Next: Deductions")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                .disabled(income.salary <= 0)
            }
        }
        .navigationTitle("Income Details")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: income) { newValue in
            appState.income = newValue
        }
        .onAppear {
            income = appState.income
        }
    }
} 