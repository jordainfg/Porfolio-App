//
//  AwardTests.swift
//  MultiPlatformPortfolioTests
//
//  Created by Jordain on 15/09/2021.
//

import XCTest
import CoreData
@testable import MultiPlatformPortfolio

class AwardTests: BaseTestCase {

    let awards = Award.allAwards

    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match it's name.")
        }
    }

    func testNewUserHasNoAwards() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "User should not have any awards at first launch")
        }
    }

    /// We are going to test if for each amount of items added we receive an award.
    func testAddingItems() {

        // This array now contains all the awards we can earn by inserting items.
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (amountOfAwardsForAmountOfItems, amountOfItemsForAward) in values.enumerated() {

            print("the amountOfItemsForAward is \(amountOfItemsForAward)*")

            // creates different scenarios, like when a user has 1, 10,20 items. etc.
            for _ in 0..<amountOfItemsForAward {
                _ = Item(context: managedObjectContext)

            }

            // checks if the user earned an award
            let matches = awards.filter { award in
                award.criterion == "items" && dataController.hasEarned(award: award)
            }

            print("The amountOfAwardsForAmountOfItems is  \(matches.count)*")

            XCTAssertEqual(matches.count,
                           amountOfAwardsForAmountOfItems + 1,
                "Adding \(amountOfItemsForAward) items should unlock \(amountOfAwardsForAmountOfItems + 1) awards.")

            dataController.deleteAll()
        }
    }

    func testCompletedItems() {

        // This array now contains all the awards we can earn by inserting items.
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (amountOfAwardsForAmountOfItems, amountOfItemsForAward) in values.enumerated() {

            print("the amountOfCompletedItemsForAward is \(amountOfItemsForAward)*")

            // creates different scenarios, like when a user has 1, 10,20 items. etc.
            for _ in 0..<amountOfItemsForAward {
                let item = Item(context: managedObjectContext)
                item.completed = true
            }

            // checks if the user earned an award
            let matches = awards.filter { award in
                award.criterion == "complete" && dataController.hasEarned(award: award)
            }

            print("The amountOfAwardsForAmountOfCompletedItems is  \(matches.count)*")

            XCTAssertEqual(matches.count,
                           amountOfAwardsForAmountOfItems + 1,
                "Completing \(amountOfItemsForAward) items should unlock \(amountOfAwardsForAmountOfItems + 1) awards.")

            dataController.deleteAll()
        }
    }
}
