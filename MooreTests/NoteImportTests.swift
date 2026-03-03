//  NoteImportTests.swift
//  MooreTests
//  Created on 2026-02-23

import XCTest
import CoreData
@testable import Moore

class NoteImportTests: XCTestCase {
    var viewModel: NoteListViewModel!
    var noteService: NoteDataService!
    var context: NSManagedObjectContext!
    var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        context = createInMemoryContext()
        noteService = CoreDataNoteService(context: context)
        viewModel = NoteListViewModel(noteService: noteService)
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        tempDirectory = nil
        noteService = nil
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
    
    // MARK: - Multiple Files Tests
    
    func test_importNotes_multipleFiles() throws {
        // Given: 複数の有効なmdファイル
        let md1 = """
        ---
        title: "First Note"
        date: 2026-01-01T10:00:00Z
        tags:
          - personal
        ---
        
        First content.
        """
        let md2 = """
        ---
        title: "Second Note"
        date: 2026-01-02T11:00:00Z
        tags:
          - work
        ---
        
        Second content.
        """
        let md3 = """
        ---
        title: "Third Note"
        date: 2026-01-03T12:00:00Z
        tags:
          - personal
        ---
        
        Third content.
        """
        
        try md1.write(to: tempDirectory.appendingPathComponent("note1.md"), atomically: true, encoding: .utf8)
        try md2.write(to: tempDirectory.appendingPathComponent("note2.md"), atomically: true, encoding: .utf8)
        try md3.write(to: tempDirectory.appendingPathComponent("note3.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: 全ノートがインポートされる
        XCTAssertNil(viewModel.importErrorMessage)
        XCTAssertEqual(viewModel.notes.count, 3)
        
        let titles = viewModel.notes.compactMap { $0.title }.sorted()
        XCTAssertTrue(titles.contains("First Note"))
        XCTAssertTrue(titles.contains("Second Note"))
        XCTAssertTrue(titles.contains("Third Note"))
        
        // タグが2つ作成されている
        XCTAssertEqual(viewModel.tags.count, 2)
        let tagNames = viewModel.tags.compactMap { $0.name }.sorted()
        XCTAssertTrue(tagNames.contains("personal"))
        XCTAssertTrue(tagNames.contains("work"))
    }
    
    // MARK: - Tag Tests
    
    func test_importNotes_existingTag() throws {
        // Given: 既存タグを作成
        let existingTag = noteService.createTag(name: "existing")
        try noteService.saveContext()
        viewModel.tags = noteService.fetchTags(predicate: nil, sortDescriptors: nil)
        
        // 既存タグと同じタグ名のmdファイル
        let md = """
        ---
        title: "Note with Existing Tag"
        date: 2026-02-23T12:00:00Z
        tags:
          - existing
        ---
        
        Content here.
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: 既存タグが使われ、新規タグは作られない
        XCTAssertNil(viewModel.importErrorMessage)
        XCTAssertEqual(viewModel.tags.count, 1)
        XCTAssertEqual(viewModel.notes.count, 1)
        XCTAssertEqual(viewModel.notes.first?.tag?.name, "existing")
    }
    
    func test_importNotes_newTag() throws {
        // Given: タグなしの状態
        XCTAssertEqual(viewModel.tags.count, 0)
        
        let md = """
        ---
        title: "Note with New Tag"
        date: 2026-02-23T12:00:00Z
        tags:
          - brandnew
        ---
        
        Content here.
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: 新規タグが作成される
        XCTAssertNil(viewModel.importErrorMessage)
        XCTAssertEqual(viewModel.tags.count, 1)
        XCTAssertEqual(viewModel.tags.first?.name, "brandnew")
        XCTAssertEqual(viewModel.notes.first?.tag?.name, "brandnew")
    }
    
    func test_importNotes_multipleTags_usesFirstTag() throws {
        // Given: 複数タグを含むmdファイル
        let md = """
        ---
        title: "Note with Multiple Tags"
        date: 2026-02-23T12:00:00Z
        tags:
          - first
          - second
          - third
        ---
        
        Content here.
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: 最初のタグのみ使用される
        XCTAssertNil(viewModel.importErrorMessage)
        XCTAssertEqual(viewModel.notes.count, 1)
        XCTAssertEqual(viewModel.notes.first?.tag?.name, "first")
        XCTAssertEqual(viewModel.tags.count, 1)
    }
    
    // MARK: - Content Tests
    
    func test_importNotes_multilineContent() throws {
        // Given: 複数行の本文
        let md = """
        ---
        title: "Multiline Note"
        date: 2026-02-23T12:00:00Z
        tags:
          - test
        ---
        
        First line of content.
        Second line of content.
        
        Third line after empty line.
        
        - Bullet point 1
        - Bullet point 2
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: 複数行が正しく保持される
        XCTAssertNil(viewModel.importErrorMessage)
        let note = viewModel.notes.first!
        XCTAssertTrue(note.content!.contains("First line"))
        XCTAssertTrue(note.content!.contains("Second line"))
        XCTAssertTrue(note.content!.contains("Third line"))
        XCTAssertTrue(note.content!.contains("Bullet point 1"))
    }
    
    func test_importNotes_japaneseContent() throws {
        // Given: 日本語コンテンツ
        let md = """
        ---
        title: "日本語ノート"
        date: 2026-02-23T12:00:00Z
        tags:
          - 日本語タグ
        ---
        
        これは日本語の本文です。
        改行も含まれています。
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: 日本語が正しくインポートされる
        XCTAssertNil(viewModel.importErrorMessage)
        let note = viewModel.notes.first!
        XCTAssertEqual(note.title, "日本語ノート")
        XCTAssertTrue(note.content!.contains("これは日本語の本文です"))
        XCTAssertEqual(note.tag?.name, "日本語タグ")
    }
    
    func test_importNotes_emojiContent() throws {
        // Given: 絵文字を含むコンテンツ
        let md = """
        ---
        title: "Emoji Note 🎉"
        date: 2026-02-23T12:00:00Z
        tags:
          - fun
        ---
        
        Content with emoji: 😀 🎨 🚀 ⭐️
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: 絵文字が正しくインポートされる
        XCTAssertNil(viewModel.importErrorMessage)
        let note = viewModel.notes.first!
        XCTAssertEqual(note.title, "Emoji Note 🎉")
        XCTAssertTrue(note.content!.contains("😀"))
        XCTAssertTrue(note.content!.contains("🚀"))
    }
    
    func test_importNotes_specialCharactersInTitle() throws {
        // Given: 特殊文字を含むタイトル
        let md = """
        ---
        title: "Note with / special * chars & symbols"
        date: 2026-02-23T12:00:00Z
        tags:
          - test
        ---
        
        Content here.
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: 特殊文字が保持される
        XCTAssertNil(viewModel.importErrorMessage)
        XCTAssertEqual(viewModel.notes.first?.title, "Note with / special * chars & symbols")
    }
    
    func test_importNotes_unicodeContent() throws {
        // Given: 多言語Unicode文字
        let md = """
        ---
        title: "Unicode Test"
        date: 2026-02-23T12:00:00Z
        tags:
          - multilang
        ---
        
        Chinese: 你好世界
        Korean: 안녕하세요
        Arabic: مرحبا بالعالم
        Russian: Привет мир
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: Unicode文字が正しくインポートされる
        XCTAssertNil(viewModel.importErrorMessage)
        let content = viewModel.notes.first?.content ?? ""
        XCTAssertTrue(content.contains("你好世界"))
        XCTAssertTrue(content.contains("안녕하세요"))
        XCTAssertTrue(content.contains("مرحبا بالعالم"))
        XCTAssertTrue(content.contains("Привет мир"))
    }
    
    // MARK: - Error Tests
    
    func test_importNotes_missingTitle() throws {
        // Given: titleがないmdファイル
        let md = """
        ---
        date: 2026-02-23T12:00:00Z
        tags:
          - test
        ---
        
        Content without title.
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: エラーが通知される
        XCTAssertNotNil(viewModel.importErrorMessage)
        XCTAssertTrue(viewModel.importErrorMessage!.contains("title"))
        XCTAssertEqual(viewModel.notes.count, 0)
    }
    
    func test_importNotes_missingDate() throws {
        // Given: dateがないmdファイル
        let md = """
        ---
        title: "No Date Note"
        tags:
          - test
        ---
        
        Content without date.
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: エラーが通知される
        XCTAssertNotNil(viewModel.importErrorMessage)
        XCTAssertTrue(viewModel.importErrorMessage!.contains("date"))
        XCTAssertEqual(viewModel.notes.count, 0)
    }
    
    func test_importNotes_missingTags() throws {
        // Given: tagsがないmdファイル
        let md = """
        ---
        title: "No Tag Note"
        date: 2026-02-23T12:00:00Z
        ---
        
        Content without tags.
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: エラーが通知される
        XCTAssertNotNil(viewModel.importErrorMessage)
        XCTAssertTrue(viewModel.importErrorMessage!.contains("tags"))
        XCTAssertEqual(viewModel.notes.count, 0)
    }
    
    func test_importNotes_emptyContent() throws {
        // Given: 本文が空のmdファイル
        let md = """
        ---
        title: "Empty Content"
        date: 2026-02-23T12:00:00Z
        tags:
          - test
        ---
        
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: エラーが通知される
        XCTAssertNotNil(viewModel.importErrorMessage)
        XCTAssertTrue(viewModel.importErrorMessage!.contains("本文"))
        XCTAssertEqual(viewModel.notes.count, 0)
    }
    
    func test_importNotes_invalidDateFormat() throws {
        // Given: 不正なdate形式
        let md = """
        ---
        title: "Invalid Date"
        date: 2026/02/23 12:00:00
        tags:
          - test
        ---
        
        Content here.
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: エラーが通知される
        XCTAssertNotNil(viewModel.importErrorMessage)
        XCTAssertTrue(viewModel.importErrorMessage!.contains("date"))
        XCTAssertEqual(viewModel.notes.count, 0)
    }
    
    func test_importNotes_partialFailure_rollback() throws {
        // Given: 有効なファイル2つと無効なファイル1つ
        let validMd1 = """
        ---
        title: "Valid Note 1"
        date: 2026-02-23T12:00:00Z
        tags:
          - test
        ---
        
        Valid content 1.
        """
        let invalidMd = """
        ---
        title: "Invalid Note"
        ---
        
        Missing date and tags.
        """
        let validMd2 = """
        ---
        title: "Valid Note 2"
        date: 2026-02-23T13:00:00Z
        tags:
          - test
        ---
        
        Valid content 2.
        """
        
        try validMd1.write(to: tempDirectory.appendingPathComponent("valid1.md"), atomically: true, encoding: .utf8)
        try invalidMd.write(to: tempDirectory.appendingPathComponent("invalid.md"), atomically: true, encoding: .utf8)
        try validMd2.write(to: tempDirectory.appendingPathComponent("valid2.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: 全件ロールバックされる
        XCTAssertNotNil(viewModel.importErrorMessage)
        XCTAssertEqual(viewModel.notes.count, 0)
    }
    
    // MARK: - Edge Case Tests
    
    func test_importNotes_quotesInTitle() throws {
        // Given: タイトル内にquotesを含む
        let md = """
        ---
        title: "Note with \\"quotes\\" inside"
        date: 2026-02-23T12:00:00Z
        tags:
          - test
        ---
        
        Content here.
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: quotesが正しくパースされる
        XCTAssertNil(viewModel.importErrorMessage)
        XCTAssertEqual(viewModel.notes.first?.title, "Note with \\\"quotes\\\" inside")
    }
    
    func test_importNotes_longContent() throws {
        // Given: 大量のコンテンツ（100KB以上）
        let longText = String(repeating: "This is a long line of text to test large content imports. ", count: 2000)
        let md = """
        ---
        title: "Large Content Note"
        date: 2026-02-23T12:00:00Z
        tags:
          - test
        ---
        
        \(longText)
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: インポート実行
        viewModel.importNotes(from: tempDirectory)
        
        // Then: 大量コンテンツが正しくインポートされる
        XCTAssertNil(viewModel.importErrorMessage)
        let content = viewModel.notes.first?.content ?? ""
        XCTAssertTrue(content.count > 100000)
    }
    
    func test_importNotes_duplicateImport() throws {
        // Given: 同じタイトル・日時のノート
        let md = """
        ---
        title: "Duplicate Note"
        date: 2026-02-23T12:00:00Z
        tags:
          - test
        ---
        
        First import.
        """
        try md.write(to: tempDirectory.appendingPathComponent("test.md"), atomically: true, encoding: .utf8)
        
        // When: 初回インポート
        viewModel.importNotes(from: tempDirectory)
        XCTAssertEqual(viewModel.notes.count, 1)
        
        // 2回目インポート
        viewModel.importNotes(from: tempDirectory)
        
        // Then: 重複チェックせず2件になる
        XCTAssertNil(viewModel.importErrorMessage)
        XCTAssertEqual(viewModel.notes.count, 2)
        XCTAssertEqual(viewModel.notes.filter { $0.title == "Duplicate Note" }.count, 2)
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
