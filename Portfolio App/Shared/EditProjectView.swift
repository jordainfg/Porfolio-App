//
//  EditProjectView.swift
//  EditProjectView
//
//  Created by Jordain on 06/09/2021.
//

import SwiftUI

struct EditProjectView: View {
    let project: Project

    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var dataController: DataController

    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var showingDeleteConfirm = false
    
    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]
    
    init(project: Project) {
        self.project = project
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Project name", text: $title)
                TextField("Description of this project", text: $detail)
            }
            Section(header: Text("Custom project color")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Project.colors, id: \.self, content: colorButton)
                }
                .padding(.vertical)
            }
            Section(footer: Text("Closing a project moves it from the Open to Closed tab; deleting it removes the project completely.")) {
                Button(project.closed ? "Reopen this project" : "Close this project") {
                    project.closed.toggle()
                    update()
                }

                Button("Delete this project") {
                    showingDeleteConfirm.toggle()
                }
                .alert(isPresented: $showingDeleteConfirm) {
                    Alert(title: Text("Delete project?"), message: Text("Are you sure you want to delete this project? You will also delete all the items it contains."), primaryButton: .default(Text("Delete"), action: delete), secondaryButton: .cancel())
                }
                .accentColor(.red)
            }
        }
        .navigationTitle("Edit Project")
        .onDisappear(perform: dataController.save)
    }
    
    func update() {
        project.title = title
        project.detail = detail
        project.color = color
    }
    
    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }
    
    func colorButton(for item: String) -> some View {
        ZStack {
            Color(color)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)
            
            if color == self.color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            self.color = color
            update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            color == self.color ? [.isButton, .isSelected] : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(color))
    }
}

// By adding a custom initializer we need to adjust the preview provider for our view. Again, this isn’t hard because we already defined a static example project we can use:
struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)
    }
}

