//
//  ContentView.swift
//  ContentView
//
//  Created by Jordain on 03/09/2021.
//

import SwiftUI
import CoreSpotlight
struct ContentView: View {

    @SceneStorage("selectedView") var selectedView: String?

    @EnvironmentObject var dataController: DataController

    private let newProjectActivity = "com.featurex.MultiPlatformPortfolio"

    var body: some View {
        TabView(selection: $selectedView) {
                HomeView()
                    .tag(HomeView.tag)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }

                ProjectsView(showClosedProjects: false)
                    .tag(ProjectsView.openTag)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Open")
                    }

                ProjectsView(showClosedProjects: true)
                    .tag(ProjectsView.closedTag)
                    .tabItem {
                        Image(systemName: "checkmark")
                        Text("Closed")
                    }

                AwardsView()
                    .tag(AwardsView.tag)
                    .tabItem {
                        Image(systemName: "rosette")
                        Text("Awards")
                    }
            SharedProjectsView()
                .tag(SharedProjectsView.tag)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Community")
                }

            }.onContinueUserActivity(CSSearchableItemActionType, perform: moveToHome)
             .onOpenURL(perform: openURL)
             .userActivity(newProjectActivity) { activity in // Siri shortcuts. 
                 activity.isEligibleForPrediction = true
                 activity.title = "New Project"
             }
             .onContinueUserActivity(newProjectActivity, perform: createProject)// Siri shortcuts.

        }

    func moveToHome(_ input: Any) {
        selectedView = HomeView.tag
    }
    func openURL(_ url: URL) {
        selectedView = ProjectsView.openTag
        _ = dataController.addProject()
    }

    /// Adds a new project when the user selects add new project in Siri Shortcuts.
    func createProject(_ userActivity: NSUserActivity) {
        selectedView = ProjectsView.openTag
        dataController.addProject()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        if #available(iOS 15.0, *) {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .previewInterfaceOrientation(.portrait)
        } else {
            // Fallback on earlier versions
        }

    }
}
