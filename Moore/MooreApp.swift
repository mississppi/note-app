//
//  MooreApp.swift
//  Moore
//
//  Created by KOSUKE SAKURAI on 2025/07/22.
//

import SwiftUI

@main
struct MooreApp: App {

    let persistenceController = PersistenceController.shared

    init() {
        // 画像ストレージを初期化（ディレクトリを作成）
        _ = ImageStorageManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.light)
        }
    }
}
