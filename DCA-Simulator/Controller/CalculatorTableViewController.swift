import UIKit

class CalculatorTableViewController: UITableViewController {
    
    ///Properties for Numeric Keyboard (TextField)
    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var moneyDollarCostAveragingTextField: UITextField!
    @IBOutlet weak var initialDateOfInvestmentTextField: UITextField!
    
    ///Properties for Dynamic UI Label / Text
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var currencyLabels: [UILabel]!
    @IBOutlet weak var investmentAmountCurrencyLabel: UILabel!
    
    var asset: AssetModel?
    
    override func viewDidLoad() {
        ///Break point is added here, to see the results of Asset whenever the Search Results is Clicked
        super.viewDidLoad()
        setupViews()
        setupTextField()
    }
    
    ///Setup the View to Display Symbol (Ticker Code), Asset Name, and Currency Label based on the Selected Search Result Data from APIService
    private func setupViews() {
        symbolLabel.text = asset?.searchResult.symbol
        nameLabel.text = asset?.searchResult.name
        investmentAmountCurrencyLabel.text = asset?.searchResult.currency
        currencyLabels.forEach { (label) in
            label.text = asset?.searchResult.currency.addBrackets()
        }
    }
    
    ///Setup keyboard view for Done button to close the Keyboard
    private func setupTextField() {
        initialInvestmentAmountTextField.addDoneButton()
        moneyDollarCostAveragingTextField.addDoneButton()
        initialDateOfInvestmentTextField.delegate = self
    }
    
    ///This Method is Handling the Navigation Destination to DateSelectionTableViewController (Date Selection with segue identifier: showDateSelection)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ///1, Make sure the segue.identifier = showDateSelection
        ///2. Make sure, the segue is type DateSelectionTableViewController
        ///3. Make sure, we are able to cast the sender as TimeSeriesMonthlyAdjustedModel
        if segue.identifier == "showDateSelection",
           let dateSelectionTableViewController = segue.destination as? DateSelectionTableViewController,
           let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjustedModel{
            dateSelectionTableViewController.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
        }
    }
    
}

extension CalculatorTableViewController: UITextFieldDelegate {
    ///This Function perform Navigation while the TextField remains empty from CalculatorTableViewController and Not Showing the Keyboard
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        ///Capturing the Event whenever the user Tap on the TextField of "Initial Date Investment"
        if textField == initialDateOfInvestmentTextField {
            ///Navigate to the Date Selection Page and perform Date Selection based on the Assets
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted)
        }
        
        ///Don't show a normal keyboard whenever the TextField of "Initial Date Investment" is tapped but instead Navigate to Date Selection Page
        return false
    }
}
