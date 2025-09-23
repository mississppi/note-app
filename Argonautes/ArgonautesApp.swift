//
//  ArgonautesApp.swift
//  Argonautes
//
//  Created by KOSUKE SAKURAI on 2025/07/22.
//

import SwiftUI

@main
struct ArgonautesApp: App {

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
