import Foundation
import Combine

/// Service layer for handling note business logic
public class NotesService {
    private let repository: NoteRepository
    private var cancellables = Set<AnyCancellable>()
    
    public init(repository: NoteRepository) {
        self.repository = repository
    }
    
    /// Get all notes with sorting
    public func getAllNotes() -> AnyPublisher<[NoteModel], Error> {
        return repository.fetchNotes()
            .map { notes in
                notes.sorted { $0.updatedAt > $1.updatedAt }
            }
            .eraseToAnyPublisher()
    }
    
    /// Create a new note with validation
    public func createNote(title: String, content: String) -> AnyPublisher<NoteModel, Error> {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Fail(error: RepositoryError.invalidData)
                .eraseToAnyPublisher()
        }
        
        let note = NoteModel(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        return repository.createNote(note)
            .eraseToAnyPublisher()
    }
    
    /// Update an existing note with validation
    public func updateNote(_ note: NoteModel, title: String, content: String) -> AnyPublisher<NoteModel, Error> {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Fail(error: RepositoryError.invalidData)
                .eraseToAnyPublisher()
        }
        
        var updatedNote = note
        updatedNote.update(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        return repository.updateNote(updatedNote)
            .eraseToAnyPublisher()
    }
    
    /// Search notes with debouncing and validation
    public func searchNotes(query: String) -> AnyPublisher<[NoteModel], Error> {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            return repository.fetchNotes()
                .eraseToAnyPublisher()
        }
        
        return repository.searchNotes(query: trimmedQuery)
            .eraseToAnyPublisher()
    }
    
    /// Delete note with confirmation
    public func deleteNote(_ note: NoteModel) -> AnyPublisher<Void, Error> {
        return repository.deleteNote(note)
            .eraseToAnyPublisher()
    }
    
    /// Get note statistics
    public func getNoteStatistics() -> AnyPublisher<NoteStatistics, Error> {
        return repository.fetchNotes()
            .map { notes in
                NoteStatistics(
                    totalNotes: notes.count,
                    notesWithContent: notes.filter { !$0.content.isEmpty }.count,
                    notesWithoutContent: notes.filter { $0.content.isEmpty }.count,
                    averageTitleLength: notes.isEmpty ? 0 : Double(notes.map { $0.title.count }.reduce(0, +)) / Double(notes.count),
                    averageContentLength: notes.isEmpty ? 0 : Double(notes.map { $0.content.count }.reduce(0, +)) / Double(notes.count)
                )
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Note Statistics
public struct NoteStatistics {
    public let totalNotes: Int
    public let notesWithContent: Int
    public let notesWithoutContent: Int
    public let averageTitleLength: Double
    public let averageContentLength: Double
    
    public init(
        totalNotes: Int,
        notesWithContent: Int,
        notesWithoutContent: Int,
        averageTitleLength: Double,
        averageContentLength: Double
    ) {
        self.totalNotes = totalNotes
        self.notesWithContent = notesWithContent
        self.notesWithoutContent = notesWithoutContent
        self.averageTitleLength = averageTitleLength
        self.averageContentLength = averageContentLength
    }
}










