import Foundation
import Combine
import CloudKit

public class CloudKitNoteRepository: NoteRepository {
    private let container: CKContainer
    private let database: CKDatabase
    
    public init(container: CKContainer = .default(), database: CKDatabase? = nil) {
        self.container = container
        self.database = database ?? container.privateCloudDatabase
    }
    
    // MARK: - NoteRepository Implementation
    
    public func fetchNotes() -> AnyPublisher<[NoteModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.fetchFailed(NSError(domain: "CloudKitNoteRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))))
                return
            }
            
            let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
            query.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            
            let operation = CKQueryOperation(query: query)
            var notes: [NoteModel] = []
            
            operation.recordMatchedBlock = { _, result in
                switch result {
                case .success(let record):
                    if let note = NoteModel(from: record) {
                        notes.append(note)
                    }
                case .failure(let error):
                    print("Error fetching record: \(error)")
                }
            }
            
            operation.queryResultBlock = { result in
                switch result {
                case .success:
                    promise(.success(notes))
                case .failure(let error):
                    promise(.failure(RepositoryError.fetchFailed(error)))
                }
            }
            
            self.database.add(operation)
        }
        .eraseToAnyPublisher()
    }
    
    public func createNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.saveFailed(NSError(domain: "CloudKitNoteRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))))
                return
            }
            
            let record = CKRecord(recordType: "Note")
            record.setValue(note.id.uuidString, forKey: "id")
            record.setValue(note.title, forKey: "title")
            record.setValue(note.content, forKey: "content")
            record.setValue(note.createdAt, forKey: "createdAt")
            record.setValue(note.updatedAt, forKey: "updatedAt")
            
            self.database.save(record) { record, error in
                if let error = error {
                    promise(.failure(RepositoryError.saveFailed(error)))
                } else if let record = record, let savedNote = NoteModel(from: record) {
                    promise(.success(savedNote))
                } else {
                    promise(.failure(RepositoryError.saveFailed(NSError(domain: "CloudKitNoteRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to create note"]))))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func updateNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.saveFailed(NSError(domain: "CloudKitNoteRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))))
                return
            }
            
            let predicate = NSPredicate(format: "id == %@", note.id.uuidString)
            let query = CKQuery(recordType: "Note", predicate: predicate)
            
            self.database.perform(query, inZoneWith: nil) { records, error in
                if let error = error {
                    promise(.failure(RepositoryError.saveFailed(error)))
                    return
                }
                
                guard let record = records?.first else {
                    promise(.failure(RepositoryError.noteNotFound))
                    return
                }
                
                record.setValue(note.title, forKey: "title")
                record.setValue(note.content, forKey: "content")
                record.setValue(note.updatedAt, forKey: "updatedAt")
                
                self.database.save(record) { savedRecord, error in
                    if let error = error {
                        promise(.failure(RepositoryError.saveFailed(error)))
                    } else if let savedRecord = savedRecord, let updatedNote = NoteModel(from: savedRecord) {
                        promise(.success(updatedNote))
                    } else {
                        promise(.failure(RepositoryError.saveFailed(NSError(domain: "CloudKitNoteRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to update note"]))))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func deleteNote(_ note: NoteModel) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.deleteFailed(NSError(domain: "CloudKitNoteRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))))
                return
            }
            
            let predicate = NSPredicate(format: "id == %@", note.id.uuidString)
            let query = CKQuery(recordType: "Note", predicate: predicate)
            
            self.database.perform(query, inZoneWith: nil) { records, error in
                if let error = error {
                    promise(.failure(RepositoryError.deleteFailed(error)))
                    return
                }
                
                guard let record = records?.first else {
                    promise(.failure(RepositoryError.noteNotFound))
                    return
                }
                
                self.database.delete(withRecordID: record.recordID) { _, error in
                    if let error = error {
                        promise(.failure(RepositoryError.deleteFailed(error)))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func searchNotes(query: String) -> AnyPublisher<[NoteModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.searchFailed(NSError(domain: "CloudKitNoteRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))))
                return
            }
            
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
            let contentPredicate = NSPredicate(format: "content CONTAINS[cd] %@", query)
            let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            
            let ckQuery = CKQuery(recordType: "Note", predicate: compoundPredicate)
            ckQuery.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            
            let operation = CKQueryOperation(query: ckQuery)
            var notes: [NoteModel] = []
            
            operation.recordMatchedBlock = { _, result in
                switch result {
                case .success(let record):
                    if let note = NoteModel(from: record) {
                        notes.append(note)
                    }
                case .failure(let error):
                    print("Error searching record: \(error)")
                }
            }
            
            operation.queryResultBlock = { result in
                switch result {
                case .success:
                    promise(.success(notes))
                case .failure(let error):
                    promise(.failure(RepositoryError.searchFailed(error)))
                }
            }
            
            self.database.add(operation)
        }
        .eraseToAnyPublisher()
    }
    
    public func getNote(by id: UUID) -> AnyPublisher<NoteModel?, Error> {
        let predicate = NSPredicate(format: "id == %@", id.uuidString)
        let query = CKQuery(recordType: "Note", predicate: predicate)
        
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.searchFailed(NSError(domain: "CloudKitNoteRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))))
                return
            }
            
            self.database.perform(query, inZoneWith: nil) { records, error in
                if let error = error {
                    promise(.failure(RepositoryError.searchFailed(error)))
                    return
                }
                
                let note = records?.first.flatMap { NoteModel(from: $0) }
                promise(.success(note))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - CloudKit Setup
    
    public func setupCloudKit() -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.saveFailed(NSError(domain: "CloudKitNoteRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))))
                return
            }
            
            let customZone = CKRecordZone(zoneID: CKRecordZone.ID(zoneName: "NotesZone"))
            self.database.save(customZone) { _, error in
                if let error = error {
                    promise(.failure(RepositoryError.saveFailed(error)))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func checkCloudKitStatus() -> AnyPublisher<CKAccountStatus, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.searchFailed(NSError(domain: "CloudKitNoteRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Repository deallocated"]))))
                return
            }
            
            self.container.accountStatus { status, error in
                if let error = error {
                    promise(.failure(RepositoryError.searchFailed(error)))
                } else {
                    promise(.success(status))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - NoteModel Extensions

extension NoteModel {
    init?(from record: CKRecord) {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = record["title"] as? String,
              let content = record["content"] as? String,
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date else {
            return nil
        }
        
        self.init(id: id, title: title, content: content, createdAt: createdAt, updatedAt: updatedAt)
    }
}




