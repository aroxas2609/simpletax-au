import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingExportSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Calculate tax when view appears
                .onAppear {
                    appState.calculateTax()
                }
                
                // Personal Details Section
                SummarySection(title: "Personal Details") {
                    SummaryRow(label: "Name", value: appState.personalInfo.fullName)
                    SummaryRow(label: "Date of Birth", value: appState.personalInfo.dateOfBirth.formatted(date: .abbreviated, time: .omitted))
                    SummaryRow(label: "Address", value: appState.personalInfo.address)
                    SummaryRow(label: "Has Spouse", value: appState.personalInfo.hasSpouse ? "Yes" : "No")
                    if appState.personalInfo.hasSpouse {
                        SummaryRow(label: "Spouse's Taxable Income", value: appState.personalInfo.spouseTaxableIncome, format: .currency(code: "AUD"))
                    }
                }
                
                // Income Section
                SummarySection(title: "Income") {
                    SummaryRow(label: "Salary/Wages", value: appState.income.salary, format: .currency(code: "AUD"))
                    SummaryRow(label: "Interest Income", value: appState.income.interest, format: .currency(code: "AUD"))
                    SummaryRow(label: "Dividend Income", value: appState.income.dividends, format: .currency(code: "AUD"))
                    SummaryRow(label: "Rental Income", value: appState.income.rental, format: .currency(code: "AUD"))
                    SummaryRow(label: "Other Income", value: appState.income.other, format: .currency(code: "AUD"))
                    SummaryRow(label: "Total Income", value: appState.income.total, format: .currency(code: "AUD"), isTotal: true)
                }
                
                // Deductions Section
                SummarySection(title: "Deductions") {
                    SummaryRow(label: "Work-related Expenses", value: appState.deductions.workExpenses, format: .currency(code: "AUD"))
                    SummaryRow(label: "Self-education Expenses", value: appState.deductions.education, format: .currency(code: "AUD"))
                    SummaryRow(label: "Donations", value: appState.deductions.donations, format: .currency(code: "AUD"))
                    SummaryRow(label: "Tax Agent Fees", value: appState.deductions.agentFees, format: .currency(code: "AUD"))
                    SummaryRow(label: "Investment Property Expenses", value: appState.deductions.propertyExpenses, format: .currency(code: "AUD"))
                    
                    if appState.depreciation.hasDepreciation {
                        SummaryRow(label: "Division 43 Depreciation", value: appState.depreciation.division43, format: .currency(code: "AUD"))
                        SummaryRow(label: "Division 40 Depreciation", value: appState.depreciation.division40, format: .currency(code: "AUD"))
                        SummaryRow(label: "Total Depreciation", value: appState.depreciation.total, format: .currency(code: "AUD"))
                    }
                    
                    SummaryRow(label: "Total Deductions", value: appState.deductions.total + appState.depreciation.total, format: .currency(code: "AUD"), isTotal: true)
                }
                
                // Tax Calculation Section
                if let result = appState.taxResult {
                    SummarySection(title: "Tax Calculation") {
                        SummaryRow(label: "Taxable Income", value: result.taxableIncome, format: .currency(code: "AUD"))
                        SummaryRow(label: "Tax on Taxable Income", value: result.taxOnTaxableIncome, format: .currency(code: "AUD"))
                        SummaryRow(label: "Medicare Levy (2%)", value: result.medicareLevy, format: .currency(code: "AUD"))
                        
                        if appState.personalInfo.hasSpouse && !appState.offsets.privateHealth {
                            let combinedIncome = result.taxableIncome + appState.personalInfo.spouseTaxableIncome
                            SummaryRow(label: "Combined Income (for MLS)", value: combinedIncome, format: .currency(code: "AUD"))
                        }
                        
                        SummaryRow(label: "Medicare Surcharge", value: result.medicareSurcharge, format: .currency(code: "AUD"))
                        SummaryRow(label: "Low Income Tax Offset", value: result.lito, format: .currency(code: "AUD"))
                        SummaryRow(label: "Spouse Rebate", value: result.spouseRebate, format: .currency(code: "AUD"))
                        SummaryRow(label: "Total Offsets", value: result.totalOffsets, format: .currency(code: "AUD"))
                        SummaryRow(label: "Total Tax Payable", value: result.totalTaxPayable, format: .currency(code: "AUD"))
                        SummaryRow(label: "Tax Withheld", value: result.taxWithheld, format: .currency(code: "AUD"))
                    }
                    
                    // Final Result Section
                    SummarySection(title: "Final Result") {
                        HStack {
                            Text(result.refund >= 0 ? "REFUND" : "AMOUNT OWING")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Text(abs(result.refund), format: .currency(code: "AUD"))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(result.refund >= 0 ? .green : .red)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        showingExportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export to PDF")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        appState.reset()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset All Data")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Tax Summary")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingExportSheet) {
            ExportView()
        }
    }
}

struct SummarySection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                content
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct SummaryRow: View {
    let label: String
    let value: Any
    let format: Format?
    let isTotal: Bool
    
    init(label: String, value: Any, format: Format? = nil, isTotal: Bool = false) {
        self.label = label
        self.value = value
        self.format = format
        self.isTotal = isTotal
    }
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(isTotal ? .semibold : .regular)
            Spacer()
            if let format = format {
                Text(value as! Double, format: format)
                    .fontWeight(isTotal ? .semibold : .regular)
            } else {
                Text("\(value)")
                    .fontWeight(isTotal ? .semibold : .regular)
            }
        }
    }
}

struct ExportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Export to PDF")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("PDF export functionality will be implemented here.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 