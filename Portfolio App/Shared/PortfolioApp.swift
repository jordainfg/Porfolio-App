//
//  Portfolio_AppApp.swift
//  Shared
//
//  Created by Jordain on 02/09/2021.
//

import SwiftUI

@main // swiftlint:disable: next line_length
struct PortfolioApp: App {
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
                    .onReceive(
                        // Automatically save when we detect that we are
                        // no longer the foreground app. Use this rather than
                        // scene phase so we can port to macOS, where scene
                        // phase won't detect our app losing focus.
                        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                        perform: save
            )
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .background:
                // Why not use `save` here instead of `NotificationCenter`?.
                // Well, we're planning ahead: SwiftUI’s scene phase API doesn’t
                // distinguish between an app that is currently selected and receiving
                // user input and one that is not – both are considered “active”
                // (multi windows apps on macOS or iPadOS.
                print("App State : Background")
            case .inactive:
                print("App State : Inactive")
            case .active:
                print("App State : Active")
            @unknown default:
                print("App State : Unknown")
            }
        }
    }
    func save(_ note: Notification) {
        dataController.save()
    }
}
