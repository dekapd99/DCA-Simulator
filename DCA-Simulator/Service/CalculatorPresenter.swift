import UIKit

struct CalculatorPresenter {
    
    ///At first, this UI Presenter was in the Publishers.CombineLatest3 (CalculatorTableViewContoller.swift)
    ///But for Unit Testing purposes we must unwrapped / extracted to this way so it would be easier
    func getPresentation(result: DCAResult) -> CalculatorPresentation {
        ///Adding Symbol Logic for Gain(+) / Loss (-)
        let isProfitable = result.isProfitable == true
        let gainSymbol = isProfitable ? "+" : ""
        
        ///Initialized the Calculator Presenter for Creating DCA Service Cell Properties
        return .init(currentValueLabelBackgroundColor: isProfitable ? .themeGreenShade : .themeRedShade,
                     currentValue: result.currentValue.currencyFormat,
                     investmentAmount: result.investmentAmount.toCurrencyFormat(hasDecimalPlaces: false),
                     gain: result.gain.toCurrencyFormat(hasDollarSymbol: true, hasDecimalPlaces: false).prefix(withText: gainSymbol),
                     yield: result.yield.percentageFormat.prefix(withText: gainSymbol).addBrackets(),
                     yieldLabelTextColor: isProfitable ? .systemGreen : .systemRed,
                     annualizedReturn: result.annualizedReturn.percentageFormat,
                     annualizedReturnLabelTextColor: isProfitable ? .systemGreen : .systemRed)
    }
}

///Object that returns the value of DCA Service Cell Properties
struct CalculatorPresentation {
    ///From Publishers.CombineLatest3 (CalculatorTableViewContoller.swift)
    let currentValueLabelBackgroundColor: UIColor
    let currentValue: String
    let investmentAmount: String
    let gain: String
    let yield: String
    let yieldLabelTextColor: UIColor
    let annualizedReturn: String
    let annualizedReturnLabelTextColor: UIColor
}
