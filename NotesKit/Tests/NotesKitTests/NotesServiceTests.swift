import XCTest
import Combine
@testable import NotesKit

final class NotesServiceTests: XCTestCase {
    var mockRepository: MockNoteRepository!
    var notesService: NotesService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockNoteRepository()
        notesService = NotesService(repository: mockRepository)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        mockRepository = nil
        notesService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testCreateNoteWithValidData() {
        // Given
        let expectation = XCTestExpectation(description: "Note created successfully")
        let title = "Test Title"
        let content = "Test Content"
        
        // When
        notesService.createNote(title: title, content: content)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { note in
                    XCTAssertEqual(note.title, title)
                    XCTAssertEqual(note.content, content)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateNoteWithEmptyTitle() {
        // Given
        let expectation = XCTestExpectation(description: "Note creation failed with empty title")
        let title = ""
        let content = "Test Content"
        
        // When
        notesService.createNote(title: title, content: content)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertEqual(error as? RepositoryError, RepositoryError.invalidData)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected failure but got success")
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetAllNotesWithSorting() {
        // Given
        let expectation = XCTestExpectation(description: "Notes retrieved and sorted")
        let notes = [
            NoteModel(title: "First", content: "Content 1", updatedAt: Date().addingTimeInterval(-100)),
            NoteModel(title: "Second", content: "Content 2", updatedAt: Date().addingTimeInterval(-50)),
            NoteModel(title: "Third", content: "Content 3", updatedAt: Date())
        ]
        mockRepository.mockNotes = notes
        
        // When
        notesService.getAllNotes()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { retrievedNotes in
                    XCTAssertEqual(retrievedNotes.count, 3)
                    XCTAssertEqual(retrievedNotes.first?.title, "Third")
                    XCTAssertEqual(retrievedNotes.last?.title, "First")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchNotesWithEmptyQuery() {
        // Given
        let expectation = XCTestExpectation(description: "All notes returned for empty query")
        let notes = [
            NoteModel(title: "First", content: "Content 1"),
            NoteModel(title: "Second", content: "Content 2")
        ]
        mockRepository.mockNotes = notes
        
        // When
        notesService.searchNotes(query: "")
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { retrievedNotes in
                    XCTAssertEqual(retrievedNotes.count, 2)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetNoteStatistics() {
        // Given
        let expectation = XCTestExpectation(description: "Note statistics calculated")
        let notes = [
            NoteModel(title: "Title 1", content: "Content 1"),
            NoteModel(title: "Title 2", content: ""),
            NoteModel(title: "Title 3", content: "Content 3")
        ]
        mockRepository.mockNotes = notes
        
        // When
        notesService.getNoteStatistics()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got error: \(error)")
                    }
                },
                receiveValue: { statistics in
                    XCTAssertEqual(statistics.totalNotes, 3)
                    XCTAssertEqual(statistics.notesWithContent, 2)
                    XCTAssertEqual(statistics.notesWithoutContent, 1)
                    XCTAssertEqual(statistics.averageTitleLength, 6.0, accuracy: 0.1)
                    XCTAssertEqual(statistics.averageContentLength, 4.0, accuracy: 0.1)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Repository
private class MockNoteRepository: NoteRepository {
    var mockNotes: [NoteModel] = []
    var mockError: Error?
    
    func fetchNotes() -> AnyPublisher<[NoteModel], Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(mockNotes)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        mockNotes.append(note)
        return Just(note)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        if let index = mockNotes.firstIndex(where: { $0.id == note.id }) {
            mockNotes[index] = note
        }
        return Just(note)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteNote(_ note: NoteModel) -> AnyPublisher<Void, Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        mockNotes.removeAll { $0.id == note.id }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func searchNotes(query: String) -> AnyPublisher<[NoteModel], Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        let filteredNotes = mockNotes.filter { note in
            note.title.localizedCaseInsensitiveContains(query) ||
            note.content.localizedCaseInsensitiveContains(query)
        }
        return Just(filteredNotes)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getNote(by id: UUID) -> AnyPublisher<NoteModel?, Error> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        let note = mockNotes.first { $0.id == id }
        return Just(note)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}










