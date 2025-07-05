import SwiftUI

struct DeductionsView: View {
    @EnvironmentObject var appState: AppState
    @State private var deductions: Deductions
    
    init() {
        _deductions = State(initialValue: Deductions())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Deductions")) {
                HStack {
                    Text("Work-related Expenses")
                    Spacer()
                    TextField("0", value: $deductions.workExpenses, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Self-education Expenses")
                    Spacer()
                    TextField("0", value: $deductions.education, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Donations")
                    Spacer()
                    TextField("0", value: $deductions.donations, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Tax Agent Fees")
                    Spacer()
                    TextField("0", value: $deductions.agentFees, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Investment Property Expenses")
                    Spacer()
                    TextField("0", value: $deductions.propertyExpenses, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section(header: Text("Summary")) {
                HStack {
                    Text("Total Deductions")
                    Spacer()
                    Text(deductions.total, format: .currency(code: "AUD"))
                        .fontWeight(.semibold)
                }
            }
            
            Section {
                NavigationLink(destination: DepreciationView()) {
                    HStack {
                        Text("Next: Depreciation")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
        .navigationTitle("Deductions")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: deductions) { newValue in
            appState.deductions = newValue
        }
        .onAppear {
            deductions = appState.deductions
        }
    }
} 