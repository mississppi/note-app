import Foundation
import CoreData

class CoreDataNoteService: NoteDataService {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchNotes(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?)-> [Note] {
        return []
    }
    
    func createNote(title: String, content: String, status: NoteStatus, tag: Tag?) {
        fatalError("createNote() has not been implemented")
    }
    
    func updateNote(
        _ note: Note,
        newTitle: String?,
        newContent: String?,
        newStatus: NoteStatus?,
        newTag: Tag?,
        newCursorPosition: Int?
    ) {
        fatalError("updateNote() has not been implemented")
    }
    
    func deleteNote(_ note: Note){
        fatalError("deleteNote() has not been implemented")
    }
    
    func saveContext() throws {
        fatalError("deleteNote() has not been implemented")
    }
    
    func fetchTag(predince: NSPredicate?, sortDescriptos: [NSSortDescriptor]?) {
        fatalError("deleteNote() has not been implemented")
    }
    
    func createTag(name: String) -> Tag {
        fatalError("deleteNote() has not been implemented")
    }
    
    func deleteTag(_ tag: Tag) {
        fatalError("deleteNote() has not been implemented")
    }
}
