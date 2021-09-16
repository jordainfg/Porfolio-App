//
//  ExtensionTests.swift
//  MultiPlatformPortfolioTests
//
//  Created by Jordain on 15/09/2021.
//

import XCTest
import SwiftUI
@testable import MultiPlatformPortfolio
class ExtensionTests: XCTestCase {
    func testSequenceKeyPathSortingSelf() {
        let items = [1, 2, 3, 4, 5]
        let sortedItems = items.sorted(by: \.self)
        XCTAssertEqual(items, sortedItems, "The sorted numbers must be ascending")
    }

    func testSequenceKeyPathSortingCustom() {
        struct Example: Equatable {
            let value: String
        }

        let example = Example(value: "a")
        let example2 = Example(value: "b")
        let example3 = Example(value: "c")

        let sortedExamples = [example, example2, example3].sorted(by: \Example.value, using: >)

        XCTAssertEqual(sortedExamples, [example3, example2, example])
    }

    func testBundleDecodingAwards() {
        let awards = Bundle.main.decode([Award].self, from: "Awards.json")
        XCTAssertFalse(awards.isEmpty, "Awards.json should decode to a non-empty array.")
    }

    func testDecodingString() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode(String.self, from: "DecodableString.json")
        XCTAssertEqual(data, "The rain in Spain falls mainly on the Spaniards.",
                       "The string must match the content of DecodableString.json.")
    }

    func testDecodingDictionary() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode([String: Int].self, from: "DecodableDictionary.json")
        XCTAssertEqual(data.count, 3, "There should be three items decoded from DecodableDictionary.json.")
        XCTAssertEqual(data["One"], 1, "The dictionary should contain Int to String mappings.")
    }

    func testBindingOnChange() {
        var storedValue = ""

        let binding = Binding(
            get: { storedValue },
            set: { storedValue = $0 }
        )
        var onChangeFunctionRun = false

        func exampleFunctionToCall() {
            onChangeFunctionRun = true
        }

        let changedBinding = binding.onChange(exampleFunctionToCall)

        changedBinding.wrappedValue = "Test"

        XCTAssertTrue(onChangeFunctionRun, "The onChange() function was not run.")
    }
}
