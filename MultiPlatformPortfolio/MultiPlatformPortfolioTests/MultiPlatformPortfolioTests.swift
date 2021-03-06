//
//  MultiPlatformPortfolioTests.swift
//  MultiPlatformPortfolioTests
//
//  Created by Jordain on 14/09/2021.
//

import CoreData
import XCTest
@testable import MultiPlatformPortfolio

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
