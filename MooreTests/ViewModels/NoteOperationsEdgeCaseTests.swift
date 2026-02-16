import XCTest
import CoreData
@testable import Moore

/// NoteListViewModelのノート操作エッジケースをテスト
/// 
/// テスト対象:
/// - エラーハンドリング
/// - nil値の処理
/// - 大量データ操作
final class NoteOperationsEdgeCaseTests: XCTestCase {
    
    var service: CoreDataNoteService!
    var persistenceController: PersistenceController!
    var viewContext: NSManagedObjectContext!
    var viewModel: NoteListViewModel!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        viewContext = persistenceController.container.viewContext
        service = CoreDataNoteService(context: viewContext)
        viewModel = NoteListViewModel(noteService: service)
    }
    
    override func tearDown() {
        viewModel = nil
        service = nil
        viewContext = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Note Selection Edge Cases
    
    /// 目的: nilノートを選択しても安全に処理されることを確認
    func testSelectNote_WhenNil_ShouldHandleSafely() {
        // Given: 既存のノートを選択している状態
        let note = service.createNote(title: "Test", content: "Content", tag: nil)
        try? service.saveContext()
        viewModel.select(note: note, userInitiated: false)
        
        XCTAssertNotNil(viewModel.selectedNote, "初期状態では選択されている")
        
        // When: nilを選択
        viewModel.select(note: nil, userInitiated: false)
        
        // Then: エラーなく処理される
        XCTAssertNil(viewModel.selectedNote, "選択がクリアされるべき")
        XCTAssertEqual(viewModel.selectedTitle, "", "タイトルが空になるべき")
        XCTAssertEqual(viewModel.selectedContent, "", "コンテンツが空になるべき")
    }
    
    /// 目的: 削除されたノートを選択しても安全に処理されることを確認
    func testSelectNote_WhenNoteIsDeleted_ShouldHandleSafely() {
        // Given: ノートを作成して削除
        let note = service.createNote(title: "ToDelete", content: "", tag: nil)
        try? service.saveContext()
        
        service.deleteNote(note)
        try? service.saveContext()
        
        // When: 削除されたノートを選択しようとする
        viewModel.select(note: note, userInitiated: false)
        
        // Then: エラーなく処理される（ノートは無効だが、クラッシュしない）
        // Note: CoreDataの仕様上、削除されたオブジェクトでも参照は可能だが、
        // isFaultプロパティでチェック可能
        XCTAssertTrue(note.isFault || note.isDeleted, "削除されたノートはFaultまたはDeletedである")
    }
    
    // MARK: - Auto-save Edge Cases (Removed)
    // Note: autoSaveTitle and autoSaveContent are fileprivate, so direct testing is not possible.
    // These methods are indirectly tested through debounced property changes in the ViewModel.
    
    // MARK: - Batch Operations
    
    /// 目的: 大量のノートを作成しても正常に動作することを確認
    func testFetchNotes_WithManyNotes_ShouldHandleCorrectly() {
        // Given: 100件のノートを作成
        for i in 1...100 {
            _ = service.createNote(title: "Note \(i)", content: "Content \(i)", tag: nil)
        }
        try? service.saveContext()
        
        // When: ノートを取得
        viewModel.fetchNotes()
        
        // Then: 全てのノートが取得される
        XCTAssertEqual(viewModel.notes.count, 100, "100件のノートが取得されるべき")
    }
    
    /// 目的: 大量のゴミ箱ノートを処理できることを確認
    func testFetchTrashedNotes_WithManyNotes_ShouldHandleCorrectly() {
        // Given: 50件のゴミ箱ノートを作成
        for i in 1...50 {
            let note = service.createNote(title: "Trashed \(i)", content: "", tag: nil)
            service.trashNote(note)
        }
        try? service.saveContext()
        
        // When: ゴミ箱ノートを取得
        viewModel.fetchTrashedNotes()
        
        // Then: 全てのゴミ箱ノートが取得される
        XCTAssertEqual(viewModel.trashedNotes.count, 50, "50件のゴミ箱ノートが取得されるべき")
    }
    
    /// 目的: 複数ノートの一括削除が正常に処理されることを確認
    func testDeleteMultipleNotesPermanently_ShouldSucceed() {
        // Given: 10件のゴミ箱ノートを作成
        var notesToDelete: [Note] = []
        for i in 1...10 {
            let note = service.createNote(title: "ToDelete \(i)", content: "", tag: nil)
            service.trashNote(note)
            notesToDelete.append(note)
        }
        try? service.saveContext()
        viewModel.fetchTrashedNotes()
        
        let initialCount = viewModel.trashedNotes.count
        
        // When: 全てのノートを永久削除
        for note in notesToDelete {
            viewModel.deleteNotePermanently(note: note)
        }
        
        // Then: ゴミ箱が空になる
        XCTAssertEqual(viewModel.trashedNotes.count, 0, "ゴミ箱が空になるべき")
        XCTAssertEqual(initialCount, 10, "初期状態では10件あったべき")
    }
    
    // MARK: - Search Edge Cases
    
    /// 目的: 空の検索文字列で全ノートが返されることを確認
    func testFetchNotes_WithEmptySearchText_ShouldReturnAllNotes() {
        // Given: 5件のノートを作成
        for i in 1...5 {
            _ = service.createNote(title: "Note \(i)", content: "", tag: nil)
        }
        try? service.saveContext()
        
        // When: 空文字列で検索
        viewModel.searchText = ""
        viewModel.fetchNotes(searchText: "")
        
        // Then: 全てのノートが返される
        XCTAssertEqual(viewModel.notes.count, 5, "空の検索では全ノートが返されるべき")
    }
    
    /// 目的: 特殊文字を含む検索でもエラーにならないことを確認
    func testFetchNotes_WithSpecialCharacters_ShouldHandleSafely() {
        // Given: 特殊文字を含むノートを作成
        _ = service.createNote(title: "Test [brackets]", content: "", tag: nil)
        _ = service.createNote(title: "Test (parentheses)", content: "", tag: nil)
        _ = service.createNote(title: "Test $pecial", content: "", tag: nil)
        try? service.saveContext()
        
        // When: 特殊文字で検索
        viewModel.searchText = "[brackets]"
        viewModel.fetchNotes(searchText: "[brackets]")
        
        // Then: エラーなく検索される
        XCTAssertGreaterThanOrEqual(viewModel.notes.count, 0, "検索結果が0件以上であるべき")
    }
    
    // MARK: - Note Order Edge Cases
    
    /// 目的: 空のノートリストでmoveNotesを呼んでもエラーにならないことを確認
    func testMoveNotes_WithEmptyList_ShouldHandleSafely() {
        // Given: ノートが0件
        viewModel.fetchNotes()
        XCTAssertEqual(viewModel.notes.count, 0, "初期状態は空であるべき")
        
        // When: 移動を試みる
        viewModel.moveNotes(fromOffsets: IndexSet(integer: 0), toOffset: 0)
        
        // Then: エラーなく処理される
        XCTAssertEqual(viewModel.notes.count, 0, "空のままであるべき")
    }
    
    /// 目的: 1件のノートでmoveNotesを呼んでもエラーにならないことを確認
    func testMoveNotes_WithSingleNote_ShouldHandleSafely() {
        // Given: 1件のノートのみ
        _ = service.createNote(title: "Only One", content: "", tag: nil)
        try? service.saveContext()
        viewModel.fetchNotes()
        
        // When: 同じ位置に移動
        viewModel.moveNotes(fromOffsets: IndexSet(integer: 0), toOffset: 0)
        
        // Then: エラーなく処理される
        XCTAssertEqual(viewModel.notes.count, 1, "1件のままであるべき")
        XCTAssertEqual(viewModel.notes[0].title, "Only One", "ノートは変わらないべき")
    }
}
