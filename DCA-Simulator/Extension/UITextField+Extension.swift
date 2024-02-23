import UIKit

extension UITextField {
    
    ///Done Button to Close Keyboard Feature
    func addDoneButton() {
        ///Done Button Properties
        let screenWidth = UIScreen.main.bounds.width //Taking entire Width Screen
        let doneToolbar: UIToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: screenWidth, height: 50))
        let flexBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        ///Behaviour whenever the Done button is Clicked / Tapped
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        let items = [flexBarButtonItem, doneBarButtonItem]
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        inputAccessoryView = doneToolbar
    }
    
    @objc private func dismissKeyboard() {
        resignFirstResponder()
    }
}
