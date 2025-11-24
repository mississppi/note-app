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
    
    // 目的: fetchNotes()を呼ぶと、ViewModelのnotesプロパティが更新され、作成順に取得できることを確認
    func testFetchNotesUpdatesNotesProperty() throws {
        // Given
        let note1 = service.createNote(title: "Test Note 1", content: "", status: .active, tag: nil)
        let note2 = service.createNote(title: "Test Note 2", content: "", status: .active, tag: nil)
        let note3 = service.createNote(title: "Test Note 3", content: "", status: .active, tag: nil)
        try service.saveContext()
        
        // When
        viewModel.fetchNotes()
        
        // Then
        XCTAssertEqual(viewModel.notes.count, 3, "ViewModelのnotesには3件のノート")
        XCTAssertEqual(viewModel.notes[0].title, "Test Note 1", "最初に作成したノートが先頭")
        XCTAssertEqual(viewModel.notes[1].title, "Test Note 2", "2番目に作成したノート")
        XCTAssertEqual(viewModel.notes[2].title, "Test Note 3", "最後に作成したノート")
    }
    
    // 目的: searchTextを指定してfetchNotes()を呼ぶと、タイトルで絞り込まれたノートのみ取得できることを確認
    func testFetchNotesWithSearchTextFiltersNotes() throws {
        // Given: 3件のノートを作成
        _ = service.createNote(title: "Apple", content: "", status: .active, tag: nil)
        _ = service.createNote(title: "Banana", content: "", status: .active, tag: nil)
        _ = service.createNote(title: "Orange", content: "", status: .active, tag: nil)
        try service.saveContext()
        
        // When: "Apple"で検索
        viewModel.searchText = "Apple"
        viewModel.fetchNotes(searchText: viewModel.searchText)
        
        // Then: "Apple"のみ取得される
        XCTAssertEqual(viewModel.notes.count, 1, "検索結果は1件であるべき")
        XCTAssertEqual(viewModel.notes[0].title, "Apple", "検索結果のタイトルが一致すべき")
    }
    
    // 目的: selectedTagを指定してfetchNotes()を呼ぶと、そのタグのノートのみ取得できることを確認
    func testSelectTagFiltersNotes() throws {
        // Given: 2つのタグと、それぞれに紐付くノートを作成
        let tagA = service.createTag(name: "A")
        let tagB = service.createTag(name: "B")
        try service.saveContext()
        
        _ = service.createNote(title: "Note with A", content: "", status: .active, tag: tagA)
        _ = service.createNote(title: "Note with B", content: "", status: .active, tag: tagB)
        try service.saveContext()
        
        // When: tagAでフィルタリング
        viewModel.selectedTag = tagA
        viewModel.fetchNotes(searchText: "", selectedTag: viewModel.selectedTag)
        
        // Then: tagAのノートのみ取得される
        XCTAssertEqual(viewModel.notes.count, 1, "フィルタリング結果は1件であるべき")
        XCTAssertEqual(viewModel.notes[0].title, "Note with A", "フィルタリング結果のタイトルが一致すべき")
    }

    // 目的: archiveNote()を呼ぶと、ノートがアーカイブ状態になり、activeリストから消えることを確認
    func testArchiveNoteUpdatesStatusAndRemovesFromList() throws {
        // Given: 1件のactiveノートを作成
        let noteToArchive = service.createNote(title: "Note to archive", content: "content", status: .active, tag: nil)
        try? service.saveContext()
        
        viewModel.fetchNotes(searchText: "", selectedTag: nil, statusFilter: .active)
        XCTAssertEqual(viewModel.notes.count, 1, "ViewModelのリストには1件のノートが存在すべき")
        
        // When: ノートをアーカイブ
        viewModel.archiveNote(note: noteToArchive)
        
        // Then: ステータスがarchivedになり、activeリストから消える
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

    // 目的: moveNotes()を呼ぶと、ノートの順序が更新されることを確認
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
    
    // 目的: moveNotes()で変更した順序が、永続化されることを確認
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

    // 目的: 同じ位置に移動した場合、何も変更されないことを確認
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

    // 目的: 複数のノートを一度に移動できることを確認
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
