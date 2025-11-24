import XCTest
import CoreData
@testable import Argonautes

final class CoreDataNoteServiceTests: XCTestCase {

    var service: CoreDataNoteService!
    var persistenceController: PersistenceController!
    var viewContext: NSManagedObjectContext!
    var viewModel: NoteListViewModel!

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        viewContext = persistenceController.container.viewContext
        service = CoreDataNoteService(context: viewContext)
    }
    
    override func tearDown() {
        // 明示的にクリーンアップ
        service = nil
        viewContext = nil
        persistenceController = nil
        super.tearDown()
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
    
    func testDeleteAndFetchNote() throws {
        let title = "Note to delete"
        let content = "This note should be deleted."
        let status = Argonautes.NoteStatus.active
        let noteToDelete = service.createNote(title: title, content: content, status: status, tag: nil)
        try service.saveContext()
        
        var fetchedNotes = service.fetchNotes(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(fetchedNotes.count,1, "削除前はノートが1件存在するべき")
        
        service.deleteNote(noteToDelete)
        
        XCTAssertTrue(viewContext.hasChanges, "ノート削除後、コンテキストに変更があるべき")
        
        try service.saveContext()
        
        fetchedNotes = service.fetchNotes(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(fetchedNotes.count, 0, "削除後はノートが0件であるべき")
    }
    
    func testSearchNotes() throws {
        let note1 = service.createNote(title: "買い物リスト", content: "牛乳、卵、パン", status: .active, tag: nil)
        let note2 = service.createNote(title: "プロジェクトの計画", content: "新しいアプリの構想", status: .active, tag: nil)
        let note3 = service.createNote(title: "旅行の計画", content: "京都、東京、大阪を巡る", status: .active, tag: nil)
        let searchText = "計画"
        let fetchedNotes = service.searchNotes(for: searchText)
        XCTAssertEqual(fetchedNotes.count, 2, "検索結果は2件であるべき")
    }
    
    func testCreateAndFetchTag() throws {
        let tagName = "General"
        let newTag = service.createTag(name: tagName)
        try service.saveContext()
        let fetchTags = service.fetchTags(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(fetchTags.count, 1, "タグ作成後、1件のタグが存在すべき")
        guard let fetchTag = fetchTags.first else {
            XCTFail("作成したタグが取得できませんでした")
            return
        }
        
        XCTAssertEqual(fetchTag.name, tagName, "作成したタグの名前は一致")
        XCTAssertEqual(fetchTag.uuid, newTag.uuid, "作成したタグのUUIDは一致")
    }
    
    func testUpdateAndFetchTag() throws {
        let originalName = "Work"
        let tagToUpdate = service.createTag(name: originalName)
        try service.saveContext()
        
        let newName = "Private"
        service.updateTag(tagToUpdate, newName: newName)
        
        try service.saveContext()
        let fetchTags = service.fetchTags(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(fetchTags.count, 1, "タグ更新後も、タグは1件であるべき")

        guard let updatedTag = fetchTags.first else {
            XCTFail("更新したタグが取得できませんでした")
            return
        }
        XCTAssertEqual(updatedTag.name, newName, "更新されたタグの名前が新しい名前に一致すべき")
    }
    
    func testDeleteAndFetchTag() throws {
        let tagToDelete = service.createTag(name: "General")
        try service.saveContext()
        var fetchedTags = service.fetchTags(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(fetchedTags.count, 1, "タグ作成後、1件のタグが存在すべき")
        
        service.deleteTag(tagToDelete)
        XCTAssertTrue(viewContext.hasChanges, "タグ削除後、コンテキストに変更があるべき")
        try service.saveContext()
        fetchedTags = service.fetchTags(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(fetchedTags.count,0,"削除後はタグが0件であるべき")
    }
    
    func testFetchNotesWithTagPredicate() throws {
        print("----- test start ------")
        let tag1 = try service.createTag(name: "tag1")
        print(tag1)
        let tag2 = try service.createTag(name: "tag2")
        
        let _ = try service.createNote(title: "Note 1", content: "c 1", status: .active, tag: tag1)
        let _ = try service.createNote(title: "Note 2", content: "c 2", status: .active, tag: tag1)
        
        let _ = try service.createNote(title: "Note 3", content: "c 3", status: .active, tag: tag2)
        let _ = try service.createNote(title: "Note 4", content: "c 4", status: .active, tag: tag2)
        
        let predicateForTag1 = NSPredicate(format: "tag == %@", tag1)
        let notesForTag1 = service.fetchNotes(predicate: predicateForTag1, sortDescriptors: nil)
        
        XCTAssertEqual(notesForTag1.count, 2)
        
        let predicateForTag2 = NSPredicate(format: "tag == %@", tag2)
        let notesForTag2 = service.fetchNotes(predicate: predicateForTag2, sortDescriptors: nil)
        
        XCTAssertEqual(notesForTag2.count, 2)
    }

}
