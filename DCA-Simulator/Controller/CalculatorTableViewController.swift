import UIKit
import Combine

class CalculatorTableViewController: UITableViewController {
    
    ///Properties for DCA Calculates Service (Label)
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var investmentAmountLabel: UILabel!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    @IBOutlet weak var annualizedReturnLabel: UILabel!
    
    ///Properties for Numeric Keyboard (TextField)
    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var monthlyDollarCostAveragingTextField: UITextField!
    @IBOutlet weak var initialDateOfInvestmentTextField: UITextField!
    
    ///Properties for Dynamic UI Label / Text
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var currencyLabels: [UILabel]!
    @IBOutlet weak var investmentAmountCurrencyLabel: UILabel!
    @IBOutlet weak var dateSlider: UISlider!
    
    var asset: AssetModel?
    
    @Published private var initialDateOfInvestmentIndex: Int? ///Observable Date of Investment Index Selected from Select Date Page
    @Published private var initialInvestmentAmount: Int? ///Observable Intial Investment Amount from Calculator TextField
    @Published private var monthlyDollarCostAveragingAmount: Int? ///Observable Dollar Cost Averaging from Calculator TextField
    
    private var subscribers = Set<AnyCancellable>()
    private let dcaService = DCAService()
    
    override func viewDidLoad() {
        ///Break point is added here, to see the results of Asset whenever the Search Results is Clicked
        super.viewDidLoad()
        setupViews()
        setupTextField()
        observeForm() ///Observing the Initial Date of Investment Changing Value
        setupDateSlider() ///Setup the Number of Elements in Slider (Value)
        resetViews() ///Reseting the Storyboard Placeholder
    }
    
