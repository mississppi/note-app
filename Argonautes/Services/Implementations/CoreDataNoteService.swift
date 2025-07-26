import Foundation // UUID, Date, Errorなどの基本型のため
import CoreData   // NSPredicate, NSSortDescriptor, NSManagedObjectContext (実装側で必要), NSManagedObject (型として必要)

enum NoteStatus: Int16, CaseIterable, Identifiable {
    case atcive = 0
    case archived = 1
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .atcive:
            return "アクティブ"
        case .archived:
            return "アーカイブ済み"
        }
    }
}

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
