

import XCTest

// MARK: - UI Test Configuration Manager

class UITestConfiguration {
    
    // MARK: - Launch Arguments
    
    static let standardLaunchArguments = [
        "-UI_TESTS",
        "-ResetCoreData",
        "-UI_TESTS_DISABLE_ANIMATIONS",
        "-disableAnimations",
        "-uiTestFastMode"
    ]
    
    static let performanceLaunchArguments = [
        "-UI_TESTS",
        "-ResetCoreData",
        "-UI_TESTS_DISABLE_ANIMATIONS",
        "-disableAnimations",
        "-uiTestFastMode",
        "-disableHaptics",
        "-disableSystemAnimations"
    ]
    
    // MARK: - Launch Environment
    
    static let standardLaunchEnvironment: [String: String] = [
        "UI_TESTING": "1",
        "DISABLE_ANIMATIONS": "1",
        "FAST_MODE": "1"
    ]
    
    // MARK: - Configuration Methods
    
    static func configureAppForUITesting(_ app: XCUIApplication, usePerformanceMode: Bool = false) {
        app.launchArguments = usePerformanceMode ? performanceLaunchArguments : standardLaunchArguments
        app.launchEnvironment = standardLaunchEnvironment
    }
    
    static func configureAppForPerformanceTesting(_ app: XCUIApplication) {
        configureAppForUITesting(app, usePerformanceMode: true)
    }
    
    // MARK: - Test Data Management
    
    static func generateTestNote() -> (title: String, content: String) {
        let timestamp = Date().timeIntervalSince1970
        return (
            title: "Test Note \(timestamp)",
            content: "This is a test note content generated at \(timestamp)"
        )
    }
    
    static func generateUniqueTestNote() -> (title: String, content: String) {
        let uuid = UUID().uuidString.prefix(8)
        let timestamp = Date().timeIntervalSince1970
        return (
            title: "Test Note \(uuid) \(timestamp)",
            content: "Unique test note content with UUID \(uuid) at \(timestamp)"
        )
    }
    
    // MARK: - Performance Metrics
    
    static let performanceMetrics: [XCTMetric] = [
        XCTCPUMetric(),
        XCTMemoryMetric(),
        XCTStorageMetric(),
        XCTClockMetric()
    ]
    
    // MARK: - Timeout Configuration
    
    struct Timeouts {
        static let short: TimeInterval = 3.0
        static let medium: TimeInterval = 5.0
        static let long: TimeInterval = 10.0
        static let veryLong: TimeInterval = 15.0
    }
    
    // MARK: - Retry Configuration
    
    struct RetryConfig {
        static let maxAttempts = 3
        static let initialDelay: TimeInterval = 0.5
        static let maxDelay: TimeInterval = 2.0
    }
}

// MARK: - Test Data Constants

struct TestData {
    
    // MARK: - Sample Notes
    
    static let sampleNotes: [(title: String, content: String)] = [
        ("Shopping List", "Milk, Bread, Eggs, Butter"),
        ("Meeting Notes", "Discuss Q4 goals, Review budget, Plan team building"),
        ("Ideas", "App feature ideas, UI improvements, Performance optimizations"),
        ("Reminders", "Call dentist, Pay bills, Schedule oil change"),
        ("Journal", "Today was productive. Completed the UI test refactoring.")
    ]
    
    // MARK: - Search Terms
    
    static let searchTerms = [
        "shopping",
        "meeting",
        "ideas",
        "reminders",
        "journal",
        "test",
        "note"
    ]
    
    static let nonExistentSearchTerms = [
        "xyz123nonexistent",
        "qwertyuiop",
        "asdfghjkl",
        "zxcvbnm"
    ]
    
    // MARK: - Long Content
    
    static let longContent = """
    This is a very long note content that should test the UI's ability to handle large amounts of text.
    It contains multiple paragraphs and should be long enough to require scrolling in the UI.
    
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
    Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
    
    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
    Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    
    Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium,
    totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
    """
    
    // MARK: - Special Characters
    
    static let specialCharacters = [
        "Test with émojis 🎉📱💻",
        "Test with numbers 12345",
        "Test with symbols !@#$%^&*()",
        "Test with spaces and   tabs",
        "Test with newlines\nand breaks",
        "Test with quotes \"Hello World\"",
        "Test with apostrophes don't won't can't"
    ]
}

// MARK: - Accessibility Identifiers

struct AccessibilityIdentifiers {
    
    // MARK: - Main App
    static let addNoteButton = "addNoteButton"
    static let searchBar = "searchBar"
    static let searchField = "searchField"
    static let clearSearchButton = "clearSearchButton"
    static let notesList = "notesList"
    static let emptyStateView = "emptyStateView"
    static let loadingView = "loadingView"
    static let errorBanner = "errorBanner"
    
    // MARK: - Add Note
    static let addNoteTitleField = "addNoteTitleField"
    static let addNoteContentField = "addNoteContentField"
    static let addNoteSaveButton = "addNoteSaveButton"
    static let addNoteCancelButton = "addNoteCancelButton"
    
    // MARK: - Edit Note
    static let editNoteTitleField = "editNoteTitleField"
    static let editNoteContentField = "editNoteContentField"
    static let editNoteSaveButton = "editNoteSaveButton"
    static let editNoteCancelButton = "editNoteCancelButton"
    
    // MARK: - Note Items
    static func noteRow(_ id: String) -> String { "noteRow_\(id)" }
    static func noteTitle(_ id: String) -> String { "noteTitle_\(id)" }
    static func noteContent(_ id: String) -> String { "noteContent_\(id)" }
    static func deleteNoteButton(_ id: String) -> String { "btnDeleteNote_\(id)" }
}
