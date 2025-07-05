import SwiftUI

struct PersonalInfoView: View {
    @EnvironmentObject var appState: AppState
    @State private var personalInfo: PersonalInfo
    
    init() {
        _personalInfo = State(initialValue: PersonalInfo())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Personal Details")) {
                TextField("Full Name", text: $personalInfo.fullName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                DatePicker("Date of Birth", selection: $personalInfo.dateOfBirth, displayedComponents: .date)
                
                TextField("Residential Address", text: $personalInfo.address, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                
                TextField("Tax File Number (Optional)", text: $personalInfo.tfn)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Section(header: Text("Spouse Information")) {
                Toggle("Do you have a spouse?", isOn: $personalInfo.hasSpouse)
                
                if personalInfo.hasSpouse {
                    HStack {
                        Text("Spouse's Taxable Income")
                        Spacer()
                        TextField("0", value: $personalInfo.spouseTaxableIncome, format: .currency(code: "AUD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Text("This information is used for Medicare Levy Surcharge calculations and spouse offset eligibility.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                NavigationLink(destination: IncomeView()) {
                    HStack {
                        Text("Next: Income Details")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                .disabled(personalInfo.fullName.isEmpty || personalInfo.address.isEmpty)
            }
        }
        .navigationTitle("Personal Details")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: personalInfo) { newValue in
            appState.personalInfo = newValue
        }
        .onAppear {
            personalInfo = appState.personalInfo
        }
    }
} 