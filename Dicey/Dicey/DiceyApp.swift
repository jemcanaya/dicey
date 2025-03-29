//
//  DiceyApp.swift
//  Dicey
//
//  Created by Jemerson Canaya on 3/29/25.
//

import SwiftUI
import SwiftData

@main
struct DiceyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Dice.self)
    }
}
