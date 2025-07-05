import Foundation

class TaxCalculator {
    static func calculateTax(income: Income, deductions: Deductions, depreciation: Depreciation, offsets: Offsets, personalInfo: PersonalInfo) -> TaxResult {
        let totalIncome = income.total
        let totalDeductions = deductions.total + depreciation.total
        let taxableIncome = max(0, totalIncome - totalDeductions)
        
        // Tax payable (ATO brackets FY2024-25)
        let taxOnTaxableIncome: Double
        if taxableIncome <= 18200 {
            taxOnTaxableIncome = 0
        } else if taxableIncome <= 45000 {
            taxOnTaxableIncome = 0.19 * (taxableIncome - 18200)
        } else if taxableIncome <= 120000 {
            taxOnTaxableIncome = 5092 + 0.325 * (taxableIncome - 45000)
        } else if taxableIncome <= 180000 {
            taxOnTaxableIncome = 29467 + 0.37 * (taxableIncome - 120000)
        } else {
            taxOnTaxableIncome = 51667 + 0.45 * (taxableIncome - 180000)
        }
        
        // Medicare levy (2%)
        let medicareLevy = 0.02 * taxableIncome
        
        // Medicare levy surcharge (if no private health)
        var medicareSurcharge: Double = 0
        if !offsets.privateHealth {
            // Use combined income for families (spouse + dependents)
            let combinedIncome = taxableIncome + (personalInfo.hasSpouse ? personalInfo.spouseTaxableIncome : 0)
            let familyThreshold = personalInfo.hasSpouse ? 186000 : 93000 // Double threshold for families
            
            if combinedIncome > familyThreshold + 51000 { // 144k for singles, 186k + 51k = 237k for families
                medicareSurcharge = 0.015 * taxableIncome
            } else if combinedIncome > familyThreshold + 15000 { // 108k for singles, 186k + 15k = 201k for families
                medicareSurcharge = 0.0125 * taxableIncome
            } else if combinedIncome > familyThreshold { // 93k for singles, 186k for families
                medicareSurcharge = 0.01 * taxableIncome
            }
        }
        
        // Low Income Tax Offset (LITO)
        var lito: Double = 0
        if taxableIncome <= 37500 {
            lito = 700
        } else if taxableIncome <= 45000 {
            lito = 700 - 0.05 * (taxableIncome - 37500)
        } else if taxableIncome <= 66667 {
            lito = 325 - 0.015 * (taxableIncome - 45000)
        }
        lito = max(0, lito)
        
        // Spouse offset eligibility check
        var spouseRebate = offsets.spouseRebate
        if personalInfo.hasSpouse && !offsets.privateHealth {
            // Basic spouse offset logic - can be enhanced based on specific ATO rules
            let combinedIncome = taxableIncome + personalInfo.spouseTaxableIncome
            if combinedIncome < 300000 { // Example threshold
                // Spouse offset may be available
                // This is a simplified version - actual ATO rules are more complex
            }
        }
        
        // Total offsets
        let totalOffsets = lito + spouseRebate
        
        // Total tax payable
        let totalTaxPayable = max(0, taxOnTaxableIncome + medicareLevy + medicareSurcharge - totalOffsets)
        
        // Refund or amount owing
        let refund = offsets.taxWithheld - totalTaxPayable
        
        return TaxResult(
            totalIncome: totalIncome,
            totalDeductions: totalDeductions,
            taxableIncome: taxableIncome,
            taxOnTaxableIncome: taxOnTaxableIncome,
            medicareLevy: medicareLevy,
            medicareSurcharge: medicareSurcharge,
            lito: lito,
            spouseRebate: spouseRebate,
            totalOffsets: totalOffsets,
            totalTaxPayable: totalTaxPayable,
            taxWithheld: offsets.taxWithheld,
            refund: refund
        )
    }
} 