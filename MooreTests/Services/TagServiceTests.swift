import XCTest
import CoreData
@testable import Moore

final class TagServiceTests: XCTestCase {
    private var persistence: PersistenceController!
    private var context: NSManagedObjectContext!
    private var service: CoreDataNoteService!
    
    override func setUp() {
        super.setUp()
        persistence = PersistenceController(inMemory: true)
        context = persistence.container.viewContext
        service = CoreDataNoteService(context: context)
    }
    
    override func tearDown() {
        service = nil
        context = nil
        persistence = nil
        super.tearDown()
    }
    
    // 目的: createTag() が UUID と name を設定する
    func testCreateTagSetsProperties() throws {
        // Given
        let tag = service.createTag(name: "Work")
        try service.saveContext()
        
        // When
        let fetched = service.fetchTags(predicate: NSPredicate(format: "name == %@", "Work"), sortDescriptors: nil)
        
        // Then
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Work")
        XCTAssertNotNil(fetched.first?.uuid)
    }
    
    // 目的: updateTag() で名称が変更される
    func testUpdateTagChangesName() throws {
        // Given
        let tag = service.createTag(name: "Old")
        try service.saveContext()
        // When
        service.updateTag(tag, newName: "New")
        try service.saveContext()
        // Then
        XCTAssertEqual(tag.name, "New")
    }
    
    // 目的: deleteTag() で削除される
    func testDeleteTagRemovesIt() throws {
        // Given
        let tag = service.createTag(name: "Temp")
        try service.saveContext()
        // When
        service.deleteTag(tag)
        try service.saveContext()
        // Then
        let all = service.fetchTags(predicate: nil, sortDescriptors: nil)
        XCTAssertFalse(all.contains(tag))
    }
}