import Testing
import Foundation
import CoreData
import Argonautes

struct CoreDataNoteServiceTests {
    
    var coreDataStack: NSPersistentContainer!
    var service: CoreDataNoteService!

    init() throws {
        self.coreDataStack = NSPersistentContainer(name: "Argonautes")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        self.coreDataStack.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        self.coreDataStack.loadPersistentStores { (storeDescription, error) in
            loadError = error
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + 5.0)
        
        if let error = loadError {
            throw error
        }
        self.service = CoreDataNoteService(context: coreDataStack.viewContext)
        
    }
    
    @Test func testFetchNoteReturnsEmptyArrayWhenNoNotes() async throws {

    }

}
