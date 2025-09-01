

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
            if ProcessInfo.processInfo.arguments.contains("-UI_TESTS_DISABLE_ANIMATIONS") ||
               ProcessInfo.processInfo.arguments.contains("-disableAnimations") {
                UIView.setAnimationsEnabled(false)
            }
            
            // Use in-memory store for UI tests
            CoreDataStack.shared.useInMemoryStore()
            
            // Additional performance optimizations for UI tests
            if ProcessInfo.processInfo.arguments.contains("-uiTestFastMode") {
                // Disable system animations
                UIView.setAnimationsEnabled(false)
                
                // Reduce animation duration
                UIView.animate(withDuration: 0.0) {
                    // This effectively disables animations
                }
                
                // Disable haptic feedback for UI tests
                // Note: This is handled automatically by XCTest
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notesKitIntegration)
        }
    }
}
