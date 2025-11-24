import Foundation
import CoreData

class CoreDataNoteService: NoteDataService {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchNotes(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?)-> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching notes: \(error)")
            return []
        }
    }
    
    func createNote(title: String, content: String, status: NoteStatus, tag: Tag?) -> Note{
        let newNote = Note(context: context)

        newNote.title = title
        newNote.content = content
        newNote.createdAt = Date()
        newNote.updatedAt = Date()
        newNote.uuid = UUID()
        newNote.cursorPosition = Int32(0)
        newNote.status = status.rawValue

        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Note.order, ascending: false)]
        fetchRequest.fetchLimit = 1

        if let maxOrderNote = try? context.fetch(fetchRequest).first {
            newNote.order = maxOrderNote.order + 1
        } else {
            newNote.order = 1
        }
        newNote.tag = tag
        
        return newNote
    }
    
    func updateNote(
        _ note: Note,
        newTitle: String?,
        newContent: String?,
        newStatus: NoteStatus?,
        newTag: Tag?,
        newCursorPosition: Int?,
        newOrder: Int64?
    ) {
        var shouldUpdateTimeStamp = false
        
        if let newTitle = newTitle, newTitle != note.title{
            print("DEBUG: title changed: ''\(note.title ?? "")'' -> ''\(newTitle)''")
            note.title = newTitle
            shouldUpdateTimeStamp = true
        }
        
        if let newContent = newContent, newContent != note.content {
            note.content = newContent
            shouldUpdateTimeStamp = true
        }
        
        if let newStatus = newStatus {
            note.status = newStatus.rawValue
        }
        
        if let newTag = newTag {
            note.tag = newTag
        }
        
        if let newCursorPosition = newCursorPosition {
            note.cursorPosition = Int32(newCursorPosition)
        }
        
        if let newOrder = newOrder {
            note.order = newOrder
        }
        
        if shouldUpdateTimeStamp {
            note.updatedAt = Date()
        }
    }
    
    func archiveNote(_ note: Note) {
        note.status = NoteStatus.archived.rawValue

    }
    
    func deleteNote(_ note: Note){
        context.delete(note)
    }
    
    func searchNotes(for searchText: String) -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        
        if !searchText.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[c] %@", searchText)
        }
        do {
            return try context.fetch(request)
        } catch {
            print("Error searching notes: \(error)")
            return []
        }
    }
    
    func saveContext() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("エラーが発生しました \(error.localizedDescription)")
                print("Core Data save error \(error.localizedDescription)")
                throw error
            }
        } else {
            print("haschangeできない:")
            print("DEBUG: no changes in ct to save.")
        }
    }
    
    func fetchTags(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Tag] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching tags: \(error)")
            return []
        }
    }
    
    func createTag(name: String) -> Tag {
        let newTag = Tag(context: context)
        newTag.name = name
        newTag.uuid = UUID()
        return newTag
    }
    
    func updateTag(_ tag: Tag, newName: String) {
        tag.name = newName
    }
    
    func deleteTag(_ tag: Tag) {
        context.delete(tag)
    }
}
