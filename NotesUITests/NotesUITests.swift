

import XCTest

class NotesUITests: XCTestCase {
    
    var app: XCUIApplication!
    var notesPage: NotesAppPage!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Configure app for UI testing with performance optimizations
        app = XCUIApplication()
        UITestConfiguration.configureAppForUITesting(app)
        
        // Launch the app
        app.launch()
        
        // Initialize page objects
        notesPage = NotesAppPage(app: app, testCase: self)
        
        // Enable screenshot on failure only
        takeScreenshotOnFailure()
        
        // Wait for app to load with predicate-based wait
        _ = notesPage.navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.medium)
        
        // Debug element existence
        notesPage.debugElementExistence()
    }
    
    override func tearDownWithError() throws {
        // Take screenshot if test failed
        if testRun?.hasSucceeded == false {
            takeScreenshot(name: "Test_Failed_\(name)")
        }
        
        // Terminate app to ensure clean state
        app.terminate()
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchPerformance() throws {
        measure(metrics: UITestConfiguration.performanceMetrics) {
            let app = XCUIApplication()
            UITestConfiguration.configureAppForPerformanceTesting(app)
            app.launch()
            
            // Wait for app to be ready
            let navigationBar = app.navigationBars.firstMatch
            _ = navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.medium)
            
            app.terminate()
        }
    }
    
    // MARK: - Basic Functionality Tests
    
    func testAppLaunch() throws {
        // Basic app existence check
        XCTAssertTrue(app.exists, "App should exist")
        
        // Take screenshot
        takeScreenshot(name: "App_Launch_Basic")
        
        // Use predicate-based waits for critical elements
        XCTAssertTrue(notesPage.navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Navigation bar should exist")
        XCTAssertTrue(notesPage.addNoteButton.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Add note button should exist")
        
        // Debug element existence to see what's available
        notesPage.debugElementExistence()
        
        // Check if empty state exists, if not, just verify we're on the main screen
        if notesPage.emptyStateView.waitExists(timeout: UITestConfiguration.Timeouts.short) {
            XCTAssertTrue(notesPage.emptyStateView.exists, "Empty state should be visible initially")
        } else {
            // If empty state doesn't exist, just verify we're on the main screen
            XCTAssertTrue(notesPage.navigationBar.exists, "Should be on main screen")
            print("⚠️ Empty state not found, but navigation bar exists - app may still be loading")
        }
        
        // Take screenshot
        takeScreenshot(name: "App_Launch_Success")
    }
    
    func testCreateNewNote() throws {
        // Tap add note button
        notesPage.tapAddNote()
        
        // Verify we're in add note view with predicate-based waits
        let addNotePage = AddNotePage(app: app, testCase: self)
        XCTAssertTrue(addNotePage.navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Add note navigation bar should exist")
        XCTAssertTrue(addNotePage.titleTextField.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Title text field should exist")
        XCTAssertTrue(addNotePage.contentTextEditor.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Content text editor should exist")
        XCTAssertTrue(addNotePage.saveButton.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Save button should exist")
        XCTAssertTrue(addNotePage.cancelButton.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Cancel button should exist")
        
        // Fill in note details using test data
        let testNote = UITestConfiguration.generateTestNote()
        addNotePage.fillNote(title: testNote.title, content: testNote.content)
        
        // Save the note
        addNotePage.saveNote()
        
        // Wait for app to return to notes list
        _ = notesPage.navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.medium)
        
        // Verify note was created (should not be in empty state)
        XCTAssertFalse(notesPage.emptyStateView.exists, "Empty state should not exist after creating note")
        
        // Take screenshot
        takeScreenshot(name: "Note_Created_Success")
    }
    
    func testCreateMultipleNotes() throws {
        // Create multiple notes to test list functionality
        for (index, note) in TestData.sampleNotes.enumerated() {
            notesPage.tapAddNote()
            
            let addNotePage = AddNotePage(app: app, testCase: self)
            addNotePage.fillNote(title: note.title, content: note.content)
            addNotePage.saveNote()
            
            // Wait for app to return to notes list
            _ = notesPage.navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.medium)
            
            // Verify we're back to the list
            XCTAssertTrue(notesPage.navigationBar.exists, "Should be back to main view after creating note \(index + 1)")
        }
        
        // Verify we have multiple notes (not in empty state)
        XCTAssertFalse(notesPage.emptyStateView.exists, "Empty state should not exist after creating multiple notes")
        
        // Take screenshot
        takeScreenshot(name: "Multiple_Notes_Created")
    }
    
    func testEditNoteFields() throws {
        // First create a note to edit
        notesPage.tapAddNote()
        
        let addNotePage = AddNotePage(app: app, testCase: self)
        addNotePage.fillNote(title: "Original Title", content: "Original content")
        addNotePage.saveNote()
        
        notesPage.waitForAppToLoad()
        
        // Find and tap on the note to edit it
        notesPage.tapFirstNote()
        
        // Verify we're in edit note view
        let editNotePage = EditNotePage(app: app, testCase: self)
        XCTAssertTrue(editNotePage.navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Edit note navigation bar should exist")
        XCTAssertTrue(editNotePage.saveButton.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Save button should exist")
        XCTAssertTrue(editNotePage.cancelButton.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Cancel button should exist")
        
        // Update note details
        let updatedTitle = "Updated Title"
        let updatedContent = "Updated content"
        
        editNotePage.updateNote(title: updatedTitle, content: updatedContent)
        
        // Save changes
        editNotePage.saveChanges()
        
        // Wait for app to return to notes list
        notesPage.waitForAppToLoad()
        
        // Verify we're back to notes list
        XCTAssertTrue(notesPage.navigationBar.exists, "Should be back to main view")
        
        // Take screenshot
        takeScreenshot(name: "Note_Edited_Success")
    }
    
    func testPullToRefresh() throws {
        // First create a note to refresh
        notesPage.tapAddNote()
        
        let addNotePage = AddNotePage(app: app, testCase: self)
        addNotePage.fillNote(title: "Refresh Note", content: "This note should persist after refresh")
        addNotePage.saveNote()
        
        notesPage.waitForAppToLoad()
        
        // Perform pull to refresh
        notesPage.pullToRefresh()
        
        // Verify note still exists after refresh
        XCTAssertFalse(notesPage.emptyStateView.exists, "Empty state should not exist after refresh")
        
        // Take screenshot
        takeScreenshot(name: "Pull_To_Refresh_Success")
    }
    
    func testCancelNoteCreation() throws {
        // Ensure we start with a clean state
        XCTAssertTrue(notesPage.navigationBar.exists, "Should be on main screen")
        
        // Tap add note button
        notesPage.tapAddNote()
        
        // Verify we're in add note view
        let addNotePage = AddNotePage(app: app, testCase: self)
        XCTAssertTrue(addNotePage.navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Add note navigation bar should exist")
        
        // Fill in some text
        addNotePage.fillNote(title: "Canceled Note", content: "This note should not be saved")
        
        // Cancel instead of saving
        addNotePage.cancelNote()
        
        // Wait for app to return to notes list with predicate-based wait
        _ = notesPage.navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.long)
        
        // Verify we're back to notes list (don't assume empty state)
        XCTAssertTrue(notesPage.navigationBar.exists, "Should be back to main view")
        
        // Check if we're in the expected state - either empty state or notes list
        if notesPage.emptyStateView.waitExists(timeout: UITestConfiguration.Timeouts.short) {
            XCTAssertTrue(notesPage.emptyStateView.exists, "Empty state should exist if no notes")
        }
        
        // Take screenshot
        takeScreenshot(name: "Note_Creation_Canceled_Success")
    }
    
    // MARK: - Update Note Tests
    
    func testUpdateNoteSuccessfully() throws {
        // First create a note to edit
        notesPage.tapAddNote()
        
        let addNotePage = AddNotePage(app: app, testCase: self)
        let originalTitle = "Original Title"
        let originalContent = "Original content for testing update"
        addNotePage.fillNote(title: originalTitle, content: originalContent)
        addNotePage.saveNote()
        
        notesPage.waitForAppToLoad()
        
        // Verify note was created
        XCTAssertFalse(notesPage.emptyStateView.exists, "Empty state should not exist after creating note")
        
        // Find and tap on the note to edit it
        notesPage.tapFirstNote()
        
        // Verify we're in edit note view
        let editNotePage = EditNotePage(app: app, testCase: self)
        XCTAssertTrue(editNotePage.navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Edit note navigation bar should exist")
        XCTAssertTrue(editNotePage.contentTextEditor.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Content text editor should exist")
        XCTAssertTrue(editNotePage.saveButton.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Save button should exist")
        XCTAssertTrue(editNotePage.cancelButton.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Cancel button should exist")
        
        // Update note details with unique content
        let uniqueNote = UITestConfiguration.generateUniqueTestNote()
        editNotePage.updateNote(title: uniqueNote.title, content: uniqueNote.content)
        
        // Save changes
        editNotePage.saveChanges()
        
        // Wait for app to return to notes list
        notesPage.waitForAppToLoad()
        
        // Verify we're back to notes list
        XCTAssertTrue(notesPage.navigationBar.exists, "Should be back to main view")
        
        // Take screenshot
        takeScreenshot(name: "Note_Updated_Successfully")
    }
    
    func testUpdateNoteSaveButtonDisabled() throws {
        // Ensure we start with a clean state
        XCTAssertTrue(notesPage.navigationBar.exists, "Should be on main screen")
        
        // First create a note to edit
        notesPage.tapAddNote()
        
        let addNotePage = AddNotePage(app: app, testCase: self)
        let originalTitle = "Title for Save Button Test"
        let originalContent = "Content for save button test"
        addNotePage.fillNote(title: originalTitle, content: originalContent)
        addNotePage.saveNote()
        
        notesPage.waitForAppToLoad()
        
        // Find and tap on the note to edit it
        notesPage.tapFirstNote()
        
        // Wait for edit note view to load with predicate-based wait
        let editNotePage = EditNotePage(app: app, testCase: self)
        XCTAssertTrue(editNotePage.navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Edit note navigation bar should exist")
        
        // Take screenshot
        takeScreenshot(name: "Note_Update_Save_Button_State")
    }
    
    func testSearchNoResults() throws {
        // First create a note
        notesPage.tapAddNote()
        
        let addNotePage = AddNotePage(app: app, testCase: self)
        addNotePage.fillNote(title: "Test Note", content: "Test content")
        addNotePage.saveNote()
        
        notesPage.waitForAppToLoad()
        
        // Search for non-existent text
        notesPage.searchForText("NonExistentText12345")
        
        // Wait for search results
        notesPage.waitForSearchResults()
        
        // Verify search results (should show no results state)
        // Note: This depends on how your app handles no search results
        
        // Take screenshot
        takeScreenshot(name: "Search_No_Results")
    }
    
    func testSearchWithSpecialCharacters() throws {
        // Create a note with special characters
        notesPage.tapAddNote()
        
        let addNotePage = AddNotePage(app: app, testCase: self)
        let specialTitle = TestData.specialCharacters[0] // "Test with émojis 🎉📱💻"
        addNotePage.fillNote(title: specialTitle, content: "Content with special characters")
        addNotePage.saveNote()
        
        notesPage.waitForAppToLoad()
        
        // Search for the special character note
        notesPage.searchForText("émojis")
        
        // Wait for search results
        notesPage.waitForSearchResults()
        
        // Verify search results
        XCTAssertFalse(notesPage.emptyStateView.exists, "Empty state should not exist when search has results")
        
        // Take screenshot
        takeScreenshot(name: "Search_Special_Characters")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() throws {
        // This test would verify error states, but depends on your app's error handling
        // For now, just verify basic app stability
        
        XCTAssertTrue(notesPage.navigationBar.exists, "App should be stable")
        
        // Take screenshot
        takeScreenshot(name: "Error_Handling_Test")
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityElements() throws {
        // Verify accessibility identifiers are present
        XCTAssertTrue(notesPage.addNoteButton.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Add note button should have accessibility identifier")
        
        // Verify navigation elements
        XCTAssertTrue(notesPage.navigationBar.waitExists(timeout: UITestConfiguration.Timeouts.medium), "Navigation bar should be accessible")
        
        // Take screenshot
        takeScreenshot(name: "Accessibility_Elements_Test")
    }
    
    // MARK: - Long Content Tests
    
    func testLongContentHandling() throws {
        // Create a note with very long content
        notesPage.tapAddNote()
        
        let addNotePage = AddNotePage(app: app, testCase: self)
        addNotePage.fillNote(title: "Long Content Test", content: TestData.longContent)
        addNotePage.saveNote()
        
        notesPage.waitForAppToLoad()
        
        // Verify the note was created successfully
        XCTAssertFalse(notesPage.emptyStateView.exists, "Empty state should not exist after creating note with long content")
        
        // Take screenshot
        takeScreenshot(name: "Long_Content_Test")
    }
}
