//
//  AssetTest.swift
//  AssetTest
//
//  Created by Jordain on 14/09/2021.
//

import XCTest
@testable import MultiPlatformPortfolio

class AssetTests: XCTestCase {
    
    func testColorsExist() {
        for color in Project.colors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
    }
    
    func testJSONLoadsCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }
    
}
