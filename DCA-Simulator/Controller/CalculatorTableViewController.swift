import UIKit

class CalculatorTableViewController: UITableViewController {
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var currencyLabels: [UILabel]!
    @IBOutlet weak var investmentAmountCurrencyLabel: UILabel!
    
    var asset: AssetModel?
    
    override func viewDidLoad() {
        ///Break point is added here, to see the results of Asset whenever the Search Results is Clicked
        super.viewDidLoad()
        setupViews()
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
}
