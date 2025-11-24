import XCTest
import CoreData
@testable import Argonautes

class NoteListViewModelTests: XCTestCase{
    var service: CoreDataNoteService!
    var persistenceController: PersistenceController!
    var viewContext: NSManagedObjectContext!
    var viewModel: NoteListViewModel!
    
    override func setUpWithError() throws {
        persistenceController = PersistenceController.inMemory
        viewContext = persistenceController.container.viewContext
        service = CoreDataNoteService(context: self.viewContext)
        viewModel = NoteListViewModel(noteService: service)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        service = nil
        viewContext = nil
    }
    
    func testFetchNotesUpdatesNotesProperty() throws {
        let note1 = service.createNote(title: "Test Note 1", content: "", status: .active, tag: nil)
        let note2 = service.createNote(title: "Test Note 2", content: "", status: .active, tag: nil)
        let note3 = service.createNote(title: "Test Note 3", content: "", status: .active, tag: nil)
        try service.saveContext()
        
        viewModel.fetchNotes()
        
        XCTAssertEqual(viewModel.notes.count, 3, "ViewModelのnotesには3件のノート")
        XCTAssertEqual(viewModel.notes[0].title, "Test Note 3", "ViewModelのnotesプロパティのタイトルが一致すべき")
        XCTAssertEqual(viewModel.notes[1].title, "Test Note 2", "ViewModelのnotesプロパティのタイトルが一致すべき")
    }
    
    func testFetchNotesWithSearchTextFiltersNotes() throws {
        // 1. ノートを3件作成し、保存
        _ = service.createNote(title: "Apple", content: "", status: .active, tag: nil)
        _ = service.createNote(title: "Banana", content: "", status: .active, tag: nil)
        _ = service.createNote(title: "Orange", content: "", status: .active, tag: nil)
        try service.saveContext()
        
        viewModel.searchText = "Apple"
        viewModel.fetchNotes(searchText: viewModel.searchText)
        
        XCTAssertEqual(viewModel.notes.count, 1, "検索結果は1件であるべき")
        XCTAssertEqual(viewModel.notes[0].title, "Apple", "検索結果のタイトルが一致すべき")
    }
    
    func testSelectTagFiltersNotes() throws {
        // 1. タグとノートをセットアップ
        let tagA = service.createTag(name: "A")
        let tagB = service.createTag(name: "B")
        try service.saveContext()
        
        _ = service.createNote(title: "Note with A", content: "", status: .active, tag: tagA)
        _ = service.createNote(title: "Note with B", content: "", status: .active, tag: tagB)
        try service.saveContext()
        
        viewModel.selectedTag = tagA
        viewModel.fetchNotes(searchText: "", selectedTag: viewModel.selectedTag)
        
        XCTAssertEqual(viewModel.notes.count, 1, "フィルタリング結果は1件であるべき")
        XCTAssertEqual(viewModel.notes[0].title, "Note with A", "フィルタリング結果のタイトルが一致すべき")
    }

        func testArchiveNoteUpdatesStatusAndRemovesFromList() throws {
        // MARK: Given (前提条件: ノートの準備)
        let title = "Note to archive"
        let status = Argonautes.NoteStatus.active
        
        // 1. ノートを作成し、保存する
        let noteToArchive = service.createNote(title: title, content: "content", status: status, tag: nil)
        try service.saveContext()
        
        // 2. ViewModelを初期化し、ノートをロード（この時点でリストには1件あるはず）
        let initialNotes = service.fetchNotes(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(initialNotes.count, 1, "アーカイブ前はノートが1件存在するべき")

        // NOTE: ViewModelのテストなので、ViewModelを初期化し、データ取得をシミュレート
        // ViewModelのコンテキスト（Service）とテストデータ（Service）を接続
        viewModel = NoteListViewModel(noteService: service)
        viewModel.fetchNotes(searchText: "", selectedTag: nil, statusFilter: .active) // アクティブノートのみをロード

        XCTAssertEqual(viewModel.notes.count, 1, "ViewModelのリストには1件のノートが存在すべき")
        
        // MARK: When (操作を実行: アーカイブ)
        // 3. ノートをアーカイブする
        viewModel.archiveNote(note: noteToArchive) // ViewModelのメソッドを呼び出す
        
        // MARK: Then (結果を検証)
        
        // 1. ノートはデータベースから消えていないことを確認 (Serviceから全件取得)
        let allNotesInDB = service.fetchNotes(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(allNotesInDB.count, 1, "DB上のノート総数はアーカイブ後も1件のままであるべき")

        // 2. ステータスがアーカイブ済みになっていることを確認 (ビジネスロジックの検証)
        let archivedNote = try XCTUnwrap(allNotesInDB.first)
        XCTAssertEqual(archivedNote.status, Argonautes.NoteStatus.archived.rawValue, "ノートのステータスが.archived (1) になっているべき")

        // 3. ViewModelのリストからノートが消えたことを確認 (UIロジックの検証)
        XCTAssertEqual(viewModel.notes.count, 0, "ViewModelのリストからアーカイブされたノートは消えているべき")
        
        // 4. selectedNoteが新しい先頭ノートに設定されていることを確認（ここでは0件なのでnil）
        XCTAssertNil(viewModel.selectedNote, "リストが空になったため、selectedNoteはnilであるべき")
    }
}
