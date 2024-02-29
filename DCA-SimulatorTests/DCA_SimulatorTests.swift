import XCTest ///Library for Unit Test
@testable import DCA_Simulator ///Testing the Project Target (DCA-Simulator to DCA_Simulator)

final class DCA_SimulatorTests: XCTestCase {

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
    func testDCAResult_givenDCAIsUsed_expectResult() {
        
    }
    
    func testDCAResult_givenDCAIsNotUsed_expectResult() {
        
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
