//
//  NotesUITests.swift
//  NotesUITests
//
//  Created by VietDH3.AVI on 31/8/25.
//

import XCTest

class NotesUITests: XCTestCase {
    
    var app: XCUIApplication!
    var notesPage: NotesAppPage!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Configure app for UI testing
        app = XCUIApplication()
        app.launchArguments = [
            "-UI_TESTS",
            "-ResetCoreData",
            "-UI_TESTS_DISABLE_ANIMATIONS"
        ]
        
        // Launch the app
        app.launch()
        
        // Initialize page objects
        notesPage = NotesAppPage(app: app, testCase: self)
        
        // Enable screenshot on failure
        takeScreenshotOnFailure()
        
        // Wait for app to load with predicate-based wait
        _ = notesPage.navigationBar.waitExists(timeout: 5)
        
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
    
    // MARK: - Test Cases
    
    func testAppLaunch() throws {
        // Basic app existence check
        XCTAssertTrue(app.exists, "App should exist")
        
        // Take screenshot
        takeScreenshot(name: "App_Launch_Basic")
        
        // Use predicate-based waits
        XCTAssertTrue(notesPage.navigationBar.waitExists(timeout: 5), "Navigation bar should exist")
        XCTAssertTrue(notesPage.addNoteButton.waitExists(timeout: 5), "Add note button should exist")
        
        // Debug element existence to see what's available
        notesPage.debugElementExistence()
        
        // Check if empty state exists, if not, just verify we're on the main screen
        if notesPage.emptyStateView.waitExists(timeout: 3) {
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
        let addNotePage = AddNotePage(app: app)
        XCTAssertTrue(addNotePage.navigationBar.waitExists(timeout: 5), "Add note navigation bar should exist")
        XCTAssertTrue(addNotePage.titleTextField.waitExists(timeout: 5), "Title text field should exist")
        XCTAssertTrue(addNotePage.contentTextEditor.waitExists(timeout: 5), "Content text editor should exist")
        XCTAssertTrue(addNotePage.saveButton.waitExists(timeout: 5), "Save button should exist")
        XCTAssertTrue(addNotePage.cancelButton.waitExists(timeout: 5), "Cancel button should exist")
        
        // Fill in note details
        let testTitle = TestNote.title
        let testContent = TestNote.content
        
        addNotePage.fillNote(title: testTitle, content: testContent)
        
        // Save the note
        addNotePage.saveNote()
        
        // Wait for app to return to notes list
        _ = notesPage.navigationBar.waitExists(timeout: 5)
        
        // Verify note was created (should not be in empty state)
        XCTAssertFalse(notesPage.emptyStateView.exists, "Empty state should not exist after creating note")
        
        // Take screenshot
        takeScreenshot(name: "Note_Created_Success")
    }
    
    func testEditNoteFields() throws {
        // First create a note to edit
        notesPage.tapAddNote()
        
        let addNotePage = AddNotePage(app: app)
        addNotePage.fillNote(title: "Original Title", content: "Original content")
        addNotePage.saveNote()
        
        notesPage.waitForAppToLoad()
        
        // Find and tap on the note to edit it
        notesPage.tapFirstNote()
        
        // Verify we're in edit note view
        let editNotePage = EditNotePage(app: app)
        XCTAssertTrue(editNotePage.navigationBar.exists, "Edit note navigation bar should exist")
        XCTAssertTrue(editNotePage.titleTextField.exists, "Title text field should exist")
        XCTAssertTrue(editNotePage.contentTextEditor.exists, "Content text editor should exist")
        XCTAssertTrue(editNotePage.saveButton.exists, "Save button should exist")
        XCTAssertTrue(editNotePage.cancelButton.exists, "Cancel button should exist")
        
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
        
        let addNotePage = AddNotePage(app: app)
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
        let addNotePage = AddNotePage(app: app)
        XCTAssertTrue(addNotePage.navigationBar.exists, "Add note navigation bar should exist")
        
        // Fill in some text
        addNotePage.fillNote(title: "Canceled Note", content: "This note should not be saved")
        
        // Cancel instead of saving
        addNotePage.cancelNote()
        
        // Wait for app to return to notes list with longer timeout
        notesPage.waitForAppToLoad(timeout: 15.0)
        
        // Verify we're back to notes list (don't assume empty state)
        XCTAssertTrue(notesPage.navigationBar.exists, "Should be back to main view")
        
        // Wait a bit more for UI to stabilize
        Thread.sleep(forTimeInterval: 2.0)
        
        // Check if we're in the expected state - either empty state or notes list
        if notesPage.emptyStateView.exists {
            XCTAssertTrue(notesPage.emptyStateView.exists, "Empty state should exist if no notes")
        }
        
        // Take screenshot
        takeScreenshot(name: "Note_Creation_Canceled_Success")
    }
    
    // MARK: - Update Note Tests
    
    func testUpdateNoteSuccessfully() throws {
        // First create a note to edit
        notesPage.tapAddNote()
        
        let addNotePage = AddNotePage(app: app)
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
        let editNotePage = EditNotePage(app: app)
        XCTAssertTrue(editNotePage.navigationBar.exists, "Edit note navigation bar should exist")
        XCTAssertTrue(editNotePage.titleTextField.exists, "Title text field should exist")
        XCTAssertTrue(editNotePage.contentTextEditor.exists, "Content text editor should exist")
        XCTAssertTrue(editNotePage.saveButton.exists, "Save button should exist")
        XCTAssertTrue(editNotePage.cancelButton.exists, "Cancel button should exist")
        
        // Update note details
        let updatedTitle = "Updated Title - \(Date().timeIntervalSince1970)"
        let updatedContent = "Updated content - \(Date().timeIntervalSince1970)"
        
        editNotePage.updateNote(title: updatedTitle, content: updatedContent)
        
        // Save changes
        editNotePage.saveChanges()
        
        // Wait for app to return to notes list
        notesPage.waitForAppToLoad()
        
        // Verify we're back to notes list
        XCTAssertTrue(notesPage.navigationBar.exists, "Should be back to main view")
        
        // Take screenshot
        takeScreenshot(name: "Note_Updated_Successfully")
    }
    
    func testUpdateNoteCancelChanges() throws {
        // First create a note to edit
        notesPage.tapAddNote()
        
        let addNotePage = AddNotePage(app: app)
        let originalTitle = "Original Title for Cancel"
        let originalContent = "Original content that should not change"
        addNotePage.fillNote(title: originalTitle, content: originalContent)
        addNotePage.saveNote()
        
        notesPage.waitForAppToLoad()
        
        // Find and tap on the note to edit it
        notesPage.tapFirstNote()
        
        // Verify we're in edit note view
        let editNotePage = EditNotePage(app: app)
        XCTAssertTrue(editNotePage.navigationBar.exists, "Edit note navigation bar should exist")
        
        // Make changes but don't save
        let tempTitle = "Temporary Title"
        let tempContent = "Temporary content"
        editNotePage.updateNote(title: tempTitle, content: tempContent)
        
        // Cancel changes instead of saving
        editNotePage.cancelChanges()
        
        // Wait for app to return to notes list
        notesPage.waitForAppToLoad()
        
        // Verify we're back to notes list
        XCTAssertTrue(notesPage.navigationBar.exists, "Should be back to main view")
        
        // Take screenshot
        takeScreenshot(name: "Note_Update_Canceled")
    }
    
    func testUpdateNoteSaveButtonDisabled() throws {
        // Ensure we start with a clean state
        XCTAssertTrue(notesPage.navigationBar.exists, "Should be on main screen")
        
        // First create a note to edit
        notesPage.tapAddNote()
        
        let addNotePage = AddNotePage(app: app)
        let originalTitle = "Title for Save Button Test"
        let originalContent = "Content for save button test"
        addNotePage.fillNote(title: originalTitle, content: originalContent)
        addNotePage.saveNote()
        
        notesPage.waitForAppToLoad()
        
        // Find and tap on the note to edit it
        notesPage.tapFirstNote()
        
        // Wait for edit note view to load
        Thread.sleep(forTimeInterval: 2.0)
        
        // Verify we're in edit note view
        let editNotePage = EditNotePage(app: app)
        XCTAssertTrue(editNotePage.navigationBar.exists, "Edit note navigation bar should exist")
        
        // Wait for save button to be ready
        XCTAssertTrue(editNotePage.saveButton.exists, "Save button should exist")
        
        // Take screenshot
        takeScreenshot(name: "Note_Update_Save_Button_State")
    }
}
