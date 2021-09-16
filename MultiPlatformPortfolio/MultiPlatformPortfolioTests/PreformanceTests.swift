//
//  PreformanceTests.swift
//  MultiPlatformPortfolioTests
//
//  Created by Jordain on 16/09/2021.
//

import XCTest
@testable import MultiPlatformPortfolio

class PerformanceTests: BaseTestCase {

    func testAwardCalculationPerformance() throws {
        // Create a significant amount of test data
        for _ in 1...100 {
            try dataController.createSampleData()
        }

        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 25).joined()

        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }
}
