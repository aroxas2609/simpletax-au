import SwiftUI

struct DepreciationView: View {
    @EnvironmentObject var appState: AppState
    @State private var depreciation: Depreciation
    
    init() {
        _depreciation = State(initialValue: Depreciation())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Depreciation Schedule")) {
                Toggle("Did you have a depreciation schedule prepared?", isOn: $depreciation.hasDepreciation)
                
                if depreciation.hasDepreciation {
                    HStack {
                        Text("Division 43 Amount")
                        Spacer()
                        TextField("0", value: $depreciation.division43, format: .currency(code: "AUD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Division 40 Amount")
                        Spacer()
                        TextField("0", value: $depreciation.division40, format: .currency(code: "AUD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Total Depreciation")
                        Spacer()
                        Text(depreciation.total, format: .currency(code: "AUD"))
                            .fontWeight(.semibold)
                    }
                }
            }
            
            Section {
                NavigationLink(destination: OffsetsView()) {
                    HStack {
                        Text("Next: Offsets & Medicare")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
        .navigationTitle("Depreciation")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: depreciation) { newValue in
            appState.depreciation = newValue
        }
        .onAppear {
            depreciation = appState.depreciation
        }
    }
} 