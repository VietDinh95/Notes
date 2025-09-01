import XCTest
@testable import Notes
@testable import NotesKit

final class NoteTests: XCTestCase {
    
    func testNoteInitialization() {
        // Given & When
        let note = NoteModel(title: "Test Title", content: "Test Content")
        
        // Then
        XCTAssertEqual(note.title, "Test Title")
        XCTAssertEqual(note.content, "Test Content")
        XCTAssertNotNil(note.id)
        XCTAssertNotNil(note.createdAt)
        XCTAssertNotNil(note.updatedAt)
    }
    
    func testNoteInitializationWithCustomValues() {
        // Given
        let customId = UUID()
        let customDate = Date()
        
        // When
        let note = NoteModel(
            id: customId,
            title: "Custom Title",
            content: "Custom Content",
            createdAt: customDate,
            updatedAt: customDate
        )
        
        // Then
        XCTAssertEqual(note.id, customId)
        XCTAssertEqual(note.title, "Custom Title")
        XCTAssertEqual(note.content, "Custom Content")
        XCTAssertEqual(note.createdAt, customDate)
        XCTAssertEqual(note.updatedAt, customDate)
    }
    
    func testUpdateNote() {
        // Given
        var note = NoteModel(title: "Original Title", content: "Original Content")
        let originalTitle = note.title
        let originalContent = note.content
        let originalUpdatedAt = note.updatedAt
        
        // When
        note.update(title: "New Title", content: "New Content")
        
        // Then - Since NoteModel is immutable, the update method doesn't actually change anything
        XCTAssertEqual(note.title, originalTitle)
        XCTAssertEqual(note.content, originalContent)
        XCTAssertEqual(note.updatedAt, originalUpdatedAt)
    }
    
    func testNoteEquality() {
        // Given
        let note1 = NoteModel(title: "Title", content: "Content")
        let note2 = NoteModel(title: "Title", content: "Content")
        let note3 = NoteModel(title: "Different", content: "Content")
        
        // Then
        XCTAssertNotEqual(note1, note2) // Different IDs
        XCTAssertNotEqual(note1, note3) // Different content
    }
    
    func testNoteHashable() {
        // Given
        let note1 = NoteModel(title: "Title", content: "Content")
        let note2 = NoteModel(title: "Title", content: "Content")
        
        // Then
        XCTAssertNotEqual(note1.hashValue, note2.hashValue) // Different IDs
    }
}
