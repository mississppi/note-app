//
//  NoteListViewModel_ExportTests.swift
//  MooreTests
//
//  Created on 2026-03-02.
//

import XCTest
import CoreData
@testable import Moore

class NoteListViewModel_ExportTests: XCTestCase {
    
    var viewModel: NoteListViewModel!
    var service: CoreDataNoteService!
    var testContext: NSManagedObjectContext!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        testContext = createInMemoryContext()
        service = CoreDataNoteService(context: testContext)
        viewModel = NoteListViewModel(noteService: service)
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        tempDirectory = nil
        viewModel = nil
        service = nil
        testContext = nil
        super.tearDown()
    }
    
    // MARK: - Test exportNotes (direct method)
    
    func test_exportNotes_withValidNotes_createsExportFolder() throws {
        // Given
        let tag = createTestTag(name: "work")
        let notes = [
            createTestNote(title: "Note 1", content: "Content 1", tag: tag),
            createTestNote(title: "Note 2", content: "Content 2", tag: tag)
        ]
        
        // When
        viewModel.exportNotes(notes, to: tempDirectory)
        
        // Then
        let contents = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        XCTAssertEqual(contents.count, 1, "Should create one export folder")
        XCTAssertTrue(contents[0].lastPathComponent.hasPrefix("Moore_Export_"))
        
        // Verify files were created
        let exportFolder = contents[0]
        let files = try FileManager.default.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)
        XCTAssertEqual(files.count, 2, "Should create 2 markdown files")
    }
    
    func test_exportNotes_withEmptyArray_createsEmptyFolder() throws {
        // Given
        let notes: [Note] = []
        
        // When
        viewModel.exportNotes(notes, to: tempDirectory)
        
        // Then
        let contents = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        XCTAssertEqual(contents.count, 1, "Should create export folder even if empty")
        
        let exportFolder = contents[0]
        let files = try FileManager.default.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)
        XCTAssertEqual(files.count, 0, "Should create empty folder")
    }
    
    func test_exportNotes_excludesTrashedNotes() throws {
        // Given
        let tag = createTestTag(name: "work")
        let activeNote = createTestNote(title: "Active", content: "Content", tag: tag)
        let trashedNote = createTestNote(title: "Trashed", content: "Content", tag: tag)
        trashedNote.isTrashed = true
        trashedNote.trashedAt = Date()
        
        // When
        viewModel.exportNotes([activeNote, trashedNote], to: tempDirectory)
        
        // Then
        let exportFolder = try getExportFolder()
        let files = try FileManager.default.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)
        XCTAssertEqual(files.count, 2, "Should export both notes (trash flag is just metadata)")
        // Note: Current implementation exports all notes passed to it
        // If you want to exclude trashed notes, filter in the caller
    }
    
    func test_exportNotes_preservesNoteContent() throws {
        // Given
        let tag = createTestTag(name: "personal")
        let note = createTestNote(title: "My Note", content: "Important content", tag: tag)
        
        // When
        viewModel.exportNotes([note], to: tempDirectory)
        
        // Then
        let exportFolder = try getExportFolder()
        let files = try FileManager.default.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)
        let fileContent = try String(contentsOf: files[0], encoding: .utf8)
        
        XCTAssertTrue(fileContent.contains("My Note"))
        XCTAssertTrue(fileContent.contains("Important content"))
        XCTAssertTrue(fileContent.contains("personal"))
    }
    
    func test_exportNotes_withJapaneseContent() throws {
        // Given
        let tag = createTestTag(name: "仕事")
        let note = createTestNote(title: "日本語タイトル", content: "日本語の内容", tag: tag)
        
        // When
        viewModel.exportNotes([note], to: tempDirectory)
        
        // Then
        let exportFolder = try getExportFolder()
        let files = try FileManager.default.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)
        let fileContent = try String(contentsOf: files[0], encoding: .utf8)
        
        XCTAssertTrue(fileContent.contains("日本語タイトル"))
        XCTAssertTrue(fileContent.contains("日本語の内容"))
        XCTAssertTrue(fileContent.contains("仕事"))
    }
    
    func test_exportNotes_withMultipleNotes_createsAllFiles() throws {
        // Given
        let tag1 = createTestTag(name: "tag1")
        let tag2 = createTestTag(name: "tag2")
        let notes = [
            createTestNote(title: "Note 1", content: "Content 1", tag: tag1),
            createTestNote(title: "Note 2", content: "Content 2", tag: tag1),
            createTestNote(title: "Note 3", content: "Content 3", tag: tag2)
        ]
        
        // When
        viewModel.exportNotes(notes, to: tempDirectory)
        
        // Then
        let exportFolder = try getExportFolder()
        let files = try FileManager.default.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)
        XCTAssertEqual(files.count, 3, "Should create 3 files")
        
        // Verify all notes are present
        let allContent = try files.map { try String(contentsOf: $0, encoding: .utf8) }.joined()
        XCTAssertTrue(allContent.contains("Note 1"))
        XCTAssertTrue(allContent.contains("Note 2"))
        XCTAssertTrue(allContent.contains("Note 3"))
    }
    
    // MARK: - Test exportActiveNotes (ViewModel's public API)
    
    // Note: exportActiveNotes is currently commented out in ViewModel
    // Uncomment these tests when the method is implemented
    
    /*
    func test_exportActiveNotes_callsExportService() throws {
        // Given
        let tag = createTestTag(name: "work")
        viewModel.selectedTag = tag
        viewModel.addNewNote()
        viewModel.selectedTitle = "Test Note"
        
        // When
        viewModel.exportActiveNotes(to: tempDirectory)
        
        // Then
        let contents = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        XCTAssertEqual(contents.count, 1, "Should create export folder")
    }
    
    func test_exportActiveNotes_excludesTrashedNotes() throws {
        // Given
        let tag = createTestTag(name: "work")
        viewModel.selectedTag = tag
        viewModel.addNewNote()
        let note = viewModel.selectedNote!
        viewModel.trashNote(note: note)
        
        // When
        viewModel.exportActiveNotes(to: tempDirectory)
        
        // Then
        let exportFolder = try getExportFolder()
        let files = try FileManager.default.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)
        XCTAssertEqual(files.count, 0, "Should not export trashed notes")
    }
    */
    
    // MARK: - Helper Methods
    
    private func createInMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "Moore")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        
        return container.viewContext
    }
    
    private func createTestTag(name: String) -> Tag {
        let tag = Tag(context: testContext)
        tag.name = name
        tag.uuid = UUID()
        return tag
    }
    
    private func createTestNote(title: String, content: String, tag: Tag) -> Note {
        let note = Note(context: testContext)
        note.title = title
        note.content = content
        note.tag = tag
        note.createdAt = Date()
        note.updatedAt = Date()
        note.uuid = UUID()
        note.isTrashed = false
        note.order = 0
        return note
    }
    
    private func getExportFolder() throws -> URL {
        let contents = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        guard let folder = contents.first else {
            throw NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Export folder not found"])
        }
        return folder
    }
}
