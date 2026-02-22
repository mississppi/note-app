import Foundation
import CoreData
import Logger

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
            let results = try context.fetch(request)
            return results
        } catch {
            Logger.error("🟡 ❌ Error fetching notes: \(error)")
            Logger.debug("🟡 ===== CoreDataNoteService.fetchNotes END (ERROR) =====")
            return []
        }
    }
    
    func createNote(
        title: String, 
        content: String, 
        tag: Tag?
    ) -> Note {
        let newNote = Note(context: context)

        newNote.title = title
        newNote.content = content
        newNote.createdAt = Date()
        newNote.updatedAt = Date()
        newNote.uuid = UUID()
        newNote.cursorPosition = Int32(0)

        newNote.isTrashed = false
        newNote.trashedAt = nil
        newNote.isLock = false

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
        newTag: Tag?,
        newCursorPosition: Int?,
        newOrder: Int64?
    ) {
        var shouldUpdateTimeStamp = false
        
        if let newTitle = newTitle, newTitle != note.title{
            note.title = newTitle
            shouldUpdateTimeStamp = true
        }
        
        if let newContent = newContent, newContent != note.content {
            note.content = newContent
            shouldUpdateTimeStamp = true
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

    func toggleLock(_ note: Note) {
        note.isLock.toggle()
        note.updatedAt = Date()
    }

    func trashNote(_ note: Note) {
        note.isTrashed = true
        note.trashedAt = Date()
        note.deletedTagName = note.tag?.name
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
            Logger.error("Error searching notes: \(error)")
            return []
        }
    }
    
    func saveContext() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                Logger.error("エラーが発生しました \(error.localizedDescription)")
                Logger.error("Core Data save error \(error.localizedDescription)")
                throw error
            }
        }
    }
    
    func fetchTags(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Tag] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(request)
        } catch {
            Logger.error("Error fetching tags: \(error)")
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
