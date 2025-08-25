import XCTest
import SwiftUI
import CoreData
@testable import Argonautes

final class NoteListViewTests: XCTestCase {
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
        // テスト後にリソースを解放
        viewModel = nil
        service = nil
        viewContext = nil
        viewModel = nil
    }
}
