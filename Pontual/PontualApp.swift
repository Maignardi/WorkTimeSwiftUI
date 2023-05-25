//
//  PontualApp.swift
//  Pontual
//
//  Created by matheus maignardi on 24/05/23.
//

import SwiftUI

@main
struct PontualApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
