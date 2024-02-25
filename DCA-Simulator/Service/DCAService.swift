import Foundation

struct DCAService {
    func calculate(initialInvestmentAmount: Double,
                   monthlyDollarCostAveragingAmount: Double,
                   intialDateOfInvestmentIndex: Int) -> DCAResult {
        
        return .init(currentValue: 0,
                     investmentAmount: 0,
                     gain: 0,
                     yield: 0,
                     annualizedReturn: 0)
    }
}

struct DCAResult {
    let currentValue: Double
    let investmentAmount: Double
    let gain: Double
    let yield: Double
    let annualizedReturn: Double
}


