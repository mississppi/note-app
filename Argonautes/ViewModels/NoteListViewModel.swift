import Foundation
import Combine
import CoreData
import Argonautes

enum TagTransitionDirection {
    case forward
    case backward
    case none
}

class NoteListViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var tags: [Tag] = []
    @Published var searchText: String = ""
    @Published var selectedNote: Note? {
        didSet {
            selectedContent = selectedNote?.content ?? ""
        }
    }
    @Published var selectedContent: String = ""
    @Published var selectedTag: Tag?
    @Published var selectedTagIndex: Int = 0
    
    @Published var showingAddTagModal: Bool = false
    @Published var newTagName: String = ""
    @Published var addTagError: String? = nil
    
    @Published var isShowingTrash: Bool = false
    
    @Published var tagTransitionDirection: TagTransitionDirection = .none

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
        
        $selectedContent
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] content in
                self?.autoSave(newContent: content)
            }
            .store(in: &cancellabels)
        
        //初回起動時に1件目を選択状態にする
        fetchDataAndSelectFirstNote()
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
            fetchNotes(searchText: searchText, selectedTag: selectedTag)
        } catch {
            print("Failed to save new note: \(error.localizedDescription)")
        }
    }
    
    func archiveNote(note: Note){
        noteService.archiveNote(note)
        do {
            try noteService.saveContext()
            fetchNotes(searchText: searchText, selectedTag: selectedTag)
            
            self.selectedNote = self.notes.first
            self.selectedContent = self.selectedNote?.content ?? ""
        } catch {
            print("Failed to save new note: \(error.localizedDescription)")
        }
    }
    
    func deleteNote(note: Note) {
        noteService.deleteNote(note)
        do {
            try noteService.saveContext()
        } catch {
            print("Failed to delete note: \(error.localizedDescription)")
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
    
    func fetchDataAndSelectLastTag() {
        self.tags = noteService.fetchTags(predicate: nil, sortDescriptors: nil)
        
        // 修正点：tags.lastで最後のタグを取得
        if let lastTag = self.tags.last {
            self.selectedTag = lastTag
            self.selectedTagIndex = self.tags.count - 1
            
            fetchNotes(searchText: "", selectedTag: self.selectedTag)
        } else {
            self.selectedTag = nil
            self.selectedTagIndex = 0
            fetchNotes(searchText: "", selectedTag: nil)
        }
    }
    
    func fetchNotes(
        searchText: String = "",
        selectedTag: Tag? = nil,
        statusFilter: NoteStatus = .active
    ) {
        let searchPredicate = createSearchPredicate(for: searchText)
        let tagPredicate = createTagPredicate(for: selectedTag)
        
        let statusPredicate = createStatusPredicate(for: statusFilter)
        
        let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate, tagPredicate, statusPredicate].compactMap { $0 })
        self.notes = noteService.fetchNotes(predicate: finalPredicate, sortDescriptors: [NSSortDescriptor(keyPath: \Note.order, ascending: true)])
        
        self.selectedNote = self.notes.first
    }
    
    func selectPreviousTag() {
        guard let selectedTagIndex = getSelectedTagIndex() else {
            return
        }
        var previousIndex = selectedTagIndex - 1
        if previousIndex < 0 {
            previousIndex = tags.count - 1
        }
        self.tagTransitionDirection = .backward
        self.selectedTag = tags[previousIndex]
        self.selectedNote = nil
        fetchNotes(searchText: "", selectedTag: self.selectedTag)
//        fetchDataAndSelectFirstNote()
    }
    
    func selectNextTag() {
        guard let selectedTagIndex = getSelectedTagIndex() else {
            return
        }
        var nextIndex = selectedTagIndex + 1
        if nextIndex >= tags.count {
            nextIndex = 0
        }
        self.tagTransitionDirection = .forward
        self.selectedTag = tags[nextIndex]
        
        self.selectedNote = nil
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
        
        let newTag = noteService.createTag(name: newTagName)
        
        do {
            try noteService.saveContext()
            addTagError = nil
            newTagName = ""
            self.selectedTag = newTag
//            fetchData()
            fetchDataAndSelectLastTag()
        } catch {
            addTagError = "タグの保存に失敗しました。"
            print("Failed to save new tag: \(error.localizedDescription)")
        }
    }
    
    func toggleTrashDisplay() {
        self.isShowingTrash.toggle()
        print(self.isShowingTrash)
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
    
    func createStatusPredicate(for status: NoteStatus) -> NSPredicate? {
        return NSPredicate(format: "status == %d", status.rawValue)
    }
    
    func getSelectedTagIndex() -> Int? {
        guard let selectedTag = selectedTag,
              let selectedTagIndex = tags.firstIndex(of: selectedTag) else {
            return nil
        }
        return selectedTagIndex
    }
    
    func autoSave(newContent: String) {
        guard let note = selectedNote else {return}
        noteService.updateNote(note, newTitle: nil, newContent: newContent, newStatus: nil, newTag: nil, newCursorPosition: nil, newOrder: nil)
        
        do {
            try noteService.saveContext()
        } catch {
            print("Autosave failed: \(error.localizedDescription)")
        }
    }
    
    func fetchDataAndSelectFirstNote() {
        self.notes = noteService.fetchNotes(predicate: nil, sortDescriptors: nil)
        
        self.selectedNote = self.notes.first
    }
}
