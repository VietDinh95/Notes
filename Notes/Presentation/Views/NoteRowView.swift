import SwiftUI
import NotesKit

struct NoteRowView: View {
    let note: NoteModel
    let onTap: () -> Void
    @ObservedObject var viewModel: NotesViewModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(note.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)
                .accessibilityIdentifier("noteTitle_\(note.id.uuidString)")
            
            // Content Preview
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .accessibilityIdentifier("noteContent_\(note.id.uuidString)")
            }
            
            // Metadata
            HStack {
                Text(note.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Delete Button
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityIdentifier("btnDeleteNote_\(note.id.uuidString)")
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
        .background(
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap()
                }
        )
        .accessibilityIdentifier("noteRow_\(note.id.uuidString)")
        .confirmationDialog(
            "Delete Note",
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteNote(note)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
    }
}

#Preview {
    NoteRowView(
        note: NoteModel(
            title: "Sample Note",
            content: "This is a sample note content for preview purposes."
        ),
        onTap: {},
        viewModel: NotesViewModel()
    )
}
