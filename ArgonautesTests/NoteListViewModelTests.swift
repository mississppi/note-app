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
}
