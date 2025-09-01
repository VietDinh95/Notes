//
//  NotesApp.swift
//  Notes
//
//  Created by VietDH3.AVI on 31/8/25.
//

import SwiftUI
import CoreData
import NotesKit

@main
struct NotesApp: App {
    @StateObject private var notesKitIntegration = NotesKitIntegration()
    
    init() {
        // Handle UI testing launch arguments
        if ProcessInfo.processInfo.arguments.contains("-UI_TESTS") {
            // Reset Core Data for UI tests
            if ProcessInfo.processInfo.arguments.contains("-ResetCoreData") {
                CoreDataStack.shared.reset()
            }
            
            // Disable animations for UI tests
            if ProcessInfo.processInfo.arguments.contains("-UI_TESTS_DISABLE_ANIMATIONS") {
                UIView.setAnimationsEnabled(false)
            }
            
            // Use in-memory store for UI tests
            CoreDataStack.shared.useInMemoryStore()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notesKitIntegration)
        }
    }
}
