//
//  MultiPlatformPortfolioUITests.swift
//  MultiPlatformPortfolioUITests
//
//  Created by Jordain on 16/09/2021.
//

import XCTest

class MultiPlatformPortfolioUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    func testExample() throws {
        XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")
    }
}

