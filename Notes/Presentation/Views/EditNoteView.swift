import SwiftUI
import NotesKit

struct EditNoteView: View {
    let note: NoteModel
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var content: String
    @StateObject private var animationManager = AnimatedStateManager()
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isContentFocused: Bool
    
    // Computed property to check if note has been modified
    private var hasChanges: Bool {
        viewModel.hasNoteChanges(original: note, currentTitle: title, currentContent: content)
    }
    
    init(note: NoteModel, viewModel: NotesViewModel) {
        self.note = note
        self.viewModel = viewModel
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.content)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Title Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTitleFocused)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(true)
                        .textContentType(.none)
                        .accessibilityIdentifier("editNoteTitleField")
                }
                
                // Content Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Content")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .focused($isContentFocused)
                            .textInputAutocapitalization(.sentences)
                            .disableAutocorrection(true)
                            .textContentType(.none)
                            .accessibilityIdentifier("editNoteContentField")
                        
                        // Placeholder for TextEditor
                        if content.isEmpty {
                            Text("Enter note content...")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                // Change indicator
                VStack {
                    if hasChanges {
                        HStack {
                            Spacer()
                            Text("Modified")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.top, 8)
                        }
                    }
                    Spacer()
                }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("editNoteCancelButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveNote()
                        }
                    }
                    .disabled(!hasChanges || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(hasChanges ? .blue : .gray)
                    .accessibilityIdentifier("editNoteSaveButton")
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        // Resign focus safely
                        isTitleFocused = false
                        isContentFocused = false
                    }
                }
            }
        }
        .task {
            await MainActor.run {
                animationManager.show()
            }
        }
        .onDisappear {
            // Clear focus when view disappears
            isTitleFocused = false
            isContentFocused = false
        }
    }
    
    @MainActor
    private func saveNote() async {
        // Create updated note model using original note.id
        let updatedNote = NoteModel(
            id: note.id,
            title: title,
            content: content,
            createdAt: note.createdAt,
            updatedAt: Date()
        )
        
        // Update the note through the view model
        viewModel.updateNote(updatedNote, title: title, content: content)
        
        // Dismiss the view after updating the note
        dismiss()
    }
}

#Preview {
    EditNoteView(
        note: NoteModel(
            title: "Sample Note",
            content: "This is a sample note content for preview purposes."
        ),
        viewModel: NotesViewModel()
    )
}
