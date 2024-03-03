import XCTest ///Library for Unit Test
@testable import DCA_Simulator ///Testing the Project Target (DCA-Simulator to DCA_Simulator)

final class DCAServiceTests: XCTestCase {

    ///SUT (System Under Test): Trying to Accessing DCAService (Business Logic)
    var sut: DCAService!
    
    ///This Function is like ViewDidLoad
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = DCAService() ///When this file Load we want to Initialized DCAService() to be and instance
    }

    ///This function is like ViewDidDisappear
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil ///When we finished the test, we don't want to to introduce any States
    }

    ///Format of Writing Unit Test Function Name
    ///1. What
    ///2. Given
    ///3. Expectation
    
    ///Test Cases Identifier
    ///1. Asset = Winning | DCA = True => Positive Gain
    ///2. Asset = Winning | DCA = False => Positive Gain
    ///3. Asset = Losing | DCA = True => Negative Gain
    ///4. Asset = Losing | DCA = False => Negative Gain
    
    func testResult_givenWinningAssetAndDCAIsUsed_expectPositiveGain() {
        ///1. Given
        let initialInvestmentAmount: Double = 5000
        let monthlyDollarCostAveragingAmount: Double = 1500
        let intialDateOfInvestmentIndex: Int = 5
        let asset = buildWinningAsset()
        
        ///2. When
        let result = sut.calculate(asset: asset,
                                   initialInvestmentAmount: initialInvestmentAmount,
                                   monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                   intialDateOfInvestmentIndex: intialDateOfInvestmentIndex)
        
        ///3. Then
        ///Initial Investment: $5000
        ///DCA: $1500 x 5 = $7500
        ///Total: $5000 + $7500 = $12.500
        XCTAssertEqual(result.investmentAmount, 12500)
        XCTAssertTrue(result.isProfitable) ///Must be Profittable
        ///At first, XCTAssertEqual() is Failed because of the Differentiation of Decimal Point Value it is not 17342.224 but it said 17342.25774225774
        ///Solution: adding accuracy properties with 0.1
        XCTAssertEqual(result.currentValue, 17342.224, accuracy: 0.1)
        XCTAssertEqual(result.gain, 4842.224, accuracy: 0.1)
        XCTAssertEqual(result.yield, 0.3873, accuracy: 0.0001)
        
        //Manual Test for Current Value:
        ///Jan: $5000 / 100 = 50 shares
        ///Feb: $1500 / 110 = 13.6363 shares
        ///March: $1500 / 120 = 12.5 shares
        ///April: $1500 / 130 = 11.5384 shares
        ///May: $1500 / 140 = 10.7142 shares
        ///June: $1500 / 150 = 10 shares
        ///Total shares = 108.3889 shares
        ///Total current value = 108.3889 x 160 (Latest Month Closing Price) = $17,342.224
        
        //Manual Test for Gain Value:
        ///Gain = $17,342.224 - $12.500 = 4842.224
        
        //Manual Test for Yield Percentage Value:
        ///Yield = Gain / Investment Amount
        ///Yield = $4842.224 / $12.500 = 0.3873 %
    }
    
    func testResult_givenWinningAssetAndDCAIsNotUsed_expectPositiveGain() {
        ///1. Given
        let initialInvestmentAmount: Double = 5000
        let monthlyDollarCostAveragingAmount: Double = 0 ///Simulates the User not using DCA by making it 0
        let intialDateOfInvestmentIndex: Int = 3
        let asset = buildWinningAsset()
        
        ///2. When
        let result = sut.calculate(asset: asset,
                                   initialInvestmentAmount: initialInvestmentAmount,
                                   monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                   intialDateOfInvestmentIndex: intialDateOfInvestmentIndex)
        
        ///3. Then
        ///Initial Investment: $5000
        ///DCA: $0 x 3 = $0
        ///Total: $5000 + $0 = $5.000
        XCTAssertEqual(result.investmentAmount, 5000)
        XCTAssertTrue(result.isProfitable) ///Must be Profittable
        XCTAssertEqual(result.currentValue, 6666.666, accuracy: 0.1)
        XCTAssertEqual(result.gain, 1666.666, accuracy: 0.1)
        XCTAssertEqual(result.yield, 0.3333, accuracy: 0.0001)
        
        //Manual Test for Current Value:
        ///March: $5000 / 120 = 41.6666 shares
        ///April: $0 / 130 = 0 shares
        ///May: $0 / 140 = 0shares
        ///June: $0 / 150 = 0 shares
        ///Total shares = 41.6666 shares
        ///Total current value = 41.6666 x 160 (Latest Month Closing Price) = $6.666.666
        
        //Manual Test for Gain Value:
        ///Gain = $6666.666 - $5000 = $1,666.666
        
        //Manual Test for Yield Percentage Value:
        ///Yield = Gain / Investment Amount
        ///Yield = $6666.666 / $5000 = 0.3333 %
    }
    
    ///Creating a Test for Winning Assets for the Test Function Above
    private func buildWinningAsset() -> AssetModel {
        let searchResult = buildSearchResult()
        let meta = buildMeta()
        
        ///This Format Data can be Accessed by Activate Breakpoints in viewDidLoad() function of CalculatorTableViewController then run the apps
        ///After that type po asset.timeSeriesMonthlyAdjusted
        ///The data below is not important but we want to cover the Test Case of Winning Assets so it should be like this
        let timeSeries: [String : OHLC] = ["2023-01-25" : OHLC(open: "100", close: "110", adjustedClose: "110"),
                                           "2023-02-25" : OHLC(open: "110", close: "120", adjustedClose: "120"),
                                           "2023-03-25" : OHLC(open: "120", close: "130", adjustedClose: "130"),
                                           "2023-04-25" : OHLC(open: "130", close: "140", adjustedClose: "140"),
                                           "2023-05-25" : OHLC(open: "140", close: "150", adjustedClose: "150"),
                                           "2023-06-25" : OHLC(open: "150", close: "160", adjustedClose: "160")]
        
        ///Debugging the XCTAssertTrue(result.isProfitable) by Getting this Function Below from getNumberOfShares() function from DCAService.swift
        ///by Putting Breakpoints in let dcaInvestmentShares
        ///At first, the Test Function XCTAssertTrue(result.isProfitable) is Failed because the value of close = "0"
        // Adjusted Open = Double(ohlc.open)! * (Double(ohlc.adjustedClose)! / Double(ohlc.close)!)
        // 100 * 110 / 0 = 0 (FAILED)
        
        let timeSeriesMonthlyAdjusted = TimeSeriesMonthlyAdjustedModel(meta: meta,
                                                                       timeSeries: timeSeries)
        
        return AssetModel(searchResult: searchResult,
                          timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
    }
    
    ///Extracting the SearchResult for buildWinningAsset() function Above
    private func buildSearchResult() -> SearchResult {
        return SearchResult(symbol: "XYZ", name: "XYZ Company", type: "ETF", currency: "USD")
    }
    
    ///Extracting the Meta data from TimeSeriesMonthlyAdjustedModel for buildWinningAsset() function Above
    private func buildMeta() -> Meta {
        return Meta(symbol: "XYZ")
    }
    
    func testResult_givenLosingAssetAndDCAIsUsed_expectNegativeGain() {
        ///1. Given
        let initialInvestmentAmount: Double = 5000
        let monthlyDollarCostAveragingAmount: Double = 1500
        let intialDateOfInvestmentIndex: Int = 5
        let asset = buildLosingAsset()
        
        ///2. When
        let result = sut.calculate(asset: asset,
                                   initialInvestmentAmount: initialInvestmentAmount,
                                   monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                   intialDateOfInvestmentIndex: intialDateOfInvestmentIndex)
        
        ///3. Then
        ///Initial Investment: $5000
        ///DCA: $1500 x 5 = $7500
        ///Total: $5000 + $7500 = $12.500
        XCTAssertEqual(result.investmentAmount, 12500)
        XCTAssertFalse(result.isProfitable) ///Must Not be Profittable
        XCTAssertEqual(result.currentValue, 9189.323, accuracy: 0.1)
        XCTAssertEqual(result.gain, -3310.677, accuracy: 0.1)
        XCTAssertEqual(result.yield, -0.2648, accuracy: 0.0001)
        
        //Manual Test for Current Value:
        ///Jan: $5000 / 170 = 29.4117 shares
        ///Feb: $1500 / 160 = 9.375 shares
        ///March: $1500 / 150 = 10 shares
        ///April: $1500 / 140 =  10.7142 shares
        ///May: $1500 / 130 = 11.5384 shares
        ///June: $1500 / 120 = 12.5 shares
        ///Total shares = 83.5393 shares
        ///Total current value = 83.5393 x 110 (Latest Month Closing Price) = $9,189.323
        
        //Manual Test for Gain Value:
        ///Gain = $9,189.323 - $5000 = - $3.310.667
        
        //Manual Test for Yield Percentage Value:
        ///Yield = Gain / Investment Amount
        ///Yield = - $3310.667 / $12.500 = - 0.2648 %
    }
    
    func testResult_givenLosingAssetAndDCAIsNotUsed_expectNegativeGain() {
        ///1. Given
        let initialInvestmentAmount: Double = 5000
        let monthlyDollarCostAveragingAmount: Double = 0
        let intialDateOfInvestmentIndex: Int = 3
        let asset = buildLosingAsset()
        
        ///2. When
        let result = sut.calculate(asset: asset,
                                   initialInvestmentAmount: initialInvestmentAmount,
                                   monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                   intialDateOfInvestmentIndex: intialDateOfInvestmentIndex)
        
        ///3. Then
        ///Initial Investment: $5000
        ///DCA: $0 x 3 = $0
        ///Total: $5000 + $0 = $5.000
        XCTAssertEqual(result.investmentAmount, 5000, accuracy: 0.1)
        XCTAssertFalse(result.isProfitable) ///Must Not be Profittable
        XCTAssertEqual(result.currentValue, 3666.666, accuracy: 0.1)
        XCTAssertEqual(result.gain, -1333.334, accuracy: 0.1)
        XCTAssertEqual(result.yield, -0.2666, accuracy: 0.0001)
        
        //Manual Test for Current Value:
        ///March: $5000 / 150 = 33,3333333333 shares
        ///April: $0 / 140 =  0 shares
        ///May: $0 / 130 = 0 shares
        ///June: $0 / 120 = 0 shares
        ///Total shares = 0 shares
        ///Total current value = 33,3333333333 x 110 (Latest Month Closing Price) = $3.666,666
        
        //Manual Test for Gain Value:
        ///Gain = Current Value - Investment Amount =
        ///Gain = $3.666,666 - $5000 = - $1.333,334
        
        //Manual Test for Yield Percentage Value:
        ///Yield = Gain / Investment Amount
        ///Yield = - $1.333,334 / $5000 = - 0,2666668 %
    }
    
    ///Creating a Test for Losing Assets for the Test Function Above
    private func buildLosingAsset() -> AssetModel {
        let searchResult = buildSearchResult()
        let meta = buildMeta()
        
        ///This Format Data can be Accessed by Activate Breakpoints in viewDidLoad() function of CalculatorTableViewController then run the apps
        ///After that type po asset.timeSeriesMonthlyAdjusted
        ///The data below is not important but we want to cover the Test Case of Winning Assets so it should be like this
        let timeSeries: [String : OHLC] = ["2023-01-25" : OHLC(open: "170", close: "160", adjustedClose: "160"),
                                           "2023-02-25" : OHLC(open: "160", close: "150", adjustedClose: "150"),
                                           "2023-03-25" : OHLC(open: "150", close: "140", adjustedClose: "140"),
                                           "2023-04-25" : OHLC(open: "140", close: "130", adjustedClose: "130"),
                                           "2023-05-25" : OHLC(open: "130", close: "120", adjustedClose: "120"),
                                           "2023-06-25" : OHLC(open: "120", close: "110", adjustedClose: "110")]
        
        ///Debugging the XCTAssertTrue(result.isProfitable) by Getting this Function Below from getNumberOfShares() function from DCAService.swift
        ///by Putting Breakpoints in let dcaInvestmentShares
        ///At first, the Test Function XCTAssertTrue(result.isProfitable) is Failed because the value of close = "0"
        // Adjusted Open = Double(ohlc.open)! * (Double(ohlc.adjustedClose)! / Double(ohlc.close)!)
        // 100 * 110 / 0 = 0 (FAILED)
        
        let timeSeriesMonthlyAdjusted = TimeSeriesMonthlyAdjustedModel(meta: meta,
                                                                       timeSeries: timeSeries)
        
        return AssetModel(searchResult: searchResult,
                          timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
    }
    
    func testInvestmentAmount_whenDCAIsUsed_expectResult() {
        ///1. Given
        let initialInvestmentAmount: Double = 500
        let monthlyDollarCostAveragingAmount: Double  = 200
        let intialDateOfInvestmentIndex: Int = 4 ///Meaning the investment Started 5 months ago
        
        ///2. When
        let investmentAmount = sut.getInvestmentAmount(initialInvestmentAmount: initialInvestmentAmount,
                                monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                intialDateOfInvestmentIndex: intialDateOfInvestmentIndex)
        ///3. Then
        XCTAssertEqual(investmentAmount, 1300)
        
        ///Explaination of Investment Amount DCAService.swift Function:
        ///Initial Amount  = 500
        ///DCA: 4 x 200 = 800, DCA happens for the first time in the second month not the first month
        ///Total = 500 + 800 = 1300
    }

    func testInvestmentAmount_whenDCAIsNotUsed_expectResult() {
        ///1. Given
        let initialInvestmentAmount: Double = 500
        let monthlyDollarCostAveragingAmount: Double  = 0
        let intialDateOfInvestmentIndex: Int = 4 ///Meaning the investment Started 5 months ago
        
        ///2. When
        let investmentAmount = sut.getInvestmentAmount(initialInvestmentAmount: initialInvestmentAmount,
                                monthlyDollarCostAveragingAmount: monthlyDollarCostAveragingAmount,
                                intialDateOfInvestmentIndex: intialDateOfInvestmentIndex)
        ///3. Then
        XCTAssertEqual(investmentAmount, 500)
        
        ///Explaination of Investment Amount DCAService.swift Function:
        ///Initial Amount  = 500
        ///DCA: 4 x 0 = 0, DCA happens for the first time in the second month not the first month
        ///Total = 500 + 0 = 500
    }
    
    //MARK: - EXAMPLE OF BASIC UNIT TEST (BELOW)
    ///Prefixing the testExample() function (without throws an error) otherwise it's not going to work. So, now it can run individual test
    ///To disable Unit Test Function, we can use Underscore in front of the name of the Function (e.g: func _testExamplePrefix() )
    func testExample() {
        ///Format of Writing Unit Test:
        ///1. Given
        let num1 = 1
        let num2 = 2
        ///2. When
        let result = performAddition(num1: num1, num2: num2)
        ///3. Then
        XCTAssertEqual(result, 3)
        
        ///Example of Fail Unit Test
        //let results = performAddition(num1: 1, num2: 2)
        /////This test case will not be succesful because based on the Function of performAddition(), it is not equal to 4 but to 3
        //XCTAssertEqual(results, 4) ///XCTAssertEqual function meaning results must be equal to 4
        //XCTAssertTrue(results < 3) ///XCTAssertEqual function meaning results is not less than 3. Therefore, it's false
    }
    
    func performAddition(num1: Int, num2: Int) -> Int {
        return num1 + num2
    }
    
}
