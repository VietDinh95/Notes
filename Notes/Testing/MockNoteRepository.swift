import Foundation
import Combine
import NotesKit

final class MockNoteRepository: NoteRepository {
    var notesToReturn: [NoteModel] = []
    var shouldFail = false
    var errorToReturn: Error = RepositoryError.fetchFailed(NSError(domain: "Mock", code: 500, userInfo: nil))
    
    func fetchNotes() -> AnyPublisher<[NoteModel], Error> {
        if shouldFail {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        }
        return Just(notesToReturn)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error> {
        if shouldFail {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        }
        notesToReturn.append(note)
        return Just(note)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error> {
        if shouldFail {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        }
        
        if let index = notesToReturn.firstIndex(where: { $0.id == note.id }) {
            notesToReturn[index] = note
            return Just(note)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: RepositoryError.noteNotFound)
                .eraseToAnyPublisher()
        }
    }
    
    func deleteNote(_ note: NoteModel) -> AnyPublisher<Void, Error> {
        if shouldFail {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        }
        
        notesToReturn.removeAll { $0.id == note.id }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func searchNotes(query: String) -> AnyPublisher<[NoteModel], Error> {
        if shouldFail {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        }
        
        let filteredNotes = notesToReturn.filter { note in
            note.title.localizedCaseInsensitiveContains(query) ||
            note.content.localizedCaseInsensitiveContains(query)
        }
        
        return Just(filteredNotes)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getNote(by id: UUID) -> AnyPublisher<NoteModel?, Error> {
        if shouldFail {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        }
        
        let note = notesToReturn.first { $0.id == id }
        return Just(note)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
