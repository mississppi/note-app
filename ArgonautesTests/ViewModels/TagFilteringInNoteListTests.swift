import XCTest
import CoreData
@testable import Argonautes

final class TagFilteringInNoteListTests: XCTestCase {
    private var persistence: PersistenceController!
    private var context: NSManagedObjectContext!
    private var service: CoreDataNoteService!
    private var viewModel: NoteListViewModel!
    
    override func setUp() {
        super.setUp()
        persistence = PersistenceController(inMemory: true)
        context = persistence.container.viewContext
        service = CoreDataNoteService(context: context)
        viewModel = NoteListViewModel(noteService: service)
    }
    
    override func tearDown() {
        viewModel = nil
        service = nil
        context = nil
        persistence = nil
        super.tearDown()
    }
    
    // 目的: selectedTag + searchText の AND フィルタ
    func testTagAndSearchCombinedFilter() throws {
        // Given
        let tagWork = service.createTag(name: "Work")
        let tagLife = service.createTag(name: "Life")
        _ = service.createNote(title: "Work Swift", content: "", status: .active, tag: tagWork)
        _ = service.createNote(title: "Work Kotlin", content: "", status: .active, tag: tagWork)
        _ = service.createNote(title: "Life Swift", content: "", status: .active, tag: tagLife)
        try service.saveContext()
        
        // When
        viewModel.searchText = "Swift"
        viewModel.selectedTag = tagWork
        viewModel.fetchNotes(searchText: viewModel.searchText, selectedTag: viewModel.selectedTag, statusFilter: .active)
        
        // Then
        XCTAssertEqual(viewModel.notes.count, 1)
        XCTAssertEqual(viewModel.notes.first?.title, "Work Swift")
    }
    
    // 目的: タグ切替で結果が更新される
    func testSwitchingSelectedTagRefreshesList() throws {
        // Given
        let tagA = service.createTag(name: "A")
        let tagB = service.createTag(name: "B")
        _ = service.createNote(title: "Note A1", content: "", status: .active, tag: tagA)
        _ = service.createNote(title: "Note B1", content: "", status: .active, tag: tagB)
        try service.saveContext()
        
        // When
        viewModel.selectedTag = tagA
        viewModel.fetchNotes(searchText: "", selectedTag: viewModel.selectedTag)
        let countA = viewModel.notes.count
        
        viewModel.selectedTag = tagB
        viewModel.fetchNotes(searchText: "", selectedTag: viewModel.selectedTag)
        let countB = viewModel.notes.count
        
        // Then
        XCTAssertEqual(countA, 1)
        XCTAssertEqual(countB, 1)
        XCTAssertEqual(viewModel.notes.first?.tag?.name, "B")
    }
}