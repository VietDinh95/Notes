//
//  UITestHelpers.swift
//  NotesUITests
//
//  Created by Senior iOS Engineer on 31/8/25.
//

import XCTest

// MARK: - Predicate-based Wait Helpers
extension XCUIElement {
    @discardableResult
    func waitExists(timeout: TimeInterval = 4) -> Bool {
        let p = NSPredicate(format: "exists == true")
        let e = XCTNSPredicateExpectation(predicate: p, object: self)
        return XCTWaiter().wait(for: [e], timeout: timeout) == .completed
    }
    
    @discardableResult
    func waitHittable(timeout: TimeInterval = 4) -> Bool {
        let p = NSPredicate(format: "exists == true && hittable == true")
        let e = XCTNSPredicateExpectation(predicate: p, object: self)
        return XCTWaiter().wait(for: [e], timeout: timeout) == .completed
    }
    
    @discardableResult
    func waitEnabled(timeout: TimeInterval = 4) -> Bool {
        let p = NSPredicate(format: "exists == true && enabled == true")
        let e = XCTNSPredicateExpectation(predicate: p, object: self)
        return XCTWaiter().wait(for: [e], timeout: timeout) == .completed
    }
    
    @discardableResult
    func waitForText(_ text: String, timeout: TimeInterval = 4) -> Bool {
        let p = NSPredicate(format: "label CONTAINS %@", text)
        let e = XCTNSPredicateExpectation(predicate: p, object: self)
        return XCTWaiter().wait(for: [e], timeout: timeout) == .completed
    }
}

extension XCUIElementQuery {
    func waitCount(_ expected: Int, timeout: TimeInterval = 4) -> Bool {
        let p = NSPredicate(format: "count == %d", expected)
        let e = XCTNSPredicateExpectation(predicate: p, object: self)
        return XCTWaiter().wait(for: [e], timeout: timeout) == .completed
    }
    
    func waitCountGreaterThan(_ minCount: Int, timeout: TimeInterval = 4) -> Bool {
        let p = NSPredicate(format: "count > %d", minCount)
        let e = XCTNSPredicateExpectation(predicate: p, object: self)
        return XCTWaiter().wait(for: [e], timeout: timeout) == .completed
    }
}

// MARK: - XCTestCase Extensions

extension XCTestCase {
    
    /// Wait for an element to exist with timeout
    func waitForElementToExist(_ element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        let expectation = XCTestExpectation(description: "Element exists")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if element.exists {
                expectation.fulfill()
            }
        }
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Wait for an element to not exist with timeout
    func waitForElementToNotExist(_ element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        let expectation = XCTestExpectation(description: "Element does not exist")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !element.exists {
                expectation.fulfill()
            }
        }
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Wait for an element to be hittable with timeout
    func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        let expectation = XCTestExpectation(description: "Element is hittable")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if element.isHittable {
                expectation.fulfill()
            }
        }
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Wait for text to appear with timeout
    func waitForTextToAppear(_ text: String, in app: XCUIApplication, timeout: TimeInterval = 10.0) -> Bool {
        let expectation = XCTestExpectation(description: "Text appears: \(text)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if app.staticTexts[text].exists {
                expectation.fulfill()
            }
        }
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Wait for app to be idle (no animations or loading)
    func waitForAppToBeIdle(timeout: TimeInterval = 5.0) {
        let expectation = XCTestExpectation(description: "App is idle")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            expectation.fulfill()
        }
        
        _ = XCTWaiter.wait(for: [expectation], timeout: timeout + 1.0)
    }
    
    /// Retry an action with exponential backoff
    func retryAction<A>(_ action: () -> A, maxAttempts: Int = 3, initialDelay: TimeInterval = 0.5) -> A? {
        var lastError: Error?
        var delay = initialDelay
        
        for attempt in 1...maxAttempts {
            do {
                return action()
            } catch {
                lastError = error
                if attempt < maxAttempts {
                    Thread.sleep(forTimeInterval: delay)
                    delay *= 2
                }
            }
        }
        
        print("❌ Action failed after \(maxAttempts) attempts. Last error: \(String(describing: lastError))")
        return nil
    }
    
    /// Take a screenshot with a descriptive name
    func takeScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /// Take a screenshot when test fails
    func takeScreenshotOnFailure() {
        addTeardownBlock { [weak self] in
            if let testCase = self, testCase.testRun?.hasSucceeded == false {
                testCase.takeScreenshot(name: "Test_Failed_\(testCase.name)")
            }
        }
    }
}

// MARK: - NotesAppPage

class NotesAppPage {
    let app: XCUIApplication
    let testCase: XCTestCase
    
    init(app: XCUIApplication, testCase: XCTestCase) {
        self.app = app
        self.testCase = testCase
    }
    
    // MARK: - Navigation Elements
    
