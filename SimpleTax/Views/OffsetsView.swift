import SwiftUI

struct OffsetsView: View {
    @EnvironmentObject var appState: AppState
    @State private var offsets: Offsets
    
    init() {
        _offsets = State(initialValue: Offsets())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Offsets & Medicare")) {
                Toggle("Private Health Insurance", isOn: $offsets.privateHealth)
                
                HStack {
                    Text("Spouse/Dependent Rebate")
                    Spacer()
                    TextField("0", value: $offsets.spouseRebate, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                Stepper("Number of Dependents: \(offsets.dependents)", value: $offsets.dependents, in: 0...10)
                
                HStack {
                    Text("Tax Withheld")
                    Spacer()
                    TextField("0", value: $offsets.taxWithheld, format: .currency(code: "AUD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section {
                NavigationLink(destination: SummaryView()) {
                    HStack {
                        Text("Calculate & View Summary")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                .disabled(offsets.taxWithheld <= 0)
            }
        }
        .navigationTitle("Offsets & Medicare")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: offsets) { newValue in
            appState.offsets = newValue
        }
        .onAppear {
            offsets = appState.offsets
        }
    }
} 