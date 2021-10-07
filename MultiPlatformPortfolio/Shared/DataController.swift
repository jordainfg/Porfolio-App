import CoreData
import SwiftUI
import CoreSpotlight
import WidgetKit
import StoreKit
/// An environment singleton responsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking awards, and dealing with sample data.
class DataController: ObservableObject {

    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer

    // MARK: - UnlockManager
    // The UserDefaults suite where we're saving user data.
    let defaults: UserDefaults

    // Loads and saves whether our premium unlock has been purchased.
    var fullVersionUnlocked: Bool {
       get {
         defaults.bool(forKey: "fullVersionUnlocked")
       }
       set {
        defaults.set(newValue, forKey: "fullVersionUnlocked")
       }
    }

    // MARK: - Init
    /// Initialises a data controller, either in memory (for temporary use such
    /// as testing and previewing in SwiftUI Previews),
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    /// - Parameter defaults: The UserDefaults suite where user data should be stored.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        container = NSPersistentCloudKitContainer(name: "MultiPlatformPortfolioApp", managedObjectModel: Self.model)

        // For testing and previewing purposes, we create a
        // temporary, in-memory database by writing to /dev/null
        // so our data is destroyed after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let groupID = "group.com.featurex.MultiPlatformPortfolio"

            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appendingPathComponent("MultiPlatformPortfolioApp.sqlite")
            }
        }

        self.defaults = defaults // Unlock Manager

container.loadPersistentStores { _, error in
    if let error = error {
        fatalError("Fatal error loading store: \(error.localizedDescription)")
    }

    self.container.viewContext.automaticallyMergesChangesFromParent = true

    #if DEBUG
    if CommandLine.arguments.contains("enable-testing") {
        self.deleteAll()
    }
    #endif
}
    }

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }

        return dataController
    }()

    /// That loads our data model exactly once, so now when we created our
    /// NSPersistentCloudKitContainer we need to make it use that model rather
    /// than have it attempt to load the model itself. This will stop two models being
    /// loaded at the same time, which is what causes Core Data to get confused.
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "MultiPlatformPortfolioApp", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    /// Creates example projects and items to make manual testing easier.
    /// - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
    func createSampleData() throws {
        let viewContext = container.viewContext

        for projectCounter in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(projectCounter)"
            project.items = []
            project.creationDate = Date()
            project.closed = Bool.random()

            for itemCounter in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(itemCounter)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.project = project
                item.priority = Int16.random(in: 1...3)
            }
        }

        try viewContext.save() // write to PERMANENT storage
    }

    /// Saves our Core Data context if(“if and only if”) there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because all our attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func delete(_ object: NSManagedObject) {
        let id = object.objectID.uriRepresentation().absoluteString

        if object is Item { // If is Item, delete the item.
            CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])

        } else { // else if is project delete project
            CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
        }

        container.viewContext.delete(object)
    }

    func deleteAll() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        delete(fetchRequest1)

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
        delete(fetchRequest2)
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        // We’re specifically asking the batch delete request to send back all the object IDs that got deleted.
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest1.resultType = .resultTypeObjectIDs
        // That array of object IDs goes into a dictionary with the key NSDeletedObjectsKey,
        // with a default empty array if it can’t be read.
        if let delete = try? container.viewContext.execute(batchDeleteRequest1) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            // That dictionary goes into the mergeChanges() method, which is what
            // updates our view context with the changes we just made to the persistent store.
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    // MARK: integrate with Spotlight
    func update(_ item: Item) {
        let itemID = item.objectID.uriRepresentation().absoluteString
        let projectID = item.project?.objectID.uriRepresentation().absoluteString

        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = item.title
        attributeSet.contentDescription = item.detail

        let searchableItem = CSSearchableItem(
            uniqueIdentifier: itemID,
            domainIdentifier: projectID,
            attributeSet: attributeSet
        )

        CSSearchableIndex.default().indexSearchableItems([searchableItem])

        save()
    }

    func item(with uniqueIdentifier: String) -> Item? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Item
    }

    @discardableResult func addProject() -> Bool {
        let canCreate = fullVersionUnlocked || count(for: Project.fetchRequest()) < 3

        if canCreate {
            let project = Project(context: container.viewContext)
            project.closed = false
            project.creationDate = Date()
            save()
            return true
        } else {
            return false
        }
    }

    // MARK: Items
    func fetchRequestForTopItems(count: Int) -> NSFetchRequest<Item> {
        let itemRequest: NSFetchRequest<Item> = Item.fetchRequest()

        let completedPredicate = NSPredicate(format: "completed = false")
        let openPredicate = NSPredicate(format: "project.closed = false")
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
        itemRequest.predicate = compoundPredicate

        itemRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        ]

        itemRequest.fetchLimit = count
        return itemRequest
    }

    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }

    // MARK: - App store review alert
    func appLaunched() {
//        guard count(for: Project.fetchRequest()) >= 5 else { return }
//        let allScenes = UIApplication.shared.connectedScenes
//        let scene = allScenes.first { $0.activationState == .foregroundActive }
//
//        if let windowScene = scene as? UIWindowScene {
//            SKStoreReviewController.requestReview(in: windowScene)
//        }
    }
}
