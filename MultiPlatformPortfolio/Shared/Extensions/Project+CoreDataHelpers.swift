//
//  Project+CoreDataHelpers.swift
//  Project+CoreDataHelpers
//
//  Created by Jordain on 03/09/2021.
//

import Foundation
import SwiftUI
import CloudKit
extension Project {

    static let colors = [
        "Pink",
        "Purple",
        "Red",
        "Orange",
        "Gold",
        "Green",
        "Teal",
        "Light Blue",
        "Dark Blue",
        "Midnight",
        "Dark Gray",
        "Gray"
    ]

    var projectTitle: String {
        title ?? "New Project"
    }

    var projectDetail: String {
        detail ?? ""
    }

    var projectColor: String {
        color ?? "Light Blue"
    }

    var label: LocalizedStringKey {
        // swiftlint:disable:next line_length
        LocalizedStringKey("\(projectTitle), \(projectItems.count) items, \(completionAmount * 100, specifier: "%g")% complete.")
    }

    static var example: Project {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let project = Project(context: viewContext)
        project.title = "Example Project"
        project.detail = "This is an example project"
        project.closed = true
        project.creationDate = Date()
        return project
    }

    var projectItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }

    var projectItemsDefaultSorted: [Item] {
        return projectItems.sorted { first, second in
            if first.completed == false {
                if second.completed == true {
                    return true
                }
            } else if first.completed == true {
                if second.completed == false {
                    return false
                }
            }

            if first.priority > second.priority {
                return true
            } else if first.priority < second.priority {
                return false
            }

            return first.itemCreationDate < second.itemCreationDate
        }
    }

    var completionAmount: Double {
        // 1. Do our little typecast dance to get an array of items.
        let originalItems = items?.allObjects as? [Item] ?? []

        // 2. If that’s empty, then return 0 because we don’t have a completion amount.
        guard originalItems.isEmpty == false else { return 0 }
        // 3. Otherwise, create a second array by filtering the first for completed items
        let completedItems = originalItems.filter(\.completed)
        // Finally, divide the count of completed items by the count of the original items.
        return Double(completedItems.count) / Double(originalItems.count)
    }

    func projectItems(using sortOrder: Item.SortOrder) -> [Item] {
        switch sortOrder {
        case .title:
            return projectItems.sorted(by: \Item.itemTitle)
        case .creationDate:
            return projectItems.sorted(by: \Item.itemCreationDate)
        case .optimzed:
            return projectItemsDefaultSorted
        }
    }

    /// Creates a `CKRecord` from a `Project` -> maps `[Item]` of that `Project` to `[CKRecord]`
    /// - Parameter username: the username of the currently logged in user.
    /// - Returns: [CKRecord]
    func prepareCloudRecords(username: String) -> [CKRecord] {
        let parentName = objectID.uriRepresentation().absoluteString
        let parentID = CKRecord.ID(recordName: parentName)
        let parent = CKRecord(recordType: "Project", recordID: parentID)

        parent["title"] = projectTitle
        parent["detail"] = projectDetail
        parent["owner"] = username
        parent["closed"] = closed

        // map [Item] to [CKRecord]
        var itemRecords = projectItemsDefaultSorted.map { item -> CKRecord in
            let childName = item.objectID.uriRepresentation().absoluteString
            let childID = CKRecord.ID(recordName: childName)
            let child = CKRecord(recordType: "Item", recordID: childID)
            child["title"] = item.itemTitle
            child["detail"] = item.itemDetail
            child["completed"] = item.completed
            child["project"] = CKRecord.Reference(recordID: parentID, action: .deleteSelf)
            return child
        }

        itemRecords.append(parent) // set newly made [CKRecord] to parent Project
        return itemRecords
    }

    func checkCloudStatus(_ completion: @escaping (Bool) -> Void) {
        let name = objectID.uriRepresentation().absoluteString
        let id = CKRecord.ID(recordName: name)
        let operation = CKFetchRecordsOperation(recordIDs: [id])
        operation.desiredKeys = ["recordID"]

        operation.fetchRecordsCompletionBlock = { records, _ in
            if let records = records {
                completion(records.count == 1)
            } else {
                completion(false)
            }
        }

        CKContainer.default().publicCloudDatabase.add(operation)
    }
}
