import Foundation

///Double Converter Extension to String (Data Type)
extension Double {
    
    ///Converting Double Value to String Value (Data Type)
    var stringValue: String {
        return String(describing: self)
    }
    
    ///Converting more than 2 Decimal into 2 Decimal Only
    var twoDecimalPlaceString: String {
        return String(format: "%.2f", self)
    }
    
    ///Converting Double Value to Currency Format (US Dollar)
    var currencyFormat: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en-US") ///Get the formatter US Dollar
        formatter.numberStyle = .currency
        
        ///Get the String from the Double value itself (extension) if fails then return the Two Decimal number format
        return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }
    
    ///Converting Double Value to Percentage Format --> Use case in Yield Label
    var percentageFormat: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en-US") ///Get the formatter US Dollar
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2 ///Display 2 Decimal Digits 
        
        ///Get the String from the Double value itself (extension) if fails then return the Two Decimal number format
        return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }
    
    ///Converting Double Value to Gain Format (Gain(+) / Loss (-)) --> Use case in Gain Label
    ///Sets the hasDollarSymbol = true & hasDecimalPlaces, so it will be set to false in the CalculatorTableViewController
    func toCurrencyFormat(hasDollarSymbol: Bool = true, hasDecimalPlaces: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en-US") ///Convert the Currency to US Dollar
        formatter.numberStyle = .currency
        
        if hasDollarSymbol == false {
            formatter.currencySymbol = "" ///Remove the Currency Symbol
        }
        
        if hasDecimalPlaces == false {
            formatter.maximumFractionDigits = 0 ///Don't Display Decimal Digits 
        }
        ///Get the String from the Double value itself (extension) if fails then return the Two Decimal number format
        return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }
}