    ///When the Calculator Page is Open (Immediately display Keyboard I/O inside Initial Investment Amount TextField)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initialInvestmentAmountTextField.becomeFirstResponder() ///Focusing to this TextField when Calculator Page is Open
    }
    
    ///Setup the View to Display Symbol (Ticker Code), Asset Name, and Currency Label based on the Selected Search Result Data from APIService
    private func setupViews() {
        navigationItem.title = asset?.searchResult.name
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
        monthlyDollarCostAveragingTextField.addDoneButton()
        initialDateOfInvestmentTextField.delegate = self
    }
    
    ///Setup the Numbers of Elements in Slider (Value)
    private func setupDateSlider() {
        ///Getting the Count Index of Asset Monthly Data then Convert the Value of Count Data to Float
        if let count = asset?.timeSeriesMonthlyAdjusted.getMonthInfos().count {
            let dateSliderCount = count - 1 ///Index Out of Range Bug Fix (Without this the Slider cannot be in Maximum Position)
            dateSlider.maximumValue = dateSliderCount.floatValue
        }
    }
    
    ///Observable Object for Intial Date of Investment (Changing the Slider position whenever the Index of Initial Date of Investment is being updated)
    private func observeForm() {
        $initialDateOfInvestmentIndex.sink { [weak self] (index) in
            ///Guarding the index cannot be nil then convert the Integer of initialDateOfInvestmentIndex to Float (Data Type)
            guard let index = index else { return }
            self?.dateSlider.value = index.floatValue
            
            ///Updating the Intial Date of Investment Value by Moving the Slider
            if let dateString = self?.asset?.timeSeriesMonthlyAdjusted.getMonthInfos()[index].date.MMYYFormat {
                self?.initialDateOfInvestmentTextField.text = dateString
            }
            
            ///Printing index number from the Select Date page
            //print(index)
        }.store(in: &subscribers)
        
        ///Listening to Value Changes from TextField input in Calculator Page (Investment Amount)
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: initialInvestmentAmountTextField).compactMap({
            ($0.object as? UITextField)?.text
        }).sink { [weak self] (text) in
            self?.initialInvestmentAmount = Int(text) ?? 0 ///Convert the Text to Int and Make the Default Cast equals to 0
            print("initialInvestmentAmountTextField: \(text)")
        }.store(in: &subscribers)
        
        ///Listening to Value Changes from TextField input in Calculator Page (Dollar Cost Averaging Amount)
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: monthlyDollarCostAveragingTextField).compactMap({
            ($0.object as? UITextField)?.text
        }).sink { [weak self] (text) in
            self?.monthlyDollarCostAveragingAmount = Int(text) ?? 0 ///Convert the Text to Int and Make the Default Cast equals to 0
            print("monthlyDollarCostAveragingTextField: \(text)")
        }.store(in: &subscribers)
        
        ///Listening to 3 Combine Value input from TextField in Calculator Page
        Publishers.CombineLatest3($initialInvestmentAmount, $monthlyDollarCostAveragingAmount, $initialDateOfInvestmentIndex).sink { [weak self] (initialInvestmentAmount, monthlyDollarCostAveragingAmount, initialDateOfInvestmentIndex) in
            
            ///Guarding the Input Value of the TextFields cannot be Nil (Empty Value / 0)
            guard let initialInvestmentAmount = initialInvestmentAmount,
                  let monthlyDollarCostAveragingAmount = monthlyDollarCostAveragingAmount,
                  let initialDateOfInvestmentIndex = initialDateOfInvestmentIndex,
                  let asset = self?.asset else { return }
                  
            ///Getting the Result as Double Value for the Investment Amount and DCA Amount
            let result = self?.dcaService.calculate(asset: asset,
                                                    initialInvestmentAmount: initialInvestmentAmount.doubleValue,
                                                    monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount.doubleValue,
                                                    intialDateOfInvestmentIndex: initialDateOfInvestmentIndex)
            
            ///Adding Symbol Logic for Gain(+) / Loss (-)
            let isProfitable = (result?.isProfitable == true)
            let gainSymbol = isProfitable ? "+" : ""
            
            ///Creating DCA Service Cell Properties
            self?.currentValueLabel.backgroundColor = isProfitable ? .themeGreenShade : .themeRedShade
            self?.currentValueLabel.text = result?.currentValue.currencyFormat
            
            self?.investmentAmountLabel.text = result?.investmentAmount.toCurrencyFormat(hasDecimalPlaces: false)
            self?.gainLabel.text = result?.gain.toCurrencyFormat(hasDollarSymbol: false, hasDecimalPlaces: false).prefix(withText: gainSymbol)
            
            self?.yieldLabel.text = result?.yield.percentageFormat.prefix(withText: gainSymbol).addBrackets()
            self?.yieldLabel.textColor = isProfitable ? .systemGreen : .systemRed
            
            self?.annualizedReturnLabel.text = result?.annualizedReturn.percentageFormat
            self?.annualizedReturnLabel.textColor = isProfitable ? .systemGreen : .systemRed
            
        }.store(in: &subscribers)
        
    }
    
    ///This Method is Handling the Navigation Destination to DateSelectionTableViewController (Date Selection with segue identifier: showDateSelection)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ///1, Make sure the segue.identifier = showDateSelection
        ///2. Make sure, the segue is type DateSelectionTableViewController
        ///3. Make sure, we are able to cast the sender as TimeSeriesMonthlyAdjustedModel
        if segue.identifier == "showDateSelection",
           let dateSelectionTableViewController = segue.destination as? DateSelectionTableViewController,
           let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjustedModel {
            
            ///Perform an Assignment in Select Date Page to get the Monthly Date, Selected Index, and Get the Selected Date Index data to Initial Date of Investment
            dateSelectionTableViewController.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
            dateSelectionTableViewController.selectedIndex = initialDateOfInvestmentIndex
            dateSelectionTableViewController.didSelectDate = { [weak self] index in
                self?.handleDateSelection(at: index) ///Get the Selected Date Index
            }
        }
    }
    
    ///Handling one of the Selection of Date when clicked and then back to CalculatorTableViewController page (Calculator Page)
    private func handleDateSelection(at index: Int) {
        ///Dismissing Date Selection (Select Date Page) whenever one of the Date of Investment is Clicked
        guard navigationController?.visibleViewController is DateSelectionTableViewController else { return }
        navigationController?.popViewController(animated: true)
        
        ///Get Date from timeSeriesMonthlyAdjusted and Put it in the Calculator Page
        if let monthInfos = asset?.timeSeriesMonthlyAdjusted.getMonthInfos() {
            initialDateOfInvestmentIndex = index
            let monthInfo = monthInfos[index]
            let dateString = monthInfo.date.MMYYFormat
            initialDateOfInvestmentTextField.text = dateString
        }
    }
    
    ///Reset the Current Placeholder from Storyboard to 0 / Default Value
    private func resetViews() {
        currentValueLabel.text = "0.00"
        investmentAmountLabel.text = "0.00"
        gainLabel.text = "-"
        yieldLabel.text = "-"
        annualizedReturnLabel.text = "-"
    }
    
    ///Handling the Value Changes for Initial Investment Date (by Moving the Slider)
    @IBAction func dateSliderDateChange(_ sender: UISlider) {
        initialDateOfInvestmentIndex = Int(sender.value)
        
        ///Printing the Slider Value
        //print(sender.value)
    }
}

extension CalculatorTableViewController: UITextFieldDelegate {
    ///This Function perform Navigation while the TextField remains empty from CalculatorTableViewController and Not Showing the Keyboard
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        ///Capturing the Event whenever the user Tap on the TextField of "Initial Date Investment"
        if textField == initialDateOfInvestmentTextField {
            ///Navigate to the Date Selection Page and perform Date Selection based on the Assets
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted)
            ///Don't show a normal keyboard whenever the TextField of "Initial Date Investment" is tapped but instead Navigate to Date Selection Page
            return false
        }
        
        return true ///Only show the Keyboard in the First & Second TextField (Initial Investment Amount & Monthly Dollar Cost Averaging Amout)
    }
}
