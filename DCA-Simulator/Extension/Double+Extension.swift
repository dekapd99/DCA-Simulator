import Foundation

///Double Converter Extension to String (Data Type)
extension Double {
    
    ///Converting Double Value to String Value (Data Type)
    var stringValue: String {
        return String(describing: self)
    }
    
    ///Converting more than 2 decimal into 2 decimal only
    var twoDecimalPlaceString: String {
        return String(format: "%.2f", self)
    }
}
