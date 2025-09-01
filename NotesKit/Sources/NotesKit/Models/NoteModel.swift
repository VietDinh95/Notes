import Foundation
import CoreData

/// Domain model for a Note
public struct NoteModel: Identifiable, Equatable, Hashable {
    public let id: UUID
    public let title: String
    public let content: String
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        content: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public mutating func update(title: String, content: String) {
        // Note: Since this is a struct, we need to create a new instance
        // This method is provided for API consistency
    }
}

// MARK: - Core Data Extensions

extension NoteModel {
    public init?(from managedObject: NSManagedObject) {
        guard let id = managedObject.value(forKey: "id") as? UUID,
              let title = managedObject.value(forKey: "title") as? String,
              let content = managedObject.value(forKey: "content") as? String,
              let createdAt = managedObject.value(forKey: "createdAt") as? Date,
              let updatedAt = managedObject.value(forKey: "updatedAt") as? Date else {
            return nil
        }
        
        self.init(id: id, title: title, content: content, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    public func toManagedObject(in context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)!
        let managedObject = NSManagedObject(entity: entity, insertInto: context)
        
        managedObject.setValue(id, forKey: "id")
        managedObject.setValue(title, forKey: "title")
        managedObject.setValue(content, forKey: "content")
        managedObject.setValue(createdAt, forKey: "createdAt")
        managedObject.setValue(updatedAt, forKey: "updatedAt")
        
        return managedObject
    }
}