    var navigationBar: XCUIElement {
        app.navigationBars.firstMatch
    }
    
    var addNoteButton: XCUIElement {
        app.buttons["addNoteButton"]
    }
    
    var searchBar: XCUIElement {
        app.searchFields["searchBar"]
    }
    
    var searchField: XCUIElement {
        app.searchFields["searchField"]
    }
    
    var clearSearchButton: XCUIElement {
        app.buttons["clearSearchButton"]
    }
    
    // MARK: - Debug Helpers
    
    func debugElementExistence() {
        print("🔍 Debug: Checking element existence...")
        print("📱 App: \(app.exists ? "✅" : "❌")")
        print("➕ Add Button: \(addNoteButton.exists ? "✅" : "❌")")
        print("🔍 Search Bar: \(searchBar.exists ? "✅" : "❌")")
        print("📋 Notes List: \(notesList.exists ? "✅" : "❌")")
        print("📊 Empty State: \(emptyStateView.exists ? "✅" : "❌")")
    }
    
    // MARK: - List Elements
    
    var notesList: XCUIElement {
        // Try different ways to find the notes list
        let collectionView = app.collectionViews["notesList"]
        let table = app.tables["notesList"]
        
        if collectionView.exists {
            return collectionView
        } else if table.exists {
            return table
        } else {
            return app.otherElements["notesList"]
        }
    }
    
    var loadingView: XCUIElement {
        app.otherElements["loadingView"]
    }
    
    var loadingIndicator: XCUIElement {
        app.activityIndicators["loadingIndicator"]
    }
    
    var emptyStateView: XCUIElement {
        app.otherElements["emptyStateView"]
    }
    
    var emptyStateTitle: XCUIElement {
        app.staticTexts["emptyStateTitle"]
    }
    
    var createFirstNoteButton: XCUIElement {
        app.buttons["createFirstNoteButton"]
    }
    
    var errorBanner: XCUIElement {
        app.otherElements["errorBanner"]
    }
    
    var dismissErrorButton: XCUIElement {
        app.buttons["dismissErrorButton"]
    }
    
    // MARK: - Note Row Elements
    
    func noteRow(for noteId: String) -> XCUIElement {
        app.otherElements["noteRow_\(noteId)"]
    }
    
    func noteTitle(for noteId: String) -> XCUIElement {
        app.staticTexts["noteTitle_\(noteId)"]
    }
    
    func noteContent(for noteId: String) -> XCUIElement {
        app.staticTexts["noteContent_\(noteId)"]
    }
    
    func deleteNoteButton(for noteId: String) -> XCUIElement {
        app.buttons["btnDeleteNote_\(noteId)"]
    }
    
    // MARK: - Delete Alert Elements
    
    var deleteAlert: XCUIElement {
        app.alerts["Delete Note"]
    }
    
    var confirmDeleteButton: XCUIElement {
        deleteAlert.buttons["Delete"]
    }
    
    var cancelDeleteButton: XCUIElement {
        deleteAlert.buttons["Cancel"]
    }
    
    // MARK: - Actions
    
    func tapAddNote() {
        addNoteButton.tap()
        testCase.waitForAppToBeIdle()
    }
    
    func searchForText(_ text: String) {
        searchField.tap()
        searchField.typeText(text)
        testCase.waitForAppToBeIdle()
    }
    
    func clearSearch() {
        if clearSearchButton.exists {
            clearSearchButton.tap()
            testCase.waitForAppToBeIdle()
        }
    }
    
    func tapNote(withId noteId: String) {
        let row = noteRow(for: noteId)
        if row.exists {
            row.tap()
            testCase.waitForAppToBeIdle()
        }
    }
    
    func tapFirstNote() {
        let firstCell = notesList.cells.firstMatch
        if firstCell.waitExists(timeout: 4) {
            firstCell.tap()
            testCase.waitForAppToBeIdle()
        }
    }
    
    func deleteNote(withId noteId: String) {
        let deleteButton = deleteNoteButton(for: noteId)
        if deleteButton.exists {
            deleteButton.tap()
            
            if deleteAlert.exists {
                confirmDeleteButton.tap()
                testCase.waitForAppToBeIdle()
            }
        }
    }
    
    func pullToRefresh() {
        let list = notesList
        if list.exists {
            let firstCell = list.cells.firstMatch
            if firstCell.exists {
                let startCoordinate = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                let endCoordinate = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
                startCoordinate.press(forDuration: 0.5, thenDragTo: endCoordinate)
                testCase.waitForAppToBeIdle()
            }
        }
    }
    
    // MARK: - Wait Methods
    
    func waitForAppToLoad(timeout: TimeInterval = 5.0) {
        // Use predicate-based wait for navigation bar
        _ = navigationBar.waitExists(timeout: timeout)
    }
    
