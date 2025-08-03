import Foundation
import CoreData

protocol NoteDataService: AnyObject {

    func fetchNotes(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Note]
    
    func createNote(title: String, content: String, status: NoteStatus, tag: Tag?) -> Note
    
    func updateNote(
        _ note: Note,
        newTitle: String?,
        newContent: String?,
        newStatus: NoteStatus?,
        newTag: Tag?,
        newCursorPosition: Int?,
        newOrder: Int64?
    )
    
    func deleteNote(_ note: Note)
    
    func saveContext() throws
    
    func fetchTags(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Tag]
    
    func createTag(name: String) -> Tag
    
    func deleteTag(_ tag: Tag)

}
