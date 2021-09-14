//
//  ContentView.swift
//  ContentView
//
//  Created by Jordain on 03/09/2021.
//

import SwiftUI

struct ContentView: View {

    @SceneStorage("selectedView") var selectedView: String?

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

            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        if #available(iOS 15.0, *) {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .previewInterfaceOrientation(.landscapeLeft)
        } else {
            // Fallback on earlier versions
        }

    }
}