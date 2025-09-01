import Foundation
import Combine
import SwiftUI
import NotesKit

/// ViewModel for managing notes list and operations
@MainActor
final class NotesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var notes: [NoteModel] = []
    @Published var filteredNotes: [NoteModel] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSearching = false
    @Published var noteStatistics: NoteStatistics?
    
    // MARK: - Private Properties
    
    private let notesKitIntegration: NotesKitIntegration
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(notesKitIntegration: NotesKitIntegration = NotesKitIntegration()) {
        self.notesKitIntegration = notesKitIntegration
        setupBindings()
        loadNotes()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Debounced search only - avoid race condition
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.applySearchFilter()  // Single source of truth for search
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Load all notes
    func loadNotes() {
        isLoading = true
        errorMessage = nil
        isSearching = false  // Reset search state when loading notes
        
        notesKitIntegration.service.getAllNotes()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] notes in
                    self?.notes = notes
                    self?.filteredNotes = notes
                    self?.loadStatistics()
                }
            )
            .store(in: &cancellables)
    }
    
    /// Create a new note
    func createNote(title: String, content: String) {
        isLoading = true
        errorMessage = nil
        
        notesKitIntegration.service.createNote(title: title, content: content)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] newNote in
                    self?.notes.insert(newNote, at: 0)
                    self?.applySearchFilter()
                }
            )
            .store(in: &cancellables)
    }
    
    /// Update an existing note
    func updateNote(_ note: NoteModel, title: String, content: String) {
        isLoading = true
        errorMessage = nil
        
        notesKitIntegration.service.updateNote(note, title: title, content: content)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] updatedNote in
                    if let index = self?.notes.firstIndex(where: { $0.id == updatedNote.id }) {
                        self?.notes[index] = updatedNote
                        self?.applySearchFilter()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    /// Delete a note
    func deleteNote(_ note: NoteModel) {
        isLoading = true
        errorMessage = nil
        
        notesKitIntegration.service.deleteNote(note)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.notes.removeAll { $0.id == note.id }
                    self?.applySearchFilter()
                }
            )
            .store(in: &cancellables)
    }
    
    /// Delete notes at specified indices
    func deleteNotes(at offsets: IndexSet) {
        let notesToDelete = offsets.map { filteredNotes[$0] }
        notesToDelete.forEach { deleteNote($0) }
    }
    
    /// Search notes
    func searchNotes(query: String) {
        // This method is only called for non-empty queries
        isSearching = true
        errorMessage = nil
        
        notesKitIntegration.service.searchNotes(query: query)
            .sink(
                receiveCompletion: { [weak self] completion in
                    // Only set isSearching = false on error, not on success
                    if case .failure(let error) = completion {
                        self?.isSearching = false
                        self?.errorMessage = error.localizedDescription
                    }
                    // On success, keep isSearching = true to show search state
                },
                receiveValue: { [weak self] searchResults in
                    self?.filteredNotes = searchResults
                    // Keep isSearching = true even when no results found
                }
            )
            .store(in: &cancellables)
    }
    
    /// Clear search and reload all notes
    func clearSearch() {
        searchText = ""
        isSearching = false  // Ensure isSearching is reset when clearing search
        loadNotes()
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Load note statistics
    func loadStatistics() {
        notesKitIntegration.getNoteStatistics()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] statistics in
                    self?.noteStatistics = statistics
                }
            )
            .store(in: &cancellables)
    }
    
    /// Enable CloudKit sync
    func enableCloudKitSync() {
        notesKitIntegration.enableCloudKitSync()
    }
    
    /// Enable local storage
    func enableLocalStorage() {
        notesKitIntegration.enableLocalStorage()
    }
    
    /// Get animation service
    var animationService: AnimationService {
        return notesKitIntegration.animations
    }
    
    /// Get animated state manager
    var stateManager: AnimatedStateManager {
        return notesKitIntegration.stateManager
    }
    
    /// Check if note has changes
    func hasNoteChanges(original: NoteModel, currentTitle: String, currentContent: String) -> Bool {
        return original.title != currentTitle || original.content != currentContent
    }
    
    // MARK: - Private Methods
    
    private func applySearchFilter() {
        if searchText.isEmpty {
            // Handle empty search immediately
            filteredNotes = notes
            isSearching = false  // Stop searching when no query
        } else {
            // Handle non-empty search
            searchNotes(query: searchText)
        }
    }
}
