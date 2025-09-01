import CoreData
import Foundation
import Combine

public final class CoreDataNoteRepository: NoteRepository {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - NoteRepository Implementation
    
    public func fetchNotes() -> AnyPublisher<[NoteModel], Error> {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Note")
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]
        
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextDeallocated))
                return
            }
            
            self.context.perform {
                do {
                    let notes = try self.context.fetch(request)
                    let noteModels = notes.compactMap { NoteModel(from: $0) }
                    promise(.success(noteModels))
                } catch {
                    promise(.failure(RepositoryError.fetchFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func createNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextDeallocated))
                return
            }
            
            self.context.perform {
                guard let entityDescription = NSEntityDescription.entity(forEntityName: "Note", in: self.context) else {
                    promise(.failure(RepositoryError.invalidData))
                    return
                }
                
                let newNote = NSManagedObject(entity: entityDescription, insertInto: self.context)
                newNote.setValue(note.id, forKey: "id")
                newNote.setValue(note.title, forKey: "title")
                newNote.setValue(note.content, forKey: "content")
                newNote.setValue(note.createdAt, forKey: "createdAt")
                newNote.setValue(note.updatedAt, forKey: "updatedAt")
                
                do {
                    try self.context.save()
                    promise(.success(note))
                } catch {
                    promise(.failure(RepositoryError.saveFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func updateNote(_ note: NoteModel) -> AnyPublisher<NoteModel, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextDeallocated))
                return
            }
            
            self.context.perform {
                let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Note")
                request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
                
                do {
                    let notes = try self.context.fetch(request)
                    guard let existingNote = notes.first else {
                        promise(.failure(RepositoryError.noteNotFound))
                        return
                    }
                    
                    existingNote.setValue(note.title, forKey: "title")
                    existingNote.setValue(note.content, forKey: "content")
                    existingNote.setValue(Date(), forKey: "updatedAt")
                    
                    try self.context.save()
                    promise(.success(note))
                } catch {
                    promise(.failure(RepositoryError.saveFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func deleteNote(_ note: NoteModel) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextDeallocated))
                return
            }
            
            self.context.perform {
                let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Note")
                request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
                
                do {
                    let notes = try self.context.fetch(request)
                    guard let existingNote = notes.first else {
                        promise(.failure(RepositoryError.noteNotFound))
                        return
                    }
                    
                    self.context.delete(existingNote)
                    try self.context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(RepositoryError.deleteFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func searchNotes(query: String) -> AnyPublisher<[NoteModel], Error> {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Note")
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@", query, query)
        request.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false)
        ]
        
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextDeallocated))
                return
            }
            
            self.context.perform {
                do {
                    let notes = try self.context.fetch(request)
                    let noteModels = notes.compactMap { NoteModel(from: $0) }
                    promise(.success(noteModels))
                } catch {
                    promise(.failure(RepositoryError.searchFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func getNote(by id: UUID) -> AnyPublisher<NoteModel?, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(RepositoryError.contextDeallocated))
                return
            }
            
            self.context.perform {
                let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Note")
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                request.fetchLimit = 1
                
                do {
                    let notes = try self.context.fetch(request)
                    let noteModel = notes.first.flatMap { NoteModel(from: $0) }
                    promise(.success(noteModel))
                } catch {
                    promise(.failure(RepositoryError.fetchFailed(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}


