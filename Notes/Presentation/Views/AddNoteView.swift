import SwiftUI
import NotesKit

struct AddNoteView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @StateObject private var animationManager = AnimatedStateManager()
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isContentFocused: Bool
    
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
                        .accessibilityIdentifier("addNoteTitleField")
                        .submitLabel(.next)
                        .onSubmit {
                            isContentFocused = true
                        }
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
                            .accessibilityIdentifier("addNoteContentField")
                            .submitLabel(.done)
                        
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
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Dismiss keyboard when tapping outside
                        isTitleFocused = false
                        isContentFocused = false
                    }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("addNoteCancelButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveNote()
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("addNoteSaveButton")
                }
            }
        }
        .task {
            await MainActor.run {
                animationManager.show()
                isTitleFocused = true
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
        // Create the note through the view model
        viewModel.createNote(title: title, content: content)
        
        // Dismiss the view after creating the note
        dismiss()
    }
}

#Preview {
    AddNoteView(viewModel: NotesViewModel())
}
