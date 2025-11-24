import XCTest
import CoreData
@testable import Argonautes

class NoteListViewModelTests: XCTestCase{
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
        // 明示的にクリーンアップ
        viewModel = nil
        service = nil
        viewContext = nil
        persistenceController = nil
        super.tearDown()
    }
    
    func testFetchNotesUpdatesNotesProperty() throws {
        // Given
        let note1 = service.createNote(title: "Test Note 1", content: "", status: .active, tag: nil)
        let note2 = service.createNote(title: "Test Note 2", content: "", status: .active, tag: nil)
        let note3 = service.createNote(title: "Test Note 3", content: "", status: .active, tag: nil)
        try service.saveContext()
        
        // デバッグ: order の値を確認
        print("DEBUG note1.order:", note1.order)
        print("DEBUG note2.order:", note2.order)
        print("DEBUG note3.order:", note3.order)
        
        // When
        viewModel.fetchNotes()
        
        // デバッグ: 取得後の順序を確認
        print("DEBUG notes[0].title:", viewModel.notes[0].title ?? "nil", "order:", viewModel.notes[0].order)
        print("DEBUG notes[1].title:", viewModel.notes[1].title ?? "nil", "order:", viewModel.notes[1].order)
        print("DEBUG notes[2].title:", viewModel.notes[2].title ?? "nil", "order:", viewModel.notes[2].order)
        
        // Then
        XCTAssertEqual(viewModel.notes.count, 3, "ViewModelのnotesには3件のノート")
        XCTAssertEqual(viewModel.notes[0].title, "Test Note 1", "最初に作成したノートが先頭")
        XCTAssertEqual(viewModel.notes[1].title, "Test Note 2", "2番目に作成したノート")
        XCTAssertEqual(viewModel.notes[2].title, "Test Note 3", "最後に作成したノート")
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
        // Given
        let noteToArchive = service.createNote(title: "Note to archive", content: "content", status: .active, tag: nil)
        try? service.saveContext()
        
        viewModel.fetchNotes(searchText: "", selectedTag: nil, statusFilter: .active)
        XCTAssertEqual(viewModel.notes.count, 1, "ViewModelのリストには1件のノートが存在すべき")
        
        print("DEBUG: Before archive - notes count:", viewModel.notes.count)
        print("DEBUG: Before archive - note status:", noteToArchive.status)
        
        // When
        viewModel.archiveNote(note: noteToArchive)
        
        print("DEBUG: After archive - notes count:", viewModel.notes.count)
        print("DEBUG: After archive - note status:", noteToArchive.status)
        print("DEBUG: After archive - searchText:", viewModel.searchText)
        print("DEBUG: After archive - selectedTag:", viewModel.selectedTag as Any)
        
        // Then
        // 1. DB上にはノートが残っている
        let allNotesInDB = service.fetchNotes(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(allNotesInDB.count, 1, "DB上のノート総数はアーカイブ後も1件のままであるべき")
        
        // 2. ステータスがarchivedになっている
        let archivedNote = allNotesInDB.first!
        XCTAssertEqual(archivedNote.status, NoteStatus.archived.rawValue, "ノートのステータスが.archived (1) になっているべき")
        
        // 3. ViewModelのリストから消えた
        XCTAssertEqual(viewModel.notes.count, 0, "ViewModelのリストからアーカイブされたノートは消えているべき")
        
        // 4. selectedNoteがnilになった
        XCTAssertNil(viewModel.selectedNote, "リストが空になったため、selectedNoteはnilであるべき")
    }


    // MARK: - Note Reordering Tests

    func testMoveNoteUpdatesOrder() {
        // Given
        let note1 = service.createNote(title: "Note 1", content: "", status: .active, tag: nil)
        let note2 = service.createNote(title: "Note 2", content: "", status: .active, tag: nil)
        let note3 = service.createNote(title: "Note 3", content: "", status: .active, tag: nil)
        try? service.saveContext()
        
        viewModel.fetchNotes()
        
        // When: note3 を先頭に移動 (index 2 → 0)
        viewModel.moveNotes(fromOffsets: IndexSet(integer: 2), toOffset: 0)
        
        // Then
        XCTAssertEqual(viewModel.notes.count, 3, "ノート数は変わらないべき")
        XCTAssertEqual(viewModel.notes[0].title, "Note 3", "移動後の順序が正しいべき")
        XCTAssertEqual(viewModel.notes[1].title, "Note 1", "移動後の順序が正しいべき")
        XCTAssertEqual(viewModel.notes[2].title, "Note 2", "移動後の順序が正しいべき")
    }
    
    func testSaveNotesOrderPersistsChanges() {
        // Given
        let note1 = service.createNote(title: "Note 1", content: "", status: .active, tag: nil)
        let note2 = service.createNote(title: "Note 2", content: "", status: .active, tag: nil)
        try? service.saveContext()
        
        viewModel.fetchNotes()
        
        // 順序を確認
        XCTAssertEqual(viewModel.notes[0].title, "Note 1")
        XCTAssertEqual(viewModel.notes[1].title, "Note 2")
        
        // When: 順序を入れ替えて保存
        viewModel.moveNotes(fromOffsets: IndexSet(integer: 1), toOffset: 0)
        // moveNotes は内部で saveNotesOrder を呼ぶので、明示的な呼び出しは不要
        
        // Then: 新しいViewModelでも順序が保持されている
        let newViewModel = NoteListViewModel(noteService: service)
        newViewModel.fetchNotes()
        
        XCTAssertEqual(newViewModel.notes.count, 2, "ノート数は変わらないべき")
        XCTAssertEqual(newViewModel.notes[0].title, "Note 2", "順序が永続化されているべき")
        XCTAssertEqual(newViewModel.notes[1].title, "Note 1", "順序が永続化されているべき")
    }

    func testMoveNoteToSamePositionDoesNothing() {
        // Given
        let note1 = service.createNote(title: "Note 1", content: "", status: .active, tag: nil)
        let note2 = service.createNote(title: "Note 2", content: "", status: .active, tag: nil)
        try? service.saveContext()
        
        viewModel.fetchNotes()
        let originalOrder = viewModel.notes.map { $0.title }
        
        // When: 同じ位置に移動
        viewModel.moveNotes(fromOffsets: IndexSet(integer: 0), toOffset: 0)
        
        // Then: 順序は変わらない
        XCTAssertEqual(viewModel.notes.map { $0.title }, originalOrder, "順序が変わらないべき")
    }

    func testMoveMultipleNotesAtOnce() {
        // Given
        let note1 = service.createNote(title: "Note 1", content: "", status: .active, tag: nil)
        let note2 = service.createNote(title: "Note 2", content: "", status: .active, tag: nil)
        let note3 = service.createNote(title: "Note 3", content: "", status: .active, tag: nil)
        let note4 = service.createNote(title: "Note 4", content: "", status: .active, tag: nil)
        try? service.saveContext()
        
        viewModel.fetchNotes()
        
        // When: index 1,2 を先頭に移動
        viewModel.moveNotes(fromOffsets: IndexSet([1, 2]), toOffset: 0)
        
        // Then
        XCTAssertEqual(viewModel.notes[0].title, "Note 2", "複数移動後の順序が正しいべき")
        XCTAssertEqual(viewModel.notes[1].title, "Note 3", "複数移動後の順序が正しいべき")
        XCTAssertEqual(viewModel.notes[2].title, "Note 1", "複数移動後の順序が正しいべき")
        XCTAssertEqual(viewModel.notes[3].title, "Note 4", "複数移動後の順序が正しいべき")
    }
}
