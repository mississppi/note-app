import XCTest
import CoreData
@testable import Moore

final class NoteListViewModel_DiagnosticTests: XCTestCase {
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

    func testDiagnosticLogsOnInitAndFetch() throws {
        // Create a tag to ensure fetchData sets a selectedTag
        let tag = service.createTag(name: "DiagTag")
        _ = service.createNote(title: "DiagNote", content: "", tag: tag)
        try service.saveContext()

        // Recreate viewModel to trigger init/fetchData
        viewModel = NoteListViewModel(noteService: service)
        // Call fetch explicitly
        viewModel.fetchNotes(searchText: "", selectedTag: viewModel.selectedTag)
        // Attach diagnostic info so it appears in the xcresult bundle for CLI parsing
        let diag = "[DIAG][NoteListViewModel] selectedTag='\(viewModel.selectedTag?.name ?? "nil")' notesCount=\(viewModel.notes.count)"
        add(XCTAttachment(string: diag))
        let titles = viewModel.notes.map { $0.title ?? "(no title)" }.joined(separator: ",")
        add(XCTAttachment(string: "[DIAG][NoteListViewModel] noteTitles='") )
        add(XCTAttachment(string: titles))
        // Assert that notes were fetched
        XCTAssertFalse(viewModel.notes.isEmpty)
    }
}
