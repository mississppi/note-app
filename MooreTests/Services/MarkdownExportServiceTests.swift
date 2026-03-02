//
//  MarkdownExportServiceTests.swift
//  MooreTests
//
//  Created on 2026-02-21.
//

import XCTest
import CoreData
@testable import Moore

class MarkdownExportServiceTests: XCTestCase {
    
    var sut: MarkdownExportService!
    var testContext: NSManagedObjectContext!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        sut = MarkdownExportService()
        testContext = createInMemoryContext()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        tempDirectory = nil
        testContext = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Test exportNotes
    
    func test_exportNotes_createsExportFolder() throws {
        // Given
        let note = createTestNote(title: "Test Note", content: "Test content")
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let contents = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        XCTAssertEqual(contents.count, 1, "Should create one export folder")
        
        let exportFolder = contents[0]
        XCTAssertTrue(exportFolder.lastPathComponent.hasPrefix("Moore_Export_"))
    }
    
    func test_exportNotes_createsCorrectNumberOfFiles() throws {
        // Given
        let notes = [
            createTestNote(title: "Note 1", content: "Content 1"),
            createTestNote(title: "Note 2", content: "Content 2"),
            createTestNote(title: "Note 3", content: "Content 3")
        ]
        
        // When
        try sut.exportNotes(notes, to: tempDirectory)
        
        // Then
        let exportFolder = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)[0]
        let files = try FileManager.default.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)
        XCTAssertEqual(files.count, 3, "Should create 3 markdown files")
    }
    
    func test_exportNotes_emptyNotes_createsEmptyFolder() throws {
        // Given
        let notes: [Note] = []
        
        // When
        try sut.exportNotes(notes, to: tempDirectory)
        
        // Then
        let exportFolder = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)[0]
        let files = try FileManager.default.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)
        XCTAssertEqual(files.count, 0, "Should create empty folder")
    }
    
    // MARK: - Test Markdown Generation
    
    func test_generateMarkdown_withTitleAndContent() throws {
        // Given
        let note = createTestNote(title: "My Title", content: "My content")
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("---"))
        XCTAssertTrue(markdown.contains("title: \"My Title\""))
        XCTAssertTrue(markdown.contains("My content"))
    }
    
    func test_generateMarkdown_withoutTitle() throws {
        // Given
        let note = createTestNote(title: nil, content: "Content without title")
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("title: \"Untitled\""))
    }
    
    func test_generateMarkdown_withDate() throws {
        // Given
        let date = Date(timeIntervalSince1970: 1708502400) // 2024-02-21 12:00:00 UTC
        let note = createTestNote(title: "Dated Note", content: "Content", date: date)
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("date: "))
        XCTAssertTrue(markdown.contains("2024-02-21"))
    }
    
    func test_generateMarkdown_withTags() throws {
        // Given
        let note = createTestNote(title: "Tagged Note", content: "Content")
        let tag = createTestTag(name: "work", context: testContext)
        note.tag = tag
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("tags:"))
        XCTAssertTrue(markdown.contains("- work"))
    }
    
    func test_generateMarkdown_withSpecialCharactersInTitle() throws {
        // Given
        let note = createTestNote(title: "Title with \"quotes\" and \\backslash", content: "Content")
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("\\\""))
        XCTAssertTrue(markdown.contains("\\\\"))
    }
    
    // MARK: - Test Filename Generation
    
    func test_generateFilename_withDateAndTitle() throws {
        // Given
        let date = createDate(year: 2024, month: 2, day: 21)
        let note = createTestNote(title: "My-Note", content: "Content", date: date)
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let files = try getExportedFiles()
        XCTAssertEqual(files.count, 1)
        XCTAssertTrue(files[0].lastPathComponent.hasPrefix("2024-02-21-"))
        XCTAssertTrue(files[0].lastPathComponent.hasSuffix(".md"))
        XCTAssertTrue(files[0].lastPathComponent.contains("My-Note"))
    }
    
    func test_generateFilename_withoutDate() throws {
        // Given
        let note = createTestNote(title: "No Date Note", content: "Content", date: nil)
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let files = try getExportedFiles()
        XCTAssertTrue(files[0].lastPathComponent.hasPrefix("0000-00-00-"))
    }
    
    func test_generateFilename_withInvalidCharacters() throws {
        // Given
        let note = createTestNote(title: "Invalid:/\\?*|\"<>Name", content: "Content")
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let files = try getExportedFiles()
        let filename = files[0].lastPathComponent
        XCTAssertFalse(filename.contains(":"))
        XCTAssertFalse(filename.contains("/"))
        XCTAssertFalse(filename.contains("\\"))
        XCTAssertFalse(filename.contains("?"))
        XCTAssertFalse(filename.contains("*"))
        XCTAssertFalse(filename.contains("|"))
        XCTAssertFalse(filename.contains("\""))
        XCTAssertFalse(filename.contains("<"))
        XCTAssertFalse(filename.contains(">"))
        XCTAssertTrue(filename.contains("Invalid"))
        XCTAssertTrue(filename.contains("Name"))
    }
    
    func test_generateFilename_veryLongTitle() throws {
        // Given
        let longTitle = String(repeating: "a", count: 200)
        let note = createTestNote(title: longTitle, content: "Content")
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let files = try getExportedFiles()
        let filename = files[0].deletingPathExtension().lastPathComponent
        // Remove date prefix (11 chars: "yyyy-MM-dd-") and UUID suffix (9 chars: "-" + 8 UUID chars)
        // Format: yyyy-MM-dd-title-uuid
        let parts = filename.components(separatedBy: "-")
        // Should have: year, month, day, ...title parts..., uuid
        XCTAssertGreaterThanOrEqual(parts.count, 5, "Should have date parts, title, and UUID")
        // Verify file was created successfully
        XCTAssertTrue(filename.count > 11, "Filename should include date, title, and UUID parts")
    }
    
    func test_generateFilename_emptyTitle() throws {
        // Given
        let note = createTestNote(title: "", content: "Content")
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let files = try getExportedFiles()
        XCTAssertTrue(files[0].lastPathComponent.contains("untitled"))
    }
    
    // MARK: - Test Content Preservation
    
    func test_exportNotes_preservesMultilineContent() throws {
        // Given
        let multilineContent = """
        Line 1
        Line 2
        Line 3
        """
        let note = createTestNote(title: "Multiline", content: multilineContent)
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("Line 1"))
        XCTAssertTrue(markdown.contains("Line 2"))
        XCTAssertTrue(markdown.contains("Line 3"))
    }
    
    func test_exportNotes_preservesEmojis() throws {
        // Given
        let note = createTestNote(title: "Emoji Test 🎉", content: "Content with 😀")
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("🎉"))
        XCTAssertTrue(markdown.contains("😀"))
    }
    
    func test_exportNotes_preservesJapaneseCharacters() throws {
        // Given
        let note = createTestNote(title: "日本語タイトル", content: "日本語の内容")
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("日本語タイトル"))
        XCTAssertTrue(markdown.contains("日本語の内容"))
    }
    
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
    
    private func createTestNote(title: String?, content: String?, date: Date? = Date()) -> Note {
        let note = Note(context: testContext)
        note.title = title
        note.content = content
        note.createdAt = date
        note.updatedAt = date ?? Date()
        note.uuid = UUID()
        note.trashedAt = nil
        return note
    }
    
    private func createTestTag(name: String, context: NSManagedObjectContext) -> Tag {
        let tag = Tag(context: context)
        tag.name = name
        tag.uuid = UUID()
        return tag
    }
    
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }
    
    private func readFirstExportedFile() throws -> String {
        let files = try getExportedFiles()
        guard let firstFile = files.first else {
            throw NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "No files found"])
        }
        return try String(contentsOf: firstFile, encoding: .utf8)
    }
    
    private func getExportedFiles() throws -> [URL] {
        let exportFolder = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)[0]
        return try FileManager.default.contentsOfDirectory(at: exportFolder, includingPropertiesForKeys: nil)
    }
    
    // MARK: - Error Handling Tests
    
    func test_exportNotes_invalidDirectory_throwsError() throws {
        // Given
        let note = createTestNote(title: "Test", content: "Content")
        let invalidURL = URL(fileURLWithPath: "/nonexistent/path/\(UUID().uuidString)")
        
        // When/Then
        XCTAssertThrowsError(try sut.exportNotes([note], to: invalidURL)) { error in
            // Should throw error when directory doesn't exist or can't be accessed
            XCTAssertNotNil(error)
        }
    }
    
    func test_exportNotes_readOnlyDirectory_throwsError() throws {
        // Given
        let note = createTestNote(title: "Test", content: "Content")
        let readOnlyDir = tempDirectory.appendingPathComponent("readonly")
        try FileManager.default.createDirectory(at: readOnlyDir, withIntermediateDirectories: true)
        
        // Make directory read-only
        try FileManager.default.setAttributes([.posixPermissions: 0o444], ofItemAtPath: readOnlyDir.path)
        
        // When/Then
        XCTAssertThrowsError(try sut.exportNotes([note], to: readOnlyDir)) { error in
            // Should throw permission error
            XCTAssertNotNil(error)
        }
        
        // Cleanup: restore permissions so tearDown can delete
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: readOnlyDir.path)
    }
    
    func test_exportNotes_nilTitleAndContent_handlesGracefully() throws {
        // Given
        let note = createTestNote(title: nil, content: nil)
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("title: \"Untitled\""))
        XCTAssertFalse(markdown.contains("nil"))
    }
    
    func test_exportNotes_noteWithoutContext_handlesGracefully() throws {
        // Given
        let note = Note(context: testContext)
        note.title = "Orphan Note"
        note.content = "Content"
        note.createdAt = Date()
        note.updatedAt = Date()
        note.uuid = UUID()
        // Note: tag is nil, which is valid
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let files = try getExportedFiles()
        XCTAssertEqual(files.count, 1, "Should export note without tag")
        
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("Orphan Note"))
        XCTAssertFalse(markdown.contains("tags:"), "Should not have tags section when no tag")
    }
    
    func test_exportNotes_veryLargeContent_exportsSuccessfully() throws {
        // Given
        let largeContent = String(repeating: "This is a line of text.\n", count: 10000) // ~240KB
        let note = createTestNote(title: "Large Note", content: largeContent)
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("Large Note"))
        XCTAssertGreaterThan(markdown.count, 200000, "Should contain large content")
    }
    
    func test_exportNotes_multipleNotesWithSameTitle_createsUniqueFilenames() throws {
        // Given
        let date = createDate(year: 2024, month: 2, day: 21)
        let notes = [
            createTestNote(title: "Duplicate", content: "Content 1", date: date),
            createTestNote(title: "Duplicate", content: "Content 2", date: date),
            createTestNote(title: "Duplicate", content: "Content 3", date: date)
        ]
        
        // When
        try sut.exportNotes(notes, to: tempDirectory)
        
        // Then
        let files = try getExportedFiles()
        XCTAssertEqual(files.count, 3, "Should create 3 unique files (UUID suffix prevents overwrites)")
        
        // Verify all filenames contain UUID suffix
        for file in files {
            let filename = file.lastPathComponent
            XCTAssertTrue(filename.hasPrefix("2024-02-21-Duplicate-"))
            XCTAssertTrue(filename.hasSuffix(".md"))
        }
        
        // Verify all contents are preserved (no overwriting)
        let allContents = try files.map { try String(contentsOf: $0, encoding: .utf8) }.joined()
        XCTAssertTrue(allContents.contains("Content 1"))
        XCTAssertTrue(allContents.contains("Content 2"))
        XCTAssertTrue(allContents.contains("Content 3"))
    }
    
    func test_exportNotes_specialCharactersInContent_preserves() throws {
        // Given
        let specialContent = """
        Special characters: !@#$%^&*()
        Quotes: "double" and 'single'
        Backticks: `code`
        Markdown: **bold** and *italic*
        """
        let note = createTestNote(title: "Special", content: specialContent)
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("!@#$%^&*()"))
        XCTAssertTrue(markdown.contains("\"double\""))
        XCTAssertTrue(markdown.contains("**bold**"))
        XCTAssertTrue(markdown.contains("`code`"))
    }
    
    func test_exportNotes_unicodeContent_preserves() throws {
        // Given
        let unicodeContent = """
        Emoji: 🎉 😀 🚀
        Japanese: 日本語
        Chinese: 中文
        Korean: 한글
        Arabic: العربية
        Mathematical: ∑∫∂∇
        """
        let note = createTestNote(title: "Unicode", content: unicodeContent)
        
        // When
        try sut.exportNotes([note], to: tempDirectory)
        
        // Then
        let markdown = try readFirstExportedFile()
        XCTAssertTrue(markdown.contains("🎉"))
        XCTAssertTrue(markdown.contains("日本語"))
        XCTAssertTrue(markdown.contains("中文"))
        XCTAssertTrue(markdown.contains("한글"))
        XCTAssertTrue(markdown.contains("العربية"))
        XCTAssertTrue(markdown.contains("∑∫∂∇"))
    }
}
