//
//  Portfolio_AppApp.swift
//  Shared
//
//  Created by Jordain on 02/09/2021.
//

import SwiftUI

@main
struct Portfolio_App: App {

    @StateObject var dataController: DataController
    @Environment(\.scenePhase) var scenePhase

    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(dataController)
        }.onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .background:
                dataController.save()
            case .inactive:
                print("App State : Inactive")
            case .active:
                print("App State : Active")
            @unknown default:
                print("App State : Unknown")
            }
        }
    }
}
