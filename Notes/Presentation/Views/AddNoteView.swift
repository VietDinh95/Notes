import SwiftUI
import NotesKit

struct AddNoteView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var animationManager = AnimatedStateManager()
    
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
                        .accessibilityIdentifier("addNoteTitleField")
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
                        .accessibilityIdentifier("addNoteContentField")
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("addNoteCancelButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("addNoteSaveButton")
                }
            }
        }
        .onAppear {
            animationManager.show()
        }
    }
    
    private func saveNote() {
        // Create the note through the view model
        viewModel.createNote(title: title, content: content)
        
        // Dismiss the view after creating the note
        dismiss()
    }
}

#Preview {
    AddNoteView(viewModel: NotesViewModel())
}
