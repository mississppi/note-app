import XCTest
import CoreData
@testable import Argonautes
extension PersistenceController {
    static var inMemory: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
}

final class CoreDataNoteServiceTests: XCTestCase {

    var service: CoreDataNoteService!
    var persistenceController: PersistenceController!
    var viewContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        persistenceController = PersistenceController.inMemory
        viewContext = persistenceController.container.viewContext
        service = CoreDataNoteService(context: self.viewContext)
    }

    override func tearDownWithError() throws {
        persistenceController = nil
        self.viewContext = nil
        self.service = nil
    }

    func testExample() throws {
        print("hello")
    }
    
    func testCreateAndFetchNote() throws {
        let title = "Test Note Title"
        let content = "Test Note Content"
        let status = Argonautes.NoteStatus.active
        let newNote = service.createNote(title: title, content: content, status: status, tag: nil)
        XCTAssertTrue(viewContext.hasChanges, "ノート作成後、コンテキストに変更があるべき")
        try service.saveContext()
        
        let fetchedNotes = service.fetchNotes(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(fetchedNotes.count, 1 , "保存後、ノートが1件増えているべき")
        XCTAssertNotNil(fetchedNotes.first, "取得したノートがnilではないことを確認")
        
        guard let fetchedNote = fetchedNotes.first else {
            return
        }
        
        XCTAssertEqual(fetchedNote.uuid, newNote.uuid, "取得したノートのUUIDが一致すべき")
    }
    
    func testUpdateAndFetchNote() throws {
        let initialTitle = "original Title"
        let initialContent = "This is the original content ."
        let initialStatus = Argonautes.NoteStatus.active
        let newNote = service.createNote(
            title: initialTitle,
            content: initialContent,
            status: initialStatus,
            tag: nil
        )
        
        try service.saveContext()
        
        let fetchedNotesAfterCreate = service.fetchNotes(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(fetchedNotesAfterCreate.count, 1, "ノート作成後、1件のノートが存在すべき")
        
        guard let createdNote = fetchedNotesAfterCreate.first else {
            XCTFail("作成したノートが取得できませんでした")
            return
        }
        
        XCTAssertEqual(createdNote.title, initialTitle, "作成したノートのタイトルが一致すべき")
        XCTAssertEqual(createdNote.content, initialContent, "作成したノートのコンテンツが一致すべき")
        
        let newTitle = "Updated Title"
        let newContent = "This is the updated content."
        
        service.updateNote(
            createdNote,
            newTitle: newTitle,
            newContent: newContent,
            newStatus: Argonautes.NoteStatus.active,
            newTag: nil,
            newCursorPosition: 10,
            newOrder: 3
        )
        
        try service.saveContext()
        
        let fetchedNotesAfterUpdate = service.fetchNotes(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(fetchedNotesAfterUpdate.count, 1, "ノート更新後も、ノートは1件であるべき")
        
        guard let updatedNote = fetchedNotesAfterUpdate.first else {
            XCTFail("作成したノートが取得できませんでした")
            return
        }
        
        XCTAssertEqual(updatedNote.title, newTitle, "更新されたノートのタイトルが一致すべき")
        XCTAssertEqual(updatedNote.content, newContent, "更新されたノートのコンテンツが一致すべき")
    }

}
