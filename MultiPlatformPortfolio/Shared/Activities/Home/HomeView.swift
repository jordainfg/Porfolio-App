//
//  HomeView.swift
//  HomeView
//
//  Created by Jordain on 03/09/2021.
//

import SwiftUI
import CoreData
import CoreSpotlight
struct HomeView: View {

    static let tag: String? = "Home"

    @EnvironmentObject var dataController: DataController

    @FetchRequest(entity: Project.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
                  predicate: NSPredicate(format: "closed = false"))
    var projects: FetchedResults<Project>

    let items: FetchRequest<Item>

    @State var selectedItem: Item?

    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }

    init() {
        // Construct a fetch request to show the 10 highest-priority, incomplete items from open projects.
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "completed = false")

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        ]
        request.fetchLimit = 10

        items = FetchRequest(fetchRequest: request)
        // more code to come
    }

    var body: some View {
        NavigationView {
            ScrollView {
                if let item = selectedItem {
                    NavigationLink(
                        destination: EditItemView(item: item),
                        tag: item,
                        selection: $selectedItem,
                        label: EmptyView.init
                    )
                    .id(item)
                }
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: items.wrappedValue.prefix(3))
                        ItemListView(title: "More to explore", items: items.wrappedValue.dropFirst(3))
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }

    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
           selectItem(with: uniqueIdentifier)
        }
    }

    func selectItem(with identifier: String) {
        selectedItem = dataController.item(with: identifier)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
