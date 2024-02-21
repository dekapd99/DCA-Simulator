import Foundation

/// VANTAGE ALPHA API
/// Converting Time Series Data (Monthly Adjusted)
/// https://www.alphavantage.co/support/#api-key

struct MonthInfo {
    let date: Date
    let adjustedOpen: Double
    let adjustedClose: Double
}

struct TimeSeriesMonthlyAdjustedModel: Decodable {
    
    let meta: Meta
    let timeSeries: [String: OHLC]
    
    enum CodingKeys: String, CodingKey {
        case meta = "Meta Data"
        case timeSeries = "Monthly Adjusted Time Series"
    }
    
    func getMonthInfos() -> [MonthInfo] {
        var monthInfos: [MonthInfo] = []
        let sortedTimeSeries = timeSeries.sorted(by: { $0.key > $1.key })
        
        ///Get Sorted Month Info
        sortedTimeSeries.forEach { (dateString, ohlc) in
            ///DateFormatter to Convert API Date Object "2024-02-21" to Native Swift Date Format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: dateString)!
            
            ///Get the Adjusted Open Formula from getAdjustedOpen() function
            let adjustedOpen = getAdjustedOpen(ohlc: ohlc)
            let monthInfo = MonthInfo(date: date, adjustedOpen: adjustedOpen, adjustedClose: Double(ohlc.adjustedClose)!)
            monthInfos.append(monthInfo)
        }
        
        ///Testing only for SortedTimeSeries of Search Results
        //print("sorted: \(sortedTimeSeries)")
        
        return monthInfos
    }
    
    ///Adjusted Open Formula is ...
    // adjusted open = open x (adjusted close / close)
    private func getAdjustedOpen(ohlc: OHLC) -> Double {
        ///The Formula  above written as below
        return Double(ohlc.open)! * (Double(ohlc.adjustedClose)! / Double(ohlc.close)!)
    }
    
}

struct Meta: Decodable {
    
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "2. Symbol"
    }
}

///OHLC (Open, High, Low, Close)
///
struct OHLC: Decodable {
    let open: String
    let close: String
    let adjustedClose: String
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case close = "4. close"
        case adjustedClose = "5. adjusted close"
    }
}

///Monthly Adjusted Time Series Results
///Source: https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=IBM&apikey=demo
//"1. open": "183.6300",
//"2. high": "188.9500",
//"3. low": "178.7500",
//"4. close": "179.7000",
//"5. adjusted close": "179.7000",
//"6. volume": "62230327",
//"7. dividend amount": "1.6600"
