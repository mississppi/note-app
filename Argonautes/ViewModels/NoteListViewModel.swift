import Foundation
import Combine
import CoreData
import Argonautes

class NoteListViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var tags: [Tag] = []
    @Published var searchText: String = ""
    @Published var selectedNote: Note?
    @Published var selectedTag: Tag?
    @Published var selectedTagIndex: Int = 0
    
    private let noteService: NoteDataService
    
    init(noteService: NoteDataService) {
        self.noteService = noteService
        fetchData()
    }
    
    func fetchData() {
        print("--- fetchData() started ---")
        self.tags = noteService.fetchTags(predicate: nil, sortDescriptors: nil)
        print("Fetched \(self.tags.count) tags.")
        
        if !self.tags.isEmpty {
            self.selectedTag = self.tags[0]
            self.selectedTagIndex = 0
            fetchNotes(searchText: "", selectedTag: self.selectedTag)
        } else {
            self.selectedTag = nil
            self.selectedTagIndex = 0
            fetchNotes(searchText: "", selectedTag: nil)
        }
        
        print("Total notes after fetch: \(self.notes.count)")
        for note in self.notes {
            print(" - Note Title: \(note.title ?? "No Title")")
        }
        print("--- fetchData() finished ---") // <-- 追加
    }
    
    func fetchNotes(searchText: String = "", selectedTag: Tag? = nil) {
        let searchPredicate = createSearchPredicate(for: searchText)
        let tagPredicate = createTagPredicate(for: selectedTag)
        let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate, tagPredicate].compactMap { $0 })

        self.notes = noteService.fetchNotes(predicate: finalPredicate, sortDescriptors: [NSSortDescriptor(keyPath: \Note.order, ascending: true)])
    }
    
    func selectPreviousTag() {
        guard let selectedTagIndex = getSelectedTagIndex() else {
            return
        }
        var previousIndex = selectedTagIndex - 1
        if previousIndex < 0 {
            previousIndex = tags.count - 1
        }
        self.selectedTag = tags[previousIndex]
        fetchNotes(searchText: "", selectedTag: self.selectedTag)
    }
    
    func selectNextTag() {
        guard let selectedTagIndex = getSelectedTagIndex() else {
            return
        }
        var nextIndex = selectedTagIndex + 1
        if nextIndex >= tags.count {
            nextIndex = 0
        }
        self.selectedTag = tags[nextIndex]
        fetchNotes(searchText: "", selectedTag: self.selectedTag)
    }
    

}

private extension NoteListViewModel {
    func createSearchPredicate(for searchText: String) -> NSPredicate? {
        guard !searchText.isEmpty else { return nil }
        return NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@", searchText, searchText)
    }
    
    func createTagPredicate(for tag: Tag?) -> NSPredicate? {
        guard let tag = tag else {return nil}
        return NSPredicate(format: "tag == %@", tag)
    }
    
    func getSelectedTagIndex() -> Int? {
        guard let selectedTag = selectedTag,
              let selectedTagIndex = tags.firstIndex(of: selectedTag) else {
            return nil
        }
        return selectedTagIndex
    }
}
