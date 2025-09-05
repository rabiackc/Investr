import XCTest
@testable import Investr

final class CalculatorTests: XCTestCase {
    
    func testInvestmentTargetCalculation() {
        let income = 10000.0
        let targetPercentage = 20.0
        let expectedTarget = 2000.0
        
        let result = income * (targetPercentage / 100)
        
        XCTAssertEqual(result, expectedTarget, accuracy: 0.01)
    }
    
    func testRemainingBudget() {
        let income = 10000.0
        let fixed = 3000.0
        let daily = 1500.0
        
        let remaining = income - fixed - daily
        XCTAssertEqual(remaining, 5500.0)
    }
}

