

import XCTest

// MARK: - Enhanced XCUIElement Extensions

extension XCUIElement {
    
    // MARK: - Existence & Visibility
    
    @discardableResult
    func waitExists(timeout: TimeInterval = 4) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
    
    @discardableResult
    func waitHittable(timeout: TimeInterval = 4) -> Bool {
        let predicate = NSPredicate(format: "exists == true && hittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
    
    @discardableResult
    func waitEnabled(timeout: TimeInterval = 4) -> Bool {
        let predicate = NSPredicate(format: "exists == true && enabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
    
    @discardableResult
    func waitVisible(timeout: TimeInterval = 4) -> Bool {
        let predicate = NSPredicate(format: "exists == true && frame.size.width > 0 && frame.size.height > 0")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
    
    // MARK: - Text & Content
    
    @discardableResult
    func waitForText(_ text: String, timeout: TimeInterval = 4) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@ OR value CONTAINS %@", text, text)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
    
    @discardableResult
    func waitForTextToEqual(_ text: String, timeout: TimeInterval = 4) -> Bool {
        let predicate = NSPredicate(format: "label == %@ OR value == %@", text, text)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
    
    // MARK: - Actions with Predicate-based Waits
    
    func tapWhenHittable(timeout: TimeInterval = 4) {
        if waitHittable(timeout: timeout) {
            tap()
        } else {
            XCTFail("Element was not hittable within \(timeout) seconds")
        }
    }
    
    func typeTextWhenEnabled(_ text: String, timeout: TimeInterval = 4) {
        if waitEnabled(timeout: timeout) {
            tap()
            typeText(text)
        } else {
            XCTFail("Element was not enabled within \(timeout) seconds")
        }
    }
    
    func clearAndTypeTextWhenEnabled(_ text: String, timeout: TimeInterval = 4) {
        if waitEnabled(timeout: timeout) {
            tap()
            clearText()
            typeText(text)
        } else {
            XCTFail("Element was not enabled within \(timeout) seconds")
        }
    }
    
    // MARK: - Text Field Operations
    
    func clearText() {
        guard exists else { return }
        
        // Select all text
        doubleTap()
        
        // Delete selected text
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 100)
        typeText(deleteString)
    }
    
    func selectAllText() {
        guard exists else { return }
        doubleTap()
    }
}

// MARK: - XCUIElementQuery Extensions

extension XCUIElementQuery {
    
    @discardableResult
    func waitCount(_ expected: Int, timeout: TimeInterval = 4) -> Bool {
        let predicate = NSPredicate(format: "count == %d", expected)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
    
    @discardableResult
    func waitCountGreaterThan(_ minCount: Int, timeout: TimeInterval = 4) -> Bool {
        let predicate = NSPredicate(format: "count > %d", minCount)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
    
    @discardableResult
    func waitCountLessThan(_ maxCount: Int, timeout: TimeInterval = 4) -> Bool {
        let predicate = NSPredicate(format: "count < %d", maxCount)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
    
    @discardableResult
    func waitForElementToExist(timeout: TimeInterval = 4) -> Bool {
        let predicate = NSPredicate(format: "count > 0")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}

// MARK: - XCTestCase Extensions

extension XCTestCase {
    
    // MARK: - Screenshot Management
    
    func takeScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func takeScreenshotOnFailure() {
        addTeardownBlock { [weak self] in
            if let testCase = self, testCase.testRun?.hasSucceeded == false {
                testCase.takeScreenshot(name: "Test_Failed_\(testCase.name)")
            }
        }
    }
    
    // MARK: - App State Management
    
    func waitForAppToBeIdle(timeout: TimeInterval = 2.0) {
        // Wait for any ongoing animations or loading to complete
        let expectation = XCTestExpectation(description: "App is idle")
        
        // Use a shorter timeout for idle state
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            expectation.fulfill()
        }
        
        _ = XCTWaiter.wait(for: [expectation], timeout: timeout + 0.5)
    }
    
    // MARK: - Performance Measurement
    
    func measureAppLaunch() {
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric(), XCTStorageMetric()]) {
            let app = XCUIApplication()
            app.launchArguments = ["-UI_TESTS", "-ResetCoreData", "-UI_TESTS_DISABLE_ANIMATIONS"]
            app.launch()
            
            // Wait for app to be ready
            let navigationBar = app.navigationBars.firstMatch
            _ = navigationBar.waitExists(timeout: 5)
            
            app.terminate()
        }
    }
    
    // MARK: - Retry Logic
    
    func retryAction<T>(_ action: () -> T, maxAttempts: Int = 3, initialDelay: TimeInterval = 0.5) -> T? {
        for _ in 1...maxAttempts {
            return action()
        }
        return nil
    }
}

// MARK: - Enhanced Page Object Base Class

class BasePage {
    let app: XCUIApplication
    let testCase: XCTestCase
    
    init(app: XCUIApplication, testCase: XCTestCase) {
        self.app = app
        self.testCase = testCase
    }
    
    // MARK: - Common Wait Methods
    
    func waitForElementToExist(_ element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        return element.waitExists(timeout: timeout)
    }
    
    func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        return element.waitHittable(timeout: timeout)
    }
    
    func waitForElementToBeEnabled(_ element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        return element.waitEnabled(timeout: timeout)
    }
    
    func waitForTextToAppear(_ text: String, in element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        return element.waitForText(text, timeout: timeout)
    }
    
    // MARK: - Common Actions
    
    func tapElement(_ element: XCUIElement, timeout: TimeInterval = 10.0) {
        if element.waitHittable(timeout: timeout) {
            element.tap()
            testCase.waitForAppToBeIdle()
        } else {
            XCTFail("Element was not hittable within \(timeout) seconds")
        }
    }
    
    func typeTextInElement(_ element: XCUIElement, text: String, timeout: TimeInterval = 10.0) {
        if element.waitEnabled(timeout: timeout) {
            element.tap()
            element.clearText()
            element.typeText(text)
            testCase.waitForAppToBeIdle()
        } else {
            XCTFail("Element was not enabled within \(timeout) seconds")
        }
    }
    
    // MARK: - Debug Helpers
    
    func debugElementExistence(_ elements: [(String, XCUIElement)]) {
        print("🔍 Debug: Checking element existence...")
        for (name, element) in elements {
            print("\(name): \(element.exists ? "✅" : "❌")")
        }
    }
}

// MARK: - NotesAppPage (Enhanced)

class NotesAppPage: BasePage {
    
    // MARK: - Navigation Elements
    
    var navigationBar: XCUIElement {
        app.navigationBars.firstMatch
    }
    
    var addNoteButton: XCUIElement {
        app.buttons["addNoteButton"]
    }
    
    var searchBar: XCUIElement {
        app.otherElements["searchBar"]
    }
    
    var searchField: XCUIElement {
        app.textFields["searchField"]
    }
    
    var clearSearchButton: XCUIElement {
        app.buttons["clearSearchButton"]
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
    
    // MARK: - Actions (Enhanced with Predicate-based Waits)
    
    func tapAddNote() {
        tapElement(addNoteButton)
    }
    
    func searchForText(_ text: String) {
        if searchField.waitHittable(timeout: 4) {
            searchField.tap()
            searchField.clearText()
            searchField.typeText(text)
            testCase.waitForAppToBeIdle()
        }
    }
    
    func clearSearch() {
        if clearSearchButton.waitHittable(timeout: 4) {
            clearSearchButton.tap()
            testCase.waitForAppToBeIdle()
        }
    }
    
    func tapNote(withId noteId: String) {
        let row = noteRow(for: noteId)
        tapElement(row)
    }
    
    func tapFirstNote() {
        let firstCell = notesList.cells.firstMatch
        if firstCell.waitExists(timeout: 4) {
            tapElement(firstCell)
        } else {
            XCTFail("No note cells found to tap")
        }
    }
    
    func deleteNote(withId noteId: String) {
        let deleteButton = deleteNoteButton(for: noteId)
        if deleteButton.waitHittable(timeout: 4) {
            deleteButton.tap()
            
            if deleteAlert.waitExists(timeout: 4) {
                confirmDeleteButton.tap()
                testCase.waitForAppToBeIdle()
            }
        }
    }
    
    func pullToRefresh() {
        let list = notesList
        if list.waitExists(timeout: 4) {
            let firstCell = list.cells.firstMatch
            if firstCell.waitExists(timeout: 4) {
                let startCoordinate = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                let endCoordinate = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
                startCoordinate.press(forDuration: 0.5, thenDragTo: endCoordinate)
                testCase.waitForAppToBeIdle()
            }
        }
    }
    
    // MARK: - Wait Methods (Enhanced)
    
    func waitForAppToLoad(timeout: TimeInterval = 5.0) {
        _ = navigationBar.waitExists(timeout: timeout)
    }
    
    func waitForNoteToAppear(withId noteId: String, timeout: TimeInterval = 10.0) {
        let noteRow = self.noteRow(for: noteId)
        _ = noteRow.waitExists(timeout: timeout)
    }
    
    func waitForNoteToDisappear(withId noteId: String, timeout: TimeInterval = 10.0) {
        let noteRow = self.noteRow(for: noteId)
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: noteRow)
        _ = XCTWaiter().wait(for: [expectation], timeout: timeout)
    }
    
    func waitForLoadingToComplete(timeout: TimeInterval = 10.0) {
        let loadingView = self.loadingView
        if loadingView.exists {
            let predicate = NSPredicate(format: "exists == false")
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: loadingView)
            _ = XCTWaiter().wait(for: [expectation], timeout: timeout)
        }
    }
    
    func waitForSearchResults(timeout: TimeInterval = 5.0) {
        // Wait for search bar to be ready
        _ = searchBar.waitExists(timeout: timeout)
        
        // Wait for search results to load (either notes list or empty state)
        let expectation = XCTestExpectation(description: "Search results loaded")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        _ = XCTWaiter().wait(for: [expectation], timeout: timeout)
    }
    
    // MARK: - Debug Helpers
    
    func debugElementExistence() {
        let elements: [(String, XCUIElement)] = [
            ("📱 App", app),
            ("➕ Add Button", addNoteButton),
            ("🔍 Search Bar", searchBar),
            ("📋 Notes List", notesList),
            ("📊 Empty State", emptyStateView)
        ]
        debugElementExistence(elements)
    }
}

// MARK: - AddNotePage (Enhanced)

class AddNotePage: BasePage {
    
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
        typeTextInElement(titleTextField, text: title)
        typeTextInElement(contentTextEditor, text: content)
    }
    
    func saveNote() {
        tapElement(saveButton)
    }
    
    func cancelNote() {
        tapElement(cancelButton)
    }
}

// MARK: - EditNotePage (Enhanced)

class EditNotePage: BasePage {
    
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
        typeTextInElement(titleTextField, text: title)
        typeTextInElement(contentTextEditor, text: content)
    }
    
    func saveChanges() {
        tapElement(saveButton)
    }
    
    func cancelChanges() {
        tapElement(cancelButton)
    }
}

// MARK: - Test Data

struct TestNote {
    static let id = UUID().uuidString
    static let title = "Test Note Title"
    static let content = "This is a test note content for UI testing purposes."
}
