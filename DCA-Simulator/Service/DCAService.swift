import Foundation

struct DCAService {   
    func calculate(asset: AssetModel,
                   initialInvestmentAmount: Double,
                   monthlyDollarCostAveragingAmount: Double,
                   intialDateOfInvestmentIndex: Int) -> DCAResult {
        
        //1. DCA (Total Investment)
        let investmentAmount = getInvestmentAmount(initialInvestmentAmount: initialInvestmentAmount,
                                                   monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                                   intialDateOfInvestmentIndex: intialDateOfInvestmentIndex)
        
        //2. Latest Share Price
        let latestSharePrice = getLatestSharePrice(asset: asset)
        
        //3. Get Number of Shares
        let numberOfShares = getNumberOfShares(asset: asset,
                                               initialInvestmentAmount: initialInvestmentAmount,
                                               monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                               intialDateOfInvestmentIndex: intialDateOfInvestmentIndex)
        
        //4. Get Current Value
        let currentValue = getCurrentValue(numberOfShares: numberOfShares, latestSharePrice: latestSharePrice)
        
        //5. Get to Know if The Investment is Profitable
        let isProfitable = currentValue > investmentAmount
        
        //6. Get value of Gain / Loss from Investment
        let gain = currentValue - investmentAmount
        
        //7. Get value of Yield = gain / investmentAmount
        let yield = gain / investmentAmount
        
        //8. Calculates Annualized Return with CAGR (Compound Annual Growth Rate)
        ///https://www.investopedia.com/terms/c/cagr.asp
        let annualizedReturn = getAnnualizedReturn(currentValue: currentValue,
                                                   investmentAmount: investmentAmount,
                                                   intialDateOfInvestmentIndex: intialDateOfInvestmentIndex)
        
        return .init(currentValue: currentValue,
                     investmentAmount: investmentAmount,
                     gain: gain,
                     yield: yield,
                     annualizedReturn: annualizedReturn,
                     isProfitable: isProfitable)
    }
    
    //Computed Function below is to Simulates DCA

    ///Computed Function for Dollar Cost Averaging Service (Total Investment)
    ///1. Simulation of Total Investing:
    ///November (investing $100)
    ///October (investing $100)
    ///September (investing $500)
    ///Total Investing = $700
    func getInvestmentAmount(initialInvestmentAmount: Double,
                                     monthlyDollarCostAveragingAmount: Double,
                                     intialDateOfInvestmentIndex: Int) -> Double {
        
        var totalAmount = Double()
        totalAmount += initialInvestmentAmount
        let dollarCostAveragingAmounts = intialDateOfInvestmentIndex.doubleValue * monthlyDollarCostAveragingAmount
        totalAmount += dollarCostAveragingAmounts
        
        return totalAmount
    }
    
    ///Computed Function to Get Current Value
    ///2. Get Current Value:
    ///CurrentValue = number of shares (initial investment + DCA) x latest share price
    private func getCurrentValue(numberOfShares: Double, latestSharePrice: Double) -> Double {
        return numberOfShares * latestSharePrice
    }
    
    ///Computed Function to Get Latest Share Price
    ///3. Get Latest Share Price
    private func getLatestSharePrice(asset: AssetModel) -> Double {
        return asset.timeSeriesMonthlyAdjusted.getMonthInfos().first?.adjustedClose ?? 0
    }
    
    ///Computed Function to Get Number of Shares
    ///4. Get Number of Shares
    private func getNumberOfShares(asset: AssetModel,
                                   initialInvestmentAmount: Double,
                                   monthlyDollarCostAveragingAmount: Double,
                                   intialDateOfInvestmentIndex: Int) -> Double {
        
        var totalShares = Double()
        
        let initialInvestmentOpenPrice = asset.timeSeriesMonthlyAdjusted.getMonthInfos()[intialDateOfInvestmentIndex].adjustedOpen
        
        let initialInvestmentShares = initialInvestmentAmount / initialInvestmentOpenPrice
        totalShares += initialInvestmentShares
        asset.timeSeriesMonthlyAdjusted.getMonthInfos().prefix(intialDateOfInvestmentIndex).forEach { (monthInfo) in
            let dcaInvestmentShares = monthlyDollarCostAveragingAmount / monthInfo.adjustedOpen
            totalShares += dcaInvestmentShares
        }
        
        return totalShares
    }
    
    ///Computed Function to
    ///5. Get Annualized Return by Calculates Annualized Return with CAGR (Compound Annual Growth Rate)
    ///https://www.investopedia.com/terms/c/cagr.asp
    private func getAnnualizedReturn(currentValue: Double,
                                     investmentAmount: Double,
                                     intialDateOfInvestmentIndex: Int) -> Double {
        
        let rate = currentValue / investmentAmount ///Calculates the Ending Value over the Beginning Value
        let years = (intialDateOfInvestmentIndex.doubleValue + 1) / 12 ///+1 because the first month (index) = 0
        
        ///Return the Result with CAGR with Power (pangkat)
        ///https://www.investopedia.com/terms/c/cagr.asp
        let result = pow(rate, (1 / years)) - 1
        return result
        
        ///Debugging the Annual Return Bug (Uncomment the Print)
        /**
         * The bug caused by this code before: let years = ((intialDateOfInvestmentIndex + 1) / 12).doubleValue ///+1 because the first month (index) = 0
         * The result of (intialDateOfInvestmentIndex + 1) / 12 is integer and will be Rounded Below if the result = to 0.1 - 0.9, causing the return -100%
         */
        //print("rate: \(rate), intialDateOfInvestmentIndex: \(intialDateOfInvestmentIndex), years: \(years), result: \(result)")
    }
}

struct DCAResult {
    let currentValue: Double
    let investmentAmount: Double
    let gain: Double
    let yield: Double
    let annualizedReturn: Double
    let isProfitable: Bool
}
