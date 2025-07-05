import Foundation

struct PersonalInfo: Codable {
    var fullName: String = ""
    var dateOfBirth: Date = Date()
    var address: String = ""
    var tfn: String = ""
    var hasSpouse: Bool = false
    var spouseTaxableIncome: Double = 0.0
}

struct Income: Codable {
    var salary: Double = 0.0
    var interest: Double = 0.0
    var dividends: Double = 0.0
    var rental: Double = 0.0
    var other: Double = 0.0
    
    var total: Double {
        salary + interest + dividends + rental + other
    }
}

struct Deductions: Codable {
    var workExpenses: Double = 0.0
    var education: Double = 0.0
    var donations: Double = 0.0
    var agentFees: Double = 0.0
    var propertyExpenses: Double = 0.0
    
    var total: Double {
        workExpenses + education + donations + agentFees + propertyExpenses
    }
}

struct Depreciation: Codable {
    var hasDepreciation: Bool = false
    var division43: Double = 0.0
    var division40: Double = 0.0
    
    var total: Double {
        hasDepreciation ? division43 + division40 : 0.0
    }
}

struct Offsets: Codable {
    var privateHealth: Bool = false
    var spouseRebate: Double = 0.0
    var dependents: Int = 0
    var taxWithheld: Double = 0.0
}

struct TaxResult: Codable {
    var totalIncome: Double = 0.0
    var totalDeductions: Double = 0.0
    var taxableIncome: Double = 0.0
    var taxOnTaxableIncome: Double = 0.0
    var medicareLevy: Double = 0.0
    var medicareSurcharge: Double = 0.0
    var lito: Double = 0.0
    var spouseRebate: Double = 0.0
    var totalOffsets: Double = 0.0
    var totalTaxPayable: Double = 0.0
    var taxWithheld: Double = 0.0
    var refund: Double = 0.0
} 