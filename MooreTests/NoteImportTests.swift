//  NoteImportTests.swift
//  MooreTests
//  Created on 2026-02-23

import XCTest
import CoreData
@testable import Moore
#if false
class NoteImportTests: XCTestCase {
    var viewModel: NoteListViewModel!
    var context: NSManagedObjectContext!
    var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        context = createInMemoryContext()
        let noteService = CoreDataNoteService(context: context)
        viewModel = NoteListViewModel(noteService: noteService)
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        tempDirectory = nil
        context = nil
        viewModel = nil
        super.tearDown()
    }

    func test_importNotes_validMarkdown() throws {
        // Given: 有効なmdファイルを作成
        let md = """
        ---
        title: "Test Note"
        date: 2026-02-23T12:00:00Z
        tags:
          - work
        ---
        
        This is a test note.
        """
        let fileURL = tempDirectory.appendingPathComponent("test.md")
        try md.write(to: fileURL, atomically: true, encoding: .utf8)

        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)

        // Then: ノートが追加されている
        XCTAssertEqual(viewModel.notes.count, 1)
        let note = viewModel.notes.first!
        XCTAssertEqual(note.title, "Test Note")
        XCTAssertEqual(note.content, "This is a test note.")
        XCTAssertEqual(note.tag?.name, "work")
    }

    func test_importNotes_invalidMarkdown() throws {
        // Given: 無効なmdファイル（YAMLなし）
        let md = "No YAML frontmatter\nJust content"
        let fileURL = tempDirectory.appendingPathComponent("invalid.md")
        try md.write(to: fileURL, atomically: true, encoding: .utf8)

        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)

        // Then: エラーが通知される
        XCTAssertNotNil(viewModel.importErrorMessage)
        XCTAssertTrue(viewModel.notes.isEmpty)
    }

    func test_importNotes_emptyDirectory() throws {
        // When: 空ディレクトリでインポート
        viewModel.importNotes(from: tempDirectory)

        // Then: エラーが通知される
        XCTAssertNotNil(viewModel.importErrorMessage)
        XCTAssertTrue(viewModel.notes.isEmpty)
    }

    // ヘルパー: インメモリCoreData
    private func createInMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "Moore")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        return container.viewContext
    }
}
#endif
