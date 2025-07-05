import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("SimpleTax AU")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Australian Tax Return Calculator")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                NavigationLink(destination: PersonalInfoView()) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Start Tax Return")
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                if appState.hasData {
                    NavigationLink(destination: SummaryView()) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("View Summary")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .environmentObject(appState)
    }
}

class AppState: ObservableObject {
    @Published var personalInfo = PersonalInfo()
    @Published var income = Income()
    @Published var deductions = Deductions()
    @Published var depreciation = Depreciation()
    @Published var offsets = Offsets()
    @Published var taxResult: TaxResult?
    
    var hasData: Bool {
        !personalInfo.fullName.isEmpty || income.total > 0 || deductions.total > 0
    }
    
    func calculateTax() {
        taxResult = TaxCalculator.calculateTax(
            income: income,
            deductions: deductions,
            depreciation: depreciation,
            offsets: offsets,
            personalInfo: personalInfo
        )
    }
    
    func reset() {
        personalInfo = PersonalInfo()
        income = Income()
        deductions = Deductions()
        depreciation = Depreciation()
        offsets = Offsets()
        taxResult = nil
    }
} 