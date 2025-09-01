import Foundation
import Combine

/// Protocol defining the interface for note repository operations
public protocol NoteRepository {
    /// Fetch all notes
    func fetchNotes() -> AnyPublisher<[NoteModel], Error>
    
    /// Create a new note
    func createNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error>
    
    /// Update an existing note
    func updateNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error>
    
    /// Delete a note
    func deleteNote(_ note: NoteModel) -> AnyPublisher<Void, Error>
    
    /// Search notes by query
    func searchNotes(query: String) -> AnyPublisher<[NoteModel], Error>
    
    /// Get note by ID
    func getNote(by id: UUID) -> AnyPublisher<NoteModel?, Error>
}

// MARK: - Repository Errors
public enum RepositoryError: Error, LocalizedError {
    case noteNotFound
    case invalidData
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)
    case searchFailed(Error)
    case contextDeallocated
    
    public var errorDescription: String? {
        switch self {
        case .noteNotFound:
            return "Note not found"
        case .invalidData:
            return "Invalid data"
        case .saveFailed(let error):
            return "Save failed: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Delete failed: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Fetch failed: \(error.localizedDescription)"
        case .searchFailed(let error):
            return "Search failed: \(error.localizedDescription)"
        case .contextDeallocated:
            return "Context deallocated"
        }
    }
}




