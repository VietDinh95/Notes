import SwiftUI
import NotesKit

struct EditNoteView: View {
    let note: NoteModel
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var content: String
    @State private var noteId: UUID
    @State private var animationManager = AnimatedStateManager()
    
    // Computed property to check if note has been modified
    private var hasChanges: Bool {
        viewModel.hasNoteChanges(original: note, currentTitle: title, currentContent: content)
    }
    
    init(note: NoteModel, viewModel: NotesViewModel) {
        self.note = note
        self.viewModel = viewModel
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.content)
        self._noteId = State(initialValue: note.id)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Title Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("editNoteTitleField")
                }
                
                // Content Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Content")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .accessibilityIdentifier("editNoteContentField")
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
                        saveNote()
                    }
                    .disabled(!hasChanges || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(hasChanges ? .blue : .gray)
                    .accessibilityIdentifier("editNoteSaveButton")
                }
            }
        }
        .onAppear {
            animationManager.show()
        }
    }
    
    private func saveNote() {
        // Create updated note model
        let updatedNote = NoteModel(
            id: noteId,
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
