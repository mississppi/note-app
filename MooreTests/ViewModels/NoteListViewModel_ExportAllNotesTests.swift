//
//  NoteListViewModel_ExportAllNotesTests.swift
//  MooreTests
//
//  Created on 2026-03-03.
//

import XCTest
import CoreData
@testable import Moore

/// exportAllActiveNotes機能のテスト
/// 全タグのノートがエクスポートされることを検証
class NoteListViewModel_ExportAllNotesTests: XCTestCase {
    
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
    
    // MARK: - exportAllActiveNotes Tests
    
    func test_exportAllActiveNotes_returnsCorrectCount() throws {
        // Given: 複数タグに3つのノートを作成
        let tag1 = noteService.createTag(name: "Work")
        let tag2 = noteService.createTag(name: "Personal")
        
        _ = noteService.createNote(title: "Work Note 1", content: "Work content 1", tag: tag1)
        _ = noteService.createNote(title: "Work Note 2", content: "Work content 2", tag: tag1)
        _ = noteService.createNote(title: "Personal Note", content: "Personal content", tag: tag2)
        
        try noteService.saveContext()
        
        // When: 全ノートをエクスポート
        let exportedCount = viewModel.exportAllActiveNotes(to: tempDirectory)
        
        // Then: 3件がエクスポートされたことが返される
        XCTAssertEqual(exportedCount, 3)
    }
    
    func test_exportAllActiveNotes_excludesTrashedNotes() throws {
        // Given: アクティブ2件、ゴミ箱1件のノート
        let tag = noteService.createTag(name: "Test")
        
        let activeNote1 = noteService.createNote(title: "Active 1", content: "Content 1", tag: tag)
        let activeNote2 = noteService.createNote(title: "Active 2", content: "Content 2", tag: tag)
        let trashedNote = noteService.createNote(title: "Trashed", content: "Trashed content", tag: tag)
        
        // ゴミ箱に移動
        noteService.trashNote(trashedNote)
        
        try noteService.saveContext()
        
        // When: 全アクティブノートをエクスポート
        let exportedCount = viewModel.exportAllActiveNotes(to: tempDirectory)
        
        // Then: アクティブな2件のみがエクスポートされる
        XCTAssertEqual(exportedCount, 2)
    }
    
    func test_exportAllActiveNotes_exportsNotesFromAllTags() throws {
        // Given: 3つのタグに5つのノート
        let tag1 = noteService.createTag(name: "Tag1")
        let tag2 = noteService.createTag(name: "Tag2")
        let tag3 = noteService.createTag(name: "Tag3")
        
        _ = noteService.createNote(title: "Note 1-1", content: "Content", tag: tag1)
        _ = noteService.createNote(title: "Note 1-2", content: "Content", tag: tag1)
        _ = noteService.createNote(title: "Note 2-1", content: "Content", tag: tag2)
        _ = noteService.createNote(title: "Note 2-2", content: "Content", tag: tag2)
        _ = noteService.createNote(title: "Note 3-1", content: "Content", tag: tag3)
        
        try noteService.saveContext()
        
        // When: 全ノートをエクスポート
        let exportedCount = viewModel.exportAllActiveNotes(to: tempDirectory)
        
        // Then: 全5件がエクスポートされる（件数のみ確認）
        // Note: セキュリティスコープリソースの制限により、テスト環境ではファイル書き込み確認はスキップ
        XCTAssertEqual(exportedCount, 5)
    }
    
    func test_exportAllActiveNotes_emptyDatabase_returnsZero() throws {
        // Given: ノートなし
        
        // When: エクスポート実行
        let exportedCount = viewModel.exportAllActiveNotes(to: tempDirectory)
        
        // Then: 0件が返される
        XCTAssertEqual(exportedCount, 0)
    }
    
    func test_exportAllActiveNotes_currentTagSelection_doesNotAffectExport() throws {
        // Given: 2つのタグにノートを作成し、tag1を選択状態にする
        let tag1 = noteService.createTag(name: "Tag1")
        let tag2 = noteService.createTag(name: "Tag2")
        
        _ = noteService.createNote(title: "Tag1 Note", content: "Content 1", tag: tag1)
        _ = noteService.createNote(title: "Tag2 Note", content: "Content 2", tag: tag2)
        
        try noteService.saveContext()
        
        // tag1を選択してfetchNotes（viewModel.notesにはtag1のノートのみ）
        viewModel.fetchData()
        viewModel.selectedTag = tag1
        viewModel.fetchNotes(searchText: "", selectedTag: tag1)
        
        XCTAssertEqual(viewModel.notes.count, 1, "Should show only tag1 notes")
        
        // When: 全ノートをエクスポート
        let exportedCount = viewModel.exportAllActiveNotes(to: tempDirectory)
        
        // Then: 選択タグに関わらず全2件がエクスポートされる
        XCTAssertEqual(exportedCount, 2, "Should export all notes regardless of selected tag")
    }
    
    // MARK: - Helper Methods
    
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
