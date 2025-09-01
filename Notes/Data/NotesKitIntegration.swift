import Foundation
import Combine
import CoreData
import CloudKit
import NotesKit

/// Integration layer for NotesKit framework
/// This file provides a bridge between the main app and NotesKit
/// allowing for easy switching between different repository implementations
class NotesKitIntegration: ObservableObject {
    
    // MARK: - Repository Configuration
    
    /// Current repository implementation
    @Published private var currentRepository: NoteRepository
    
    // MARK: - Services
    
    /// Notes service for business logic
    private var notesService: NotesService
    
    /// Animation service for enhanced UI
    private let animationService: AnimationService
    
    /// Animated state manager for interactive animations
    private let animatedStateManager: AnimatedStateManager
    
    // MARK: - Initialization
    
    init() {
        // Initialize services first
        self.animationService = AnimationService()
        self.animatedStateManager = AnimatedStateManager()
        
        // Create a temporary repository for initialization with Core Data context
        let tempRepository = CoreDataNoteRepository(context: CoreDataStack.shared.viewContext)
        
        // Initialize notes service with temporary repository
        self.notesService = NotesService(repository: tempRepository)
        
        // Now assign to the published property
        self.currentRepository = tempRepository
        
        // Setup CloudKit if available
        // Temporarily disabled to avoid entitlement issues
        // setupCloudKitIfAvailable()
    }
    
    // MARK: - Repository Management
    
    /// Switch to CloudKit repository for iCloud sync
    func enableCloudKitSync() {
        print("☁️ Enabling CloudKit sync...")
        
        let cloudKitRepository = CloudKitNoteRepository()
        
        // Setup CloudKit zone
        cloudKitRepository.setupCloudKit()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("✅ CloudKit setup completed")
                        self?.currentRepository = cloudKitRepository
                        // Update service with new repository
                        self?.notesService = NotesService(repository: cloudKitRepository)
                    case .failure(let error):
                        print("❌ CloudKit setup failed: \(error)")
                    }
                },
                receiveValue: { _ in
                    print("✅ CloudKit zone created")
                }
            )
            .store(in: &cancellables)
    }
    
    /// Switch to local storage repository
    func enableLocalStorage() {
        print("💾 Switching to local storage...")
        self.currentRepository = CoreDataNoteRepository(context: CoreDataStack.shared.viewContext)
        // Update service with new repository
        self.notesService = NotesService(repository: currentRepository)
    }
    
    /// Public accessor for the current repository
    var repository: NoteRepository {
        return currentRepository
    }
    
    /// Get the notes service
    var service: NotesService {
        return notesService
    }
    
    /// Get the animation service
    var animations: AnimationService {
        return animationService
    }
    
    /// Get the animated state manager
    var stateManager: AnimatedStateManager {
        return animatedStateManager
    }
    
    // MARK: - CloudKit Setup
    
    private func setupCloudKitIfAvailable() {
        // Check if CloudKit is available and user is signed in
        let cloudKitRepository = CloudKitNoteRepository()
        
        cloudKitRepository.checkCloudKitStatus()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("✅ CloudKit status check completed")
                    case .failure(let error):
                        print("❌ CloudKit status check failed: \(error)")
                    }
                },
                receiveValue: { status in
                    switch status {
                    case .available:
                        print("✅ CloudKit is available")
                        // Optionally auto-enable CloudKit sync
                        // self.enableCloudKitSync()
                    case .noAccount:
                        print("⚠️ No iCloud account found")
                    case .restricted:
                        print("⚠️ CloudKit access is restricted")
                    case .couldNotDetermine:
                        print("⚠️ Could not determine CloudKit status")
                    case .temporarilyUnavailable:
                        print("⚠️ CloudKit is temporarily unavailable")
                    @unknown default:
                        print("⚠️ Unknown CloudKit status")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Note Statistics
    
    func getNoteStatistics() -> AnyPublisher<NoteStatistics, Error> {
        return notesService.getNoteStatistics()
    }
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
}
