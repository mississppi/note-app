//
//  MockNoteDataService.swift
//  ArgonautesTests
//
//  Created by KOSUKE SAKURAI on 2025/07/26.
//

import Foundation
import CoreData
import Argonautes

class MockNoteDataService: NoteDataService {
    var mockNotes: [Note] = []
    var mockTags: [Tag] = []
    
    var saveContextCalled = false
    var createNoteCalled = false
    var deleteNoteCalled = false
    var updateNoteCalled = false
    var fetchNotesCalled = false
    var fetchTagsCalled = false
    var createTagCalled = false
    var deleteTagCalled = false
    
    init() {}
    
    func fetchNotes(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Note] {
        fetchNotesCalled = true
        return mockNotes
    }
    
    func createNote(title: String, content: String, status: NoteStatus, tag: Tag?) -> Note{
        createNoteCalled = true
        
        let newNote = Note(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        newNote.title = title
        newNote.content = content
        newNote.status = status.rawValue
        newNote.tag = tag
        newNote.createdAt = Date()
        newNote.updatedAt = Date()
        newNote.uuid = UUID()
        newNote.cursorPosition = 0
        
        return newNote
    }
    
    func updateNote(
        _ note: Note,
        newTitle: String?,
        newContent: String?,
        newStatus: NoteStatus?,
        newTag: Tag?,
        newCursorPosition: Int?
    ) {
        updateNoteCalled = true
        if let newTitle = newTitle {note.title = newTitle}
        if let newContent = newContent {note.content = newContent}
        if let newStatus = newStatus {note.status = newStatus.rawValue}
        if let newTag = newTag {note.tag = newTag}
        if let newCursorPosition = newCursorPosition {note.cursorPosition = Int32(newCursorPosition)}
        note.updatedAt = Date()
    }
    
    func deleteNote(_ note: Note) {
        deleteNoteCalled = true
    }
    
    func fetchTags(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Tag] {
        fetchTagsCalled = true
        return mockTags
    }
    
    func createTag(name: String) -> Tag {
        createTagCalled = true
        let newTag = Tag(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        newTag.name = name
        newTag.uuid = UUID()
        mockTags.append(newTag)
        return newTag
    }
    
    func deleteTag(_ tag: Tag) {
        deleteTagCalled = true
        mockTags.removeAll(where: { $0.uuid == tag.uuid })
    }
    
    static func createMockNote(
        context: NSManagedObjectContext,
        title: String = "TestNote",
        content: String = "This is a tes note content",
        status: NoteStatus = .active,
        tag: Tag? = nil,
        uuid: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        cursorPosition: Int = 0
    ) -> Note {
        let note = Note(context: context)
        note.title = title
        note.content = content
        note.status = status.rawValue
        note.tag = tag
        note.createdAt = createdAt
        note.updatedAt = updatedAt
        note.uuid = uuid
        note.cursorPosition = Int32(cursorPosition)
        return note
    }
    
    static func createMockTag(
        context: NSManagedObjectContext,
        name: String = "General",
        uuid: UUID = UUID()
    ) -> Tag {
        let tag = Tag(context: context)
        tag.name = name
        tag.uuid = uuid
        return tag
    }
}
