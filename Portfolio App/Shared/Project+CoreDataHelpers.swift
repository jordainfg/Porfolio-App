//
//  Project+CoreDataHelpers.swift
//  Project+CoreDataHelpers
//
//  Created by Jordain on 03/09/2021.
//

import Foundation
extension Project {
    
    static let colors = ["Pink", "Purple", "Red", "Orange", "Gold", "Green", "Teal", "Light Blue", "Dark Blue", "Midnight", "Dark Gray", "Gray"]
    
    var projectTitle: String {
        title ?? "New Project"
    }

    var projectDetail: String {
        detail ?? ""
    }

    var projectColor: String {
        color ?? "Light Blue"
    }
    
    static var example: Project {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let project = Project(context: viewContext)
        project.title = "Example Project"
        project.detail = "This is an example project"
        project.closed = true
        project.creationDate = Date()
        return project
    }
    
    var projectItems: [Item] {
            let itemsArray = items?.allObjects as? [Item] ?? []
            return itemsArray
    }
    
    var completionAmount: Double {
        let originalItems = items?.allObjects as? [Item] ?? [] // 1. Do our little typecast dance to get an array of items.

        guard originalItems.isEmpty == false else { return 0 } // 2. If that’s empty, then return 0 because we don’t have a completion amount.

        let completedItems = originalItems.filter(\.completed) // 3. Otherwise, create a second array by filtering the first for completed items.
        
        return Double(completedItems.count) / Double(originalItems.count) // Finally, divide the count of completed items by the count of the original items.
    }
}