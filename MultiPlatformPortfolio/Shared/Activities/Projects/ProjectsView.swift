//
//  ProjectsView.swift
//  ProjectsView
//
//  Created by Jordain on 03/09/2021.
//

import SwiftUI

struct ProjectsView: View {

    static let closedTag: String? = "Closed"
    static let openTag: String? = "Open"

    @State private var showingSortOrder = false

    @StateObject var viewModel: ViewModel

    var body: some View {
        NavigationView {
            Group {
                if viewModel.projects.wrappedValue.count == 0 {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    projectsList
                }
            }
            .navigationTitle(viewModel.showClosedProjects ? "Closed Projects" : "Open Projects")
            .toolbar {
                addProjectToolbarItem
                sortOrderToolbarItem
            }
            .actionSheet(isPresented: $showingSortOrder) {
                ActionSheet(title: Text("Sort items"), message: nil, buttons: [
                    .default(Text("Optimised")) {
                        viewModel.sortOrder = .optimized },
                    .default(Text("Creation Date")) {
                        viewModel.sortOrder = .creationDate },
                    .default(Text("Title")) {
                        viewModel.sortOrder = .title }
                ])
            }
            SelectSomethingView()
        }
    }

    var addProjectToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.showClosedProjects == false {
                Button(action: viewModel.addProject) {
                    // In iOS 14.3 VoiceOver has a glitch that reads the label
                    // "Add Project" as "Add" no matter what accessibility label
                    // we give this button when using a label. As a result, when
                    // VoiceOver is running we use a text view for the button instead,
                    // forcing a correct reading without losing the original layout.
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Project")
                    } else {
                        Label("add", systemImage: "plus")
                    }
                }
            }
        }
    }

    var sortOrderToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }

    var projectsList : some View {
        List {
            ForEach(viewModel.projects.wrappedValue) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    // ForEach(project.projectItems, content: ItemRowView.init)
                    ForEach(project.projectItems(using: viewModel.sortOrder)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        viewModel.delete(offsets, from: project)
                    }

                    if viewModel.showClosedProjects == false {
                        Button {
                            viewModel.addItem(to: project)
                        } label: {
                            Label("Add New Item", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    init(dataController: DataController, showClosedProjects: Bool) {
        let viewModel = ViewModel(dataController: dataController, showClosedProjects: showClosedProjects)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView(dataController: DataController.preview, showClosedProjects: false)

    }
}
