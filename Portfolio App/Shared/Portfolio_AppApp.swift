//
//  Portfolio_AppApp.swift
//  Shared
//
//  Created by Jordain on 02/09/2021.
//

import SwiftUI

@main
struct Portfolio_AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
