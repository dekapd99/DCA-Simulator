import UIKit

class DateSelectionTableViewController: UITableViewController {
    
    var timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjustedModel?
    var monthInfos: [MonthInfo] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMonthInfos()
    }
    
    private func setupMonthInfos() {
        if let monthInfos = timeSeriesMonthlyAdjusted?.getMonthInfos() {
            self.monthInfos = monthInfos
        }
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
        let monthInfo = monthInfos[indexPath.item]
        
        ///Creating Table View Cell Properties
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DateSelectionTableViewCell
        cell.configure(with: monthInfo)
        
        return cell
    }
    
    ///Did Select Row At
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

class DateSelectionTableViewCell: UITableViewCell {
    ///Properties for Dynamic UI Label / Text
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthsAgoLabel: UILabel! ///How many "months ago" is this from Today from This Current Month
    
    ///Configuring the Cell with Information with MonthInfo
    func configure(with monthInfo: MonthInfo) {
        backgroundColor = .red
    }
}
