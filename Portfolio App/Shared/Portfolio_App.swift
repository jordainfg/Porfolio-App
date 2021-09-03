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
    
    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(dataController)
        }
    }
}
