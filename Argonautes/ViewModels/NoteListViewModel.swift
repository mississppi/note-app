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
    
    @Published var showingAddTagModal: Bool = false
    @Published var newTagName: String = ""
    @Published var addTagError: String? = nil
    
    
    private let noteService: NoteDataService
    private var cancellabels = Set<AnyCancellable>()
    
    init(noteService: NoteDataService) {
        self.noteService = noteService
        
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.fetchNotes(searchText: searchText)
            }
            .store(in: &cancellabels)
        
        fetchData()
    }
    
    func addNewNote() {
        let newNote = noteService.createNote(
            title: "new Note",
            content: "",
            status: .active,
            tag: selectedTag
        )
        
        self.notes.insert(newNote, at: 0)
        
        self.selectedNote = newNote
        
        do {
            try noteService.saveContext()
        } catch {
            print("Failed to save new note: \(error.localizedDescription)")
        }
    }
    
    func fetchData() {
        self.tags = noteService.fetchTags(predicate: nil, sortDescriptors: nil)
        if !self.tags.isEmpty {
            self.selectedTag = self.tags[0]
            self.selectedTagIndex = 0
            fetchNotes(searchText: "", selectedTag: self.selectedTag)
        } else {
            self.selectedTag = nil
            self.selectedTagIndex = 0
            fetchNotes(searchText: "", selectedTag: nil)
        }
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
    
    func addNewTag() {
        guard !newTagName.isEmpty else {
            addTagError = "タグ名を入力してください"
            return
        }
        
        let existsTagNames = tags.compactMap{ $0.name }
        if existsTagNames.contains(newTagName) {
            addTagError = "このタグはすでに存在しています"
            return
        }
        
        _ = noteService.createTag(name: newTagName)
        
        do {
            try noteService.saveContext()
            addTagError = nil
            newTagName = ""
            fetchData()
        } catch {
            addTagError = "タグの保存に失敗しました。"
            print("Failed to save new tag: \(error.localizedDescription)")
        }
        
        
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