    func waitForNoteToAppear(withId noteId: String, timeout: TimeInterval = 10.0) {
        let noteRow = self.noteRow(for: noteId)
        _ = testCase.waitForElementToExist(noteRow, timeout: timeout)
    }
    
    func waitForNoteToDisappear(withId noteId: String, timeout: TimeInterval = 10.0) {
        let noteRow = self.noteRow(for: noteId)
        _ = testCase.waitForElementToNotExist(noteRow, timeout: timeout)
    }
    
    func waitForLoadingToComplete(timeout: TimeInterval = 10.0) {
        let loadingView = self.loadingView
        if loadingView.exists {
            _ = testCase.waitForElementToNotExist(loadingView, timeout: timeout)
        }
    }
    
    func waitForSearchResults(timeout: TimeInterval = 5.0) {
        // Wait for search bar to be ready
        _ = searchBar.waitExists(timeout: timeout)
    }
    
    func waitForAppToBeIdle(timeout: TimeInterval = 5.0) {
        testCase.waitForAppToBeIdle(timeout: timeout)
    }
    
    // MARK: - Specific Wait Helpers
    
    func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        return testCase.waitForElementToBeHittable(element, timeout: timeout)
    }
    
    func waitForElementToExist(_ element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        return testCase.waitForElementToExist(element, timeout: timeout)
    }
    
    func waitForElementToNotExist(_ element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        return testCase.waitForElementToNotExist(element, timeout: timeout)
    }
    
    func waitForTextToAppear(_ text: String, timeout: TimeInterval = 10.0) -> Bool {
        return testCase.waitForTextToAppear(text, in: app, timeout: timeout)
    }
}

// MARK: - AddNotePage

class AddNotePage {
    let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var navigationBar: XCUIElement {
        app.navigationBars.firstMatch
    }
    
    var titleTextField: XCUIElement {
        app.textFields["addNoteTitleField"]
    }
    
    var contentTextEditor: XCUIElement {
        app.textViews["addNoteContentField"]
    }
    
    var saveButton: XCUIElement {
        app.buttons["addNoteSaveButton"]
    }
    
    var cancelButton: XCUIElement {
        app.buttons["addNoteCancelButton"]
    }
    
    func fillNote(title: String, content: String) {
        // Use predicate-based waits
        _ = titleTextField.waitHittable(timeout: 4)
        titleTextField.tap()
        titleTextField.clearAndTypeText(title)
        
        _ = contentTextEditor.waitHittable(timeout: 4)
        contentTextEditor.tap()
        contentTextEditor.clearAndTypeText(content)
    }
    
    func saveNote() {
        _ = saveButton.waitHittable(timeout: 4)
        saveButton.tap()
    }
    
    func cancelNote() {
        _ = cancelButton.waitHittable(timeout: 4)
        cancelButton.tap()
    }
    
    // MARK: - Wait Helpers
    
    private func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        let expectation = XCTestExpectation(description: "Element is hittable")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if element.isHittable {
                expectation.fulfill()
            }
        }
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}

// MARK: - EditNotePage

class EditNotePage {
    let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var navigationBar: XCUIElement {
        app.navigationBars.firstMatch
    }
    
    var titleTextField: XCUIElement {
        app.textFields["editNoteTitleField"]
    }
    
    var contentTextEditor: XCUIElement {
        app.textViews["editNoteContentField"]
    }
    
    var saveButton: XCUIElement {
        app.buttons["editNoteSaveButton"]
    }
    
    var cancelButton: XCUIElement {
        app.buttons["editNoteCancelButton"]
    }
    
    func updateNote(title: String, content: String) {
        // Use predicate-based waits
        _ = titleTextField.waitHittable(timeout: 4)
        titleTextField.tap()
        titleTextField.clearAndTypeText(title)
        
        _ = contentTextEditor.waitHittable(timeout: 4)
        contentTextEditor.tap()
        contentTextEditor.clearAndTypeText(content)
    }
    
    func saveChanges() {
        _ = saveButton.waitHittable(timeout: 4)
        saveButton.tap()
    }
    
    func cancelChanges() {
        _ = cancelButton.waitHittable(timeout: 4)
        cancelButton.tap()
    }
    
    // MARK: - Wait Helpers
    
    private func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        let expectation = XCTestExpectation(description: "Element is hittable")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if element.isHittable {
                expectation.fulfill()
            }
        }
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}

// MARK: - Test Data

struct TestNote {
    static let id = UUID().uuidString
    static let title = "Test Note Title"
    static let content = "This is a test note content for UI testing purposes."
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    
    /// Clear text field and type new text
    func clearAndTypeText(_ text: String) {
        guard self.exists else { return }
        
        // Clear existing text
        self.doubleTap()
        self.press(forDuration: 0.5)
        
        // Type new text
        self.typeText(text)
    }
}
