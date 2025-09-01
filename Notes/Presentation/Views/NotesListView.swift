import SwiftUI
import NotesKit

struct NotesListView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var showingAddNote = false
    @State private var selectedNote: NoteModel?
    @State private var isSearchFocused: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                if !viewModel.notes.isEmpty {
                    SearchBar(text: $viewModel.searchText)
                        .accessibilityIdentifier("searchBar")
                        .padding(.top, -8) // Reduce spacing between nav bar and search bar
                }
                
                // Notes List
                if viewModel.filteredNotes.isEmpty && !viewModel.isSearching {
                    EmptyStateView {
                        showingAddNote = true
                    }
                    .accessibilityIdentifier("emptyStateView")
                } else if viewModel.filteredNotes.isEmpty && viewModel.isSearching {
                    NoSearchResultsView(searchQuery: viewModel.searchText) {
                        viewModel.clearSearch()
                    }
                    .accessibilityIdentifier("noSearchResultsView")
                } else {
                    List {
                        ForEach(viewModel.filteredNotes) { note in
                            NoteRowView(
                                note: note,
                                onTap: { selectedNote = note },
                                viewModel: viewModel
                            )
                            .accessibilityIdentifier("noteRow_\(note.id.uuidString)")
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .accessibilityIdentifier("notesList")
                    .refreshable {
                        viewModel.loadNotes()
                    }
                }
                
                // Loading View
                if viewModel.isLoading {
                    LoadingView()
                        .accessibilityIdentifier("loadingView")
                }
                
                // Error Banner
                if let errorMessage = viewModel.errorMessage {
                    ErrorBanner(message: errorMessage) {
                        viewModel.clearError()
                    }
                    .accessibilityIdentifier("errorBanner")
                }
            }
            .onTapGesture {
                // End search editing when tapping outside
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddNote = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .accessibilityIdentifier("addNoteButton")
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(viewModel: viewModel)
            }
            .sheet(item: $selectedNote) { note in
                EditNoteView(note: note, viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
                viewModel.loadNotes()
            }
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        for index in offsets {
            let note = viewModel.filteredNotes[index]
            viewModel.deleteNote(note)
        }
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search notes...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)
                .accessibilityIdentifier("searchField")
            
            if !text.isEmpty {
                Button("Clear") {
                    text = ""
                }
                .foregroundColor(.blue)
                .accessibilityIdentifier("clearSearchButton")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let onCreateNote: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Notes Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityIdentifier("emptyStateTitle")
            
            Text("Create your first note to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create First Note") {
                onCreateNote()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("createFirstNoteButton")
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .accessibilityIdentifier("loadingIndicator")
            
            Text("Loading notes...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Spacer()
            
            Button("Dismiss") {
                onDismiss()
            }
            .foregroundColor(.blue)
            .accessibilityIdentifier("dismissErrorButton")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemRed).opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - No Search Results View

struct NoSearchResultsView: View {
    let searchQuery: String
    let onClearSearch: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Results Found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .accessibilityIdentifier("noSearchResultsTitle")
            
            Text("No notes match \"\(searchQuery)\"")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Clear Search") {
                onClearSearch()
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("clearSearchButton")
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    let viewModel = NotesViewModel()
    
    // Add sample data for preview
    let sampleNotes = [
        NoteModel(
            id: UUID(),
            title: "Shopping List",
            content: "1. Milk\n2. Bread\n3. Eggs\n4. Butter",
            createdAt: Date().addingTimeInterval(-86400), // 1 day ago
            updatedAt: Date().addingTimeInterval(-3600)   // 1 hour ago
        ),
        NoteModel(
            id: UUID(),
            title: "Meeting Notes",
            content: "Team standup discussion:\n- Project timeline review\n- Bug fixes priority\n- Next sprint planning",
            createdAt: Date().addingTimeInterval(-172800), // 2 days ago
            updatedAt: Date().addingTimeInterval(-7200)    // 2 hours ago
        ),
        NoteModel(
            id: UUID(),
            title: "Ideas for Weekend",
            content: "Things to do this weekend:\n• Visit the new coffee shop\n• Watch the latest movie\n• Call mom and dad\n• Clean the apartment",
            createdAt: Date().addingTimeInterval(-259200), // 3 days ago
            updatedAt: Date().addingTimeInterval(-10800)   // 3 hours ago
        )
    ]
    
    // Set sample data
    viewModel.notes = sampleNotes
    viewModel.filteredNotes = sampleNotes
    
    return NotesListView(viewModel: viewModel)
}

#Preview("Empty State View") {
    EmptyStateView {
        print("Create first note tapped")
    }
}

#Preview("No Search Results View") {
    NoSearchResultsView(searchQuery: "test") {
        print("Clear search tapped")
    }
}
