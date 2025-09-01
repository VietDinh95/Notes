import XCTest
import Combine
@testable import Notes
@testable import NotesKit

@MainActor
final class NotesViewModelTests: XCTestCase {
    var viewModel: NotesViewModel!
    var mockRepository: MockNoteRepository!
    fileprivate var mockNotesKitIntegration: MockNotesKitIntegration!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockNoteRepository()
        mockNotesKitIntegration = MockNotesKitIntegration(repository: mockRepository)
        viewModel = NotesViewModel(notesKitIntegration: mockNotesKitIntegration)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        mockNotesKitIntegration = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func resetMockState() {
        mockRepository.resetMockState()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(viewModel.notes.count, 0)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Load Notes Tests
    
    func testLoadNotesSuccess() {
        resetMockState()
        let expectation = XCTestExpectation(description: "Load notes success")
        let testNotes = [
            NoteModel(title: "Test Note 1", content: "Content 1"),
            NoteModel(title: "Test Note 2", content: "Content 2")
        ]
        
        // Setup mock to return test notes
        mockRepository.notesToReturn = testNotes
        
        // Observe notes changes
        viewModel.$notes
            .dropFirst() // Skip initial empty state
            .sink { notes in
                XCTAssertEqual(notes.count, 2)
                XCTAssertEqual(notes[0].title, "Test Note 1")
                XCTAssertEqual(notes[1].title, "Test Note 2")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.loadNotes()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadNotesFailure() {
        resetMockState()
        let expectation = XCTestExpectation(description: "Load notes failure")
        let testError = RepositoryError.fetchFailed(NSError(domain: "Test", code: 500, userInfo: nil))
        
        // Setup mock to return error
        mockRepository.errorToReturn = testError
        
        // Observe error message changes
        viewModel.$errorMessage
            .sink { errorMessage in
                if errorMessage != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.loadNotes()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Search Tests
    
    func testSearchNotesSuccess() {
        resetMockState()
        let testNotes = [
            NoteModel(title: "Swift Programming", content: "Learn Swift"),
            NoteModel(title: "iOS Development", content: "Build apps")
        ]
        
        // Setup mock to return test notes
        mockRepository.notesToReturn = testNotes
        
        let expectation = XCTestExpectation(description: "Search notes success")
        
        // Observe notes changes
        viewModel.$notes
            .dropFirst() // Skip initial empty state
            .sink { _ in
                // Test search functionality
                self.viewModel.searchText = "Swift"
                
                // Check if search state is correct
                XCTAssertEqual(self.viewModel.filteredNotes.count, 1)
                XCTAssertEqual(self.viewModel.filteredNotes.first?.title, "Swift Programming")
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Load notes
        viewModel.loadNotes()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchNotesEmptyQuery() {
        resetMockState()
        let testNotes = [
            NoteModel(title: "Note 1", content: "Content 1"),
            NoteModel(title: "Note 2", content: "Content 2")
        ]
        
        // Setup mock to return test notes
        mockRepository.notesToReturn = testNotes
        
        let expectation = XCTestExpectation(description: "Search notes empty query")
        
        // Observe notes changes
        viewModel.$notes
            .dropFirst() // Skip initial empty state
            .sink { _ in
                // Test empty search
                self.viewModel.searchText = ""
                
                // Check if search state is correct
                XCTAssertEqual(self.viewModel.filteredNotes.count, 2)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Load notes
        viewModel.loadNotes()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchNotesFailure() {
        resetMockState()
        let expectation = XCTestExpectation(description: "Search notes failure")
        let testError = RepositoryError.fetchFailed(NSError(domain: "Test", code: 500, userInfo: nil))
        
        // Setup mock to return error
        mockRepository.errorToReturn = testError
        
        // Observe error message changes
        viewModel.$errorMessage
            .sink { errorMessage in
                if errorMessage != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Try to load notes which should fail
        viewModel.loadNotes()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Create Note Tests
    
    func testCreateNoteSuccess() {
        resetMockState()
        let expectation = XCTestExpectation(description: "Create note success")
        let newNote = NoteModel(title: "New Note", content: "New content")
        
        // Setup mock to return success
        mockRepository.notesToReturn = [newNote]
        
        // Observe notes changes
        viewModel.$notes
            .dropFirst() // Skip initial empty state
            .sink { notes in
                XCTAssertEqual(notes.count, 1)
                XCTAssertEqual(notes[0].title, "New Note")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.createNote(title: "New Note", content: "New content")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateNoteFailure() {
        resetMockState()
        let expectation = XCTestExpectation(description: "Create note failure")
        let testError = RepositoryError.saveFailed(NSError(domain: "Test", code: 500, userInfo: nil))
        
        // Setup mock to return error
        mockRepository.errorToReturn = testError
        
        // Observe error message changes
        viewModel.$errorMessage
            .sink { errorMessage in
                if errorMessage != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.createNote(title: "New Note", content: "New content")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Update Note Tests
    
    func testUpdateNoteSuccess() {
        resetMockState()
        let expectation = XCTestExpectation(description: "Update note success")
        let originalNote = NoteModel(title: "Original", content: "Original content")
        let updatedNote = NoteModel(title: "Updated", content: "Updated content")
        
        // Setup initial state
        mockRepository.notesToReturn = [originalNote]
        
        // Load initial notes
        viewModel.loadNotes()
        
        // Setup mock to return updated note
        mockRepository.notesToReturn = [updatedNote]
        
        // Observe notes changes
        viewModel.$notes
            .dropFirst() // Skip initial load
            .sink { notes in
                XCTAssertEqual(notes.count, 1)
                XCTAssertEqual(notes[0].title, "Updated")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateNote(originalNote, title: "Updated", content: "Updated content")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateNoteFailure() {
        resetMockState()
        let expectation = XCTestExpectation(description: "Update note failure")
        let note = NoteModel(title: "Test", content: "Test content")
        let testError = RepositoryError.saveFailed(NSError(domain: "Test", code: 500, userInfo: nil))
        
        // Setup mock to return error
        mockRepository.errorToReturn = testError
        
        // Observe error message changes
        viewModel.$errorMessage
            .sink { errorMessage in
                if errorMessage != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.updateNote(note, title: "Updated", content: "Updated content")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Delete Note Tests
    
    func testDeleteNoteSuccess() {
        resetMockState()
        let expectation = XCTestExpectation(description: "Delete note success")
        let noteToDelete = NoteModel(title: "To Delete", content: "Delete me")
        let remainingNotes = [NoteModel(title: "Remaining", content: "Stay")]
        
        // Setup initial state
        mockRepository.notesToReturn = [noteToDelete, remainingNotes[0]]
        
        // Load initial notes
        viewModel.loadNotes()
        
        // Setup mock to return remaining notes after delete
        mockRepository.notesToReturn = remainingNotes
        
        // Observe notes changes
        viewModel.$notes
            .dropFirst() // Skip initial load
            .sink { notes in
                XCTAssertEqual(notes.count, 1)
                XCTAssertEqual(notes[0].title, "Remaining")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.deleteNote(noteToDelete)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteNoteFailure() {
        resetMockState()
        let expectation = XCTestExpectation(description: "Delete note failure")
        let note = NoteModel(title: "Test", content: "Test content")
        let testError = RepositoryError.deleteFailed(NSError(domain: "Test", code: 500, userInfo: nil))
        
        // Setup mock to return error
        mockRepository.errorToReturn = testError
        
        // Observe error message changes
        viewModel.$errorMessage
            .sink { errorMessage in
                if errorMessage != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.deleteNote(note)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Utility Tests
    
    func testClearSearch() {
        // Setup some search state
        viewModel.searchText = "test query"
        XCTAssertEqual(viewModel.searchText, "test query")
        
        // Clear search
        viewModel.clearSearch()
        XCTAssertEqual(viewModel.searchText, "")
    }
    
    func testClearError() {
        viewModel.errorMessage = "Test error"
        XCTAssertNotNil(viewModel.errorMessage)
        
        viewModel.clearError()
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadStatisticsSuccess() {
        resetMockState()
        let expectation = XCTestExpectation(description: "Load statistics success")
        let testStatistics = NoteStatistics(
            totalNotes: 5,
            notesWithContent: 3,
            notesWithoutContent: 2,
            averageTitleLength: 10.0,
            averageContentLength: 25.0
        )
        
        // Setup mock to return statistics
        mockRepository.statisticsToReturn = testStatistics
        
        // Observe statistics changes
        viewModel.$noteStatistics
            .dropFirst() // Skip initial nil state
            .sink { statistics in
                XCTAssertNotNil(statistics)
                XCTAssertEqual(statistics?.totalNotes, 5)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.loadStatistics()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testEnableCloudKitSync() {
        resetMockState()
        // This test verifies that enableCloudKitSync doesn't crash
        // Since we're using a mock, this should always pass
        viewModel.enableCloudKitSync()
        
        // Test passes if we reach here without crashing
        XCTAssertTrue(true)
    }
    
    func testEnableLocalStorage() {
        resetMockState()
        // This is a simple pass-through method, just test it doesn't crash
        viewModel.enableLocalStorage()
        // No assertions needed as it's just a pass-through
    }
    
    // MARK: - Note Changes Tests
    
    func testHasNoteChanges() {
        let originalNote = NoteModel(title: "Original Title", content: "Original Content")
        
        // Test no changes
        XCTAssertFalse(viewModel.hasNoteChanges(
            original: originalNote,
            currentTitle: "Original Title",
            currentContent: "Original Content"
        ))
        
        // Test title change
        XCTAssertTrue(viewModel.hasNoteChanges(
            original: originalNote,
            currentTitle: "New Title",
            currentContent: "Original Content"
        ))
        
        // Test content change
        XCTAssertTrue(viewModel.hasNoteChanges(
            original: originalNote,
            currentTitle: "Original Title",
            currentContent: "New Content"
        ))
        
        // Test both changes
        XCTAssertTrue(viewModel.hasNoteChanges(
            original: originalNote,
            currentTitle: "New Title",
            currentContent: "New Content"
        ))
        
        // Test whitespace trimming
        XCTAssertTrue(viewModel.hasNoteChanges(
            original: originalNote,
            currentTitle: "  Original Title  ",
            currentContent: "  Original Content  "
        ))
    }
    
    func testFilteredNotes() {
        let testNotes = [
            NoteModel(title: "Swift Programming", content: "Learn Swift"),
            NoteModel(title: "iOS Development", content: "Build iOS apps"),
            NoteModel(title: "Python", content: "Learn Python")
        ]
        
        // Setup mock to return test notes
        mockRepository.notesToReturn = testNotes
        
        // Load notes first
        viewModel.loadNotes()
        
        // Wait for notes to be loaded
        let expectation = XCTestExpectation(description: "Filtered notes test")
        
        // Wait for notes to be loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Test empty search returns all notes
            self.viewModel.searchText = ""
            XCTAssertEqual(self.viewModel.filteredNotes.count, 3)
            
            // Test search by title
            self.viewModel.searchText = "Swift"
            XCTAssertEqual(self.viewModel.filteredNotes.count, 1)
            XCTAssertEqual(self.viewModel.filteredNotes.first?.title, "Swift Programming")
            
            // Test search by content
            self.viewModel.searchText = "iOS"
            XCTAssertEqual(self.viewModel.filteredNotes.count, 1)
            XCTAssertEqual(self.viewModel.filteredNotes.first?.title, "iOS Development")
            
            // Test search with no results
            self.viewModel.searchText = "JavaScript"
            XCTAssertEqual(self.viewModel.filteredNotes.count, 0)
            
            // Test case insensitive search
            self.viewModel.searchText = "swift"
            XCTAssertEqual(self.viewModel.filteredNotes.count, 1)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock NotesKitIntegration

fileprivate class MockNotesKitIntegration: NotesKitIntegration {
    private let mockRepository: MockNoteRepository
    
    init(repository: MockNoteRepository) {
        self.mockRepository = repository
        super.init()
    }
    
    override var repository: NoteRepository {
        return mockRepository
    }
    
    override var service: NotesService {
        return MockNotesService(repository: mockRepository)
    }
    
    override func getNoteStatistics() -> AnyPublisher<NoteStatistics, Error> {
        if let error = mockRepository.errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        if let statistics = mockRepository.statisticsToReturn {
            return Just(statistics)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: RepositoryError.fetchFailed(NSError(domain: "Test", code: 500, userInfo: nil)))
            .eraseToAnyPublisher()
    }
    
    override func enableCloudKitSync() {
        // Mock implementation - does nothing
        print("Mock: CloudKit sync enabled")
    }
    
    override func enableLocalStorage() {
        // Mock implementation - does nothing
        print("Mock: Local storage enabled")
    }
}

// MARK: - Mock NotesService

class MockNotesService: NotesService {
    private let mockRepository: MockNoteRepository
    
    init(repository: MockNoteRepository) {
        self.mockRepository = repository
        super.init(repository: repository)
    }
    
    override func getAllNotes() -> AnyPublisher<[NoteModel], Error> {
        if let error = mockRepository.errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        if !mockRepository.notesToReturn.isEmpty {
            return Just(mockRepository.notesToReturn)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return mockRepository.fetchNotes()
    }
    
    override func searchNotes(query: String) -> AnyPublisher<[NoteModel], Error> {
        if let error = mockRepository.errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        if !mockRepository.notesToReturn.isEmpty {
            return Just(mockRepository.notesToReturn)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return mockRepository.searchNotes(query: query)
    }
    
    override func createNote(title: String, content: String) -> AnyPublisher<NoteModel, Error> {
        // Check for validation error first
        if let error = mockRepository.errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        // If no error, create the note
        let note = NoteModel(title: title, content: content)
        return Just(note)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    override func updateNote(_ note: NoteModel, title: String, content: String) -> AnyPublisher<NoteModel, Error> {
        // Check for validation error first
        if let error = mockRepository.errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        // If no error, update the note
        var updatedNote = note
        updatedNote.update(title: title, content: content)
        return Just(updatedNote)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    override func deleteNote(_ note: NoteModel) -> AnyPublisher<Void, Error> {
        // Check for validation error first
        if let error = mockRepository.errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        // If no error, return success
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    override func getNoteStatistics() -> AnyPublisher<NoteStatistics, Error> {
        if let error = mockRepository.errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        if let statistics = mockRepository.statisticsToReturn {
            return Just(statistics)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: RepositoryError.fetchFailed(NSError(domain: "Test", code: 500, userInfo: nil)))
            .eraseToAnyPublisher()
    }
}

// MARK: - Mock NoteRepository

class MockNoteRepository: NoteRepository {
    var notesToReturn: [NoteModel] = []
    var errorToReturn: Error?
    var statisticsToReturn: NoteStatistics?
    
    func fetchNotes() -> AnyPublisher<[NoteModel], Error> {
        if let error = errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(notesToReturn)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func searchNotes(query: String) -> AnyPublisher<[NoteModel], Error> {
        if let error = errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(notesToReturn)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error> {
        if let error = errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(note)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error> {
        if let error = errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(note)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteNote(_ note: NoteModel) -> AnyPublisher<Void, Error> {
        if let error = errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getNote(by id: UUID) -> AnyPublisher<NoteModel?, Error> {
        if let error = errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        }
        let note = notesToReturn.first { $0.id == id }
        return Just(note)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func resetMockState() {
        notesToReturn = []
        errorToReturn = nil
        statisticsToReturn = nil
    }
}
