import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        
        // For bonus CloudKit sync, uncomment this line:
        // let container = NSPersistentCloudKitContainer(name: "CoreDataModel")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Enable automatic merging of changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - In-Memory Context for Testing
    
    static var inMemoryContainer: NSPersistentContainer {
        let container = NSPersistentContainer(name: "CoreDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }
    
    // MARK: - Reset for UI Testing
    
    func reset() {
        // Delete all entities
        let context = persistentContainer.viewContext
        let entityNames = persistentContainer.managedObjectModel.entities.map { $0.name }
        
        for entityName in entityNames {
            guard let entityName = entityName else { continue }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                print("🧹 Deleted all \(entityName) entities")
            } catch {
                print("❌ Failed to delete \(entityName) entities: \(error)")
            }
        }
        
        // Save context
        saveContext()
        print("✅ Core Data reset complete")
    }
    
    // MARK: - In-Memory Store for UI Testing
    
    func useInMemoryStore() {
        // Create in-memory container
        let container = NSPersistentContainer(name: "CoreDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("❌ Failed to load in-memory store: \(error)")
            } else {
                print("✅ In-memory store loaded for UI testing")
            }
        }
        
        // Replace the persistent container
        persistentContainer = container
        
        // Enable automatic merging of changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
