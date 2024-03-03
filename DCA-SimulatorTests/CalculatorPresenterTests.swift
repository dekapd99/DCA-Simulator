import XCTest ///Library for Unit Test
@testable import DCA_Simulator ///Testing the Project Target (DCA-Simulator to DCA_Simulator)

final class CalculatorPresenterTests: XCTestCase {

    ///SUT (System Under Test): Trying to Accessing DCAService (Business Logic)
    var sut: CalculatorPresenter!
    
    ///This Function is like ViewDidLoad
    override func setUpWithError() throws {
        sut = CalculatorPresenter() ///When this file Load we want to Initialized DCAService() to be and instance
        try super.setUpWithError()
    }

    ///This function is like ViewDidDisappear
    override func tearDownWithError() throws {
        sut = nil ///When we finished the test, we don't want to to introduce any States
        try super.tearDownWithError()
    }

    ///Unit Test Function Format
    ///1. Test
    ///2. Given
    ///3. Expect
    func testAnnualReturnLabelTextColor_givenResultIsProfitable_expectSystemGreen() throws {
        ///Unit Test Logic Format
        ///1. Given
        let result = DCAResult(currentValue: 0,
                               investmentAmount: 0,
                               gain: 0,
                               yield: 0,
                               annualizedReturn: 0,
                               isProfitable: true)
        
        ///2. When
        let presentation = sut.getPresentation(result: result)
        
        ///3. Then
        XCTAssertEqual(presentation.annualizedReturnLabelTextColor, UIColor.systemGreen)
    }
    
    func testAnnualReturnLabelTextColor_givenResultIsNotProfitable_expectSystemGreen() throws {
        ///Unit Test Logic Format
        ///1. Given
        let result = DCAResult(currentValue: 0,
                               investmentAmount: 0,
                               gain: 0,
                               yield: 0,
                               annualizedReturn: 0,
                               isProfitable: true)
        
        ///2. When
        let presentation = sut.getPresentation(result: result)
        
        ///3. Then
        XCTAssertEqual(presentation.annualizedReturnLabelTextColor, UIColor.systemGreen)
    }
    
    func testAnnualReturnLabelTextColor_givenResultIsProfitable_expectSystemRed() throws {
        ///Unit Test Logic Format
        ///1. Given
        let result = DCAResult(currentValue: 0,
                               investmentAmount: 0,
                               gain: 0,
                               yield: 0,
                               annualizedReturn: 0,
                               isProfitable: false)
        
        ///2. When
        let presentation = sut.getPresentation(result: result)
        
        ///3. Then
        XCTAssertEqual(presentation.annualizedReturnLabelTextColor, UIColor.systemRed)
    }
    
    func testAnnualReturnLabelTextColor_givenResultIsNotProfitable_expectSystemRed() throws {
        ///Unit Test Logic Format
        ///1. Given
        let result = DCAResult(currentValue: 0,
                               investmentAmount: 0,
                               gain: 0,
                               yield: 0,
                               annualizedReturn: 0,
                               isProfitable: false)
        
        ///2. When
        let presentation = sut.getPresentation(result: result)
        
        ///3. Then
        XCTAssertEqual(presentation.annualizedReturnLabelTextColor, UIColor.systemRed)
    }
    
    func testYieldLabel_expectBrackets() {
        ///Unit Test Logic Format
        ///1. Given
        let openBracket: Character = "("
        let closeBracket: Character = ")"
        let result = DCAResult(currentValue: 0,
                               investmentAmount: 0,
                               gain: 0,
                               yield: 0.25,
                               annualizedReturn: 0,
                               isProfitable: false)
        ///2. When
        let presentation = sut.getPresentation(result: result)
        
        ///3. Then
        XCTAssertEqual(presentation.yield.first, openBracket)
        XCTAssertEqual(presentation.yield.last, closeBracket)
    }

}
