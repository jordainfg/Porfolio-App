//  EditProjectView.swift
//  EditProjectView
//
//  Created by Jordain on 06/09/2021.
//

// swiftlint:disable all

import SwiftUI
import CloudKit
struct EditProjectView: View {

    enum CloudStatus {
        case checking, exists, absent
    }
    
    @ObservedObject var project: Project

    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var dataController: DataController

    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var showingDeleteConfirm = false
    @State private var showingNotificationsError = false

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    @State private var remindMeToggle: Bool
    @State private var reminderTime: Date

    @AppStorage("username") var username: String?
    @State private var showingSignIn = false

    @State private var cloudStatus = CloudStatus.checking

    @State private var cloudError: CloudError?

    init(project: Project) {
        self.project = project
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)

        // if we have a reminder time set for this project, the local reminderTime
        // state property should be set to that time, and remindMe should be true.
        if let projectReminderTime = project.reminderTime {
            _reminderTime = State(wrappedValue: projectReminderTime)
            _remindMeToggle = State(wrappedValue: true)
        } else { // Otherwise we should set reminderTime to the current date, and remindMe to false.
            _reminderTime = State(wrappedValue: Date())
            _remindMeToggle = State(wrappedValue: false)
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Project name", text: $title.onChange(update))
                TextField("Description of this project", text: $detail.onChange(update))
            }
            Section(header: Text("Custom project color")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Project.colors, id: \.self, content: colorButton)
                }
                .padding(.vertical)
            }

            // swiftlint:disable:next line_length
            Section(footer: Text("Closing a project moves it from the Open to Closed tab; deleting it removes the project completely.")) {
                Button(project.closed ? "Reopen this project" : "Close this project") {
                    project.closed.toggle()
                    update()
                    if project.closed {
                        HapticEngine.shared.generator.notificationOccurred(.success)
                    }
                }

                Button("Delete this project") {
                    showingDeleteConfirm.toggle()
                }
                .alert(isPresented: $showingDeleteConfirm) {
                    Alert(
                        title: Text("Delete project?"),
                        message: Text("Are you sure you want to delete this project? You will also delete all the items it contains."),
                        primaryButton: .default(Text("Delete"), action: delete),
                        secondaryButton: .cancel())
                }
                .accentColor(.red)
            }
            Section(header: Text("Project reminders")) {
                Toggle("Show reminders", isOn: $remindMeToggle.animation().onChange(update))

                if remindMeToggle {
                    DatePicker(
                        "Reminder time",
                        selection: $reminderTime.onChange(update),
                        displayedComponents: .hourAndMinute
                    )
                }
            }
        }
        .navigationTitle("Edit Project")
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $showingNotificationsError) {
            Alert(
                title: Text("Oops!"),
                message: Text("There was a problem. Please check you have notifications enabled."),
                primaryButton: .default(Text("Check Settings"), action: showAppSettings),
                secondaryButton: .cancel()
            )
        }
        .alert(item: $cloudError) { error in
            Alert(
                title: Text("There was an error"),
                message: Text(error.message)
            )
        }
        .sheet(isPresented: $showingSignIn, content: SignInView.init)
        .toolbar {
            switch cloudStatus {
            case .checking:
                ProgressView()
            case .exists:
                Button(action: removeFromCloud) {
                    Label("Remove from iCloud", systemImage: "icloud.slash")
                }
            case .absent:
                Button(action: uploadToCloud) {
                    Label("Upload to iCloud", systemImage: "icloud.and.arrow.up")
                }
            }
        }
        .onAppear(perform: updateUItoCloudStatus)
    }

    func uploadToCloud(){
        if let username = username {
            let records = project.prepareCloudRecords(username: username)
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.savePolicy = .allKeys

            operation.modifyRecordsCompletionBlock = { _, _, error in
                if let error = error {
                        cloudError = error.getCloudKitError()
                    }

                updateUItoCloudStatus()
            }

            cloudStatus = .checking

            CKContainer.default().publicCloudDatabase.add(operation)
        } else {
            showingSignIn = true
        }

    }

    func updateUItoCloudStatus() {
        project.checkCloudStatus { exists in
            if exists {
                cloudStatus = .exists
            } else {
                cloudStatus = .absent
            }
        }
    }

    func removeFromCloud() {
        let name = project.objectID.uriRepresentation().absoluteString
        let id = CKRecord.ID(recordName: name)

        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [id])

        operation.modifyRecordsCompletionBlock = { _, _, _ in
            updateUItoCloudStatus()
        }

        cloudStatus = .checking
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    /// Opens the Settings of the iOS Device, and displays to notification settings.
    func showAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }


    func update() {
        project.title = title
        project.detail = detail
        project.color = color

        if remindMeToggle {
            project.reminderTime = reminderTime
        } else {
            project.reminderTime = nil
        }

        // reminders
        if remindMeToggle {
            project.reminderTime = reminderTime

            dataController.addReminders(for: project) { success in
                if success == false {
                    project.reminderTime = nil
                    remindMeToggle = false

                    showingNotificationsError = true
                }
            }
        } else {
            project.reminderTime = nil
            dataController.removeReminders(for: project)
        }
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

// By adding a custom initializer we need to adjust the preview provider for our view.
// Again, this isn???t hard because we already defined a static example project we can use:
struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)
    }
}
