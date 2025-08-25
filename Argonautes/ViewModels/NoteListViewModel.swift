import Foundation
import Combine
import CoreData
import Argonautes

class NoteListViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var searchText: String = ""
    @Published var selectedNote: Note?
    
    private let noteService: NoteDataService
    
    init(noteService: NoteDataService) {
        self.noteService = noteService
        fetchNotes()
    }
    
    func fetchNotes(searchText: String = "") {
        let predicate = searchText.isEmpty ? nil : NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@", searchText, searchText)
        self.notes = noteService.fetchNotes(predicate: predicate, sortDescriptors: [NSSortDescriptor(keyPath: \Note.order, ascending: true)])
    }
}

