import UIKit

class DateSelectionTableViewController: UITableViewController {
    
    ///Properties
    var timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjustedModel?
    var selectedIndex: Int? ///Date of Investment Index Selected from Select Date Page (nil when there is no index selected)
    ///
    private var monthInfos: [MonthInfo] = []
    
    var didSelectDate: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupMonthInfos()
    }
    
    private func setupNavigation() {
        title = "Select Date"
    }
    
    private func setupMonthInfos() {
        monthInfos = timeSeriesMonthlyAdjusted?.getMonthInfos() ?? []
    }
    
}

extension DateSelectionTableViewController {
    
    ///Number of Section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    ///Number Of Rows In Section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthInfos.count
    }
    
    ///Cell For Row At
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        ///Creating Table View Cell Properties
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DateSelectionTableViewCell
        let index = indexPath.item
        let monthInfo = monthInfos[index]
        let isSelected = index == selectedIndex
        
        cell.configure(with: monthInfo, index: index, isSelected: isSelected)
        
        return cell
    }
    
    ///Did Select Row At: Everytime the user select this Cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectDate?(indexPath.item) ///Closure for Selecting Date
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

class DateSelectionTableViewCell: UITableViewCell {
    ///Properties for Dynamic UI Label / Text
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthsAgoLabel: UILabel! ///How many "months ago" is this from Today from This Current Month
    
    ///Configuring the Cell with Date Information with MonthInfo (MonthInfo, Date Index, isSelected Date Index)
    func configure(with monthInfo: MonthInfo, index: Int, isSelected: Bool) {
        monthLabel.text = monthInfo.date.MMYYFormat ///Change the Month Date  to MMYY Format from Date+Extension
        accessoryType = isSelected ? .checkmark : .none ///If one of the Date Index Selected (show Checkmark)
        
        if index == 1 {
            monthsAgoLabel.text = "1 month ago"
        } else if index > 1{
            monthsAgoLabel.text = "\(index) months ago"
        } else {
            monthsAgoLabel.text = "Just invested"
        }
    }
}
