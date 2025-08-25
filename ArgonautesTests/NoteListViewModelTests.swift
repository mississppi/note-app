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
}
