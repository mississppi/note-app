import Foundation
import Combine
import CoreData
import Argonautes

/// ノート一覧画面のビジネスロジックを管理するViewModel
/// 
/// 主な責務:
/// - ノートの一覧表示・検索・フィルタリング
/// - ノートの作成・更新・削除・アーカイブ
/// - タグの管理・切り替え
/// - 自動保存機能（タイトル・コンテンツの変更を監視）
class NoteListViewModel: ObservableObject {
    private enum Constants {
        static let newNoteTitle = "new Note"
        /// 検索テキストのデバウンス時間（ミリ秒）
        static let searchDebounceMilliseconds = 500
        /// タイトル自動保存のデバウンス時間（ミリ秒）
        static let titleDebounceMilliseconds = 500
        /// コンテンツ自動保存のデバウンス時間（秒）
        static let contentDebounceSeconds: TimeInterval  = 1.0
    }
    @Published var notes: [Note] = []
    @Published var tags: [Tag] = []
    @Published var searchText: String = ""

    /// 現在選択されているノート
    /// - Note: `private(set)` により外部からは読み取り専用
    /// - didSet で selectedTitle と selectedContent を自動更新
    @Published private(set) var selectedNote: Note? {
        didSet {
            selectedTitle = selectedNote?.title ?? ""
            selectedContent = selectedNote?.content ?? ""
        }
    }
    @Published var selectedTitle: String = ""
    @Published var selectedContent: String = ""
    @Published var selectedTag: Tag?
    @Published var selectedTagIndex: Int = 0
    
    @Published var showingAddTagModal: Bool = false
    @Published var newTagName: String = ""
    @Published var addTagError: TagError? = nil
    
    @Published var isShowingTrash: Bool = false
    @Published var archivedNotes: [Note] = []
    
    @Published var tagTransitionDirection: TagTransitionDirection = .none

    @Published var isTitleFocused: Bool = false {
        didSet {
            if !isTitleFocused && oldValue {
                normalizeTitle()
            }
        }
    }

    private let noteService: NoteDataService
    private var cancellabels = Set<AnyCancellable>()
    
    init(noteService: NoteDataService) {
        self.noteService = noteService
        
        $searchText
            .debounce(for: .milliseconds(Constants.searchDebounceMilliseconds), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.fetchNotes(searchText: searchText)
            }
            .store(in: &cancellabels)
        
        $selectedTitle
            .debounce(for: .milliseconds(Constants.titleDebounceMilliseconds), scheduler: RunLoop.main)
            .sink { [weak self] title in
                self?.autoSaveTitle(newTitle: title)
            }
            .store(in: &cancellabels)
        
        $selectedContent
            .debounce(for: .seconds(Constants.contentDebounceSeconds), scheduler: RunLoop.main)
            .sink { [weak self] content in
                self?.autoSaveContent(newContent: content)
            }
            .store(in: &cancellabels)
        
        //初回起動時に1件目を選択状態にする
        fetchDataAndSelectFirstNote()
    }
    
    /// ノートを選択する
    /// 
    /// - Parameters:
    ///   - note: 選択するノート（nil の場合は選択解除）
    ///   - userInitiated: ユーザーの明示的な操作による選択かどうか
    /// 
    /// - Note: 選択時の動作
    ///   1. `selectedNote` が更新される
    ///   2. `didSet` で `selectedTitle` と `selectedContent` が自動的に更新される
    ///   3. `$selectedTitle` と `$selectedContent` の Publisher が発火
    ///   4. デバウンス後に `autoSaveTitle` と `autoSaveContent` が呼ばれる
    ///   5. ただし、値が変更されていない場合は実際には保存されない（guard で早期リターン）
    /// 
    /// - Important: userInitiated の使い分け
    ///   - `userInitiated: false`: 
    ///     - リストからのノート選択時（NoteListNoteArea）
    ///     - タグ切り替え時の自動選択（selectPreviousTag, selectNextTag）
    ///     - データ取得後の自動選択（fetchNotes, archiveNote）
    ///     → 選択しただけでは `updatedAt` が更新されない（値が同じため）
    ///   
    ///   - `userInitiated: true`:
    ///     - ノート作成時（addNewNote）
    ///     → 現在は false の場合と動作は同じだが、将来的な拡張のために区別
    ///     → 例: ユーザー操作のログ記録、アナリティクス送信など
    /// 
    /// - SeeAlso: 
    ///   - `NoteListNoteArea.selectionBinding`: リストからの選択で使用（false）
    ///   - `addNewNote()`: ノート作成時に使用（true）
    ///   - `autoSaveTitle(newTitle:)`: タイトル自動保存の実装
    ///   - `autoSaveContent(newContent:)`: コンテンツ自動保存の実装
    func select(note: Note?, userInitiated: Bool) {
        selectedNote = note
    }
    
    func addNewNote() {
        let newNote = noteService.createNote(
            title: Constants.newNoteTitle,
            content: "",
            status: .active,
            tag: selectedTag
        )
        
        self.notes.insert(newNote, at: 0)

        // ユーザ操作なので、userInitiated: true
        select(note: newNote, userInitiated: true)
        
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

            select(note: self.notes.first, userInitiated: false)
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
        
        select(note: self.notes.first, userInitiated: false)
        
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
        
        select(note: nil, userInitiated: false)
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
        self.tagTransitionDirection = .forward
        self.selectedTag = tags[nextIndex]
        
        select(note: nil, userInitiated: false)
        fetchNotes(searchText: "", selectedTag: self.selectedTag)
    }
    
    func addNewTag() {
        let name = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            addTagError = TagError.emptyTagName
            return
        }
        
        let existsTagNames = tags.compactMap{ $0.name }
        if existsTagNames.contains(newTagName) {
            addTagError = TagError.duplicateTag
            return
        }
        
        let newTag = noteService.createTag(name: newTagName)
        
        do {
            try noteService.saveContext()
            addTagError = nil
            newTagName = ""
            self.selectedTag = newTag
            fetchDataAndSelectLastTag()
        } catch {
            addTagError = TagError.unknownError
            print("Failed to save new tag: \(error.localizedDescription)")
        }
    }
    
    func moveNotes(fromOffsets: IndexSet, toOffset: Int) {
        var updated = notes
        updated.move(fromOffsets: fromOffsets, toOffset: toOffset)
        notes = updated
        saveNotesOrder()
    }

    func fetchArchivedNotes() {
        let predicate = NSPredicate(format: "status == %d", NoteStatus.archived.rawValue)
        let sortDescriptors = [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)]
        archivedNotes = noteService.fetchNotes(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func restoreNoteFromArchive(note: Note) {
        noteService.updateNote(note, newTitle:nil, newContent: nil,
            newStatus: .active,
            newTag: nil,
            newCursorPosition: nil,
            newOrder: nil
        )
        do {
            try noteService.saveContext()
            fetchArchivedNotes()
        } catch {
            print("Failed to restore note from archive: \(error.localizedDescription)")
        }
    }

    func deleteNotePermanently(note: Note) {
        noteService.deleteNote(note)
        do {
            try noteService.saveContext()
            fetchArchivedNotes()
        } catch {
            print("Failed to delete note permanently: \(error.localizedDescription)")
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
        
        func autoSaveTitle(newTitle: String) {
            guard let note = selectedNote else {return}
            guard note.title != newTitle else { return }

            noteService.updateNote(note, newTitle: newTitle, newContent: nil, newStatus: nil, newTag: nil, newCursorPosition: nil, newOrder: nil)
            
            do {
                try noteService.saveContext()
            } catch {
                print("autoSaveTitle failed: \(error.localizedDescription)")
            }
        }
        
        func autoSaveContent(newContent: String) {
            guard let note = selectedNote else {return}
            guard note.content != newContent else { return }
            noteService.updateNote(note, newTitle: nil, newContent: newContent, newStatus: nil, newTag: nil, newCursorPosition: nil, newOrder: nil)
            
            do {
                try noteService.saveContext()
            } catch {
                print("autoSaveContent failed: \(error.localizedDescription)")
            }
        }

        func normalizeTitle() {
            print("normalizeTitle called")
            let trimmed = selectedTitle.trimmingCharacters(in: .whitespacesAndNewlines)

            guard selectedTitle != trimmed else { return }

            selectedTitle = trimmed
        }
        
        func fetchDataAndSelectFirstNote() {
            self.notes = noteService.fetchNotes(predicate: nil, sortDescriptors: nil)
            select(note: self.notes.first, userInitiated: false)
        }
        
        func saveNotesOrder() {
            for (index, note) in notes.enumerated() {
                let newOrder = Int64(index)
                if note.order != newOrder {
                    noteService.updateNote(
                        note,
                        newTitle: nil,
                        newContent: nil,
                        newStatus: nil,
                        newTag: nil,
                        newCursorPosition: nil,
                        newOrder: newOrder
                    )
                }
            }
            
            do {
                try noteService.saveContext()
                fetchNotes(searchText: searchText, selectedTag: selectedTag) .self
                
            } catch {
                print("saveNoteOrder failed: \(error.localizedDescription)")
            }
        }
        
        func saveContextIfNeeded(context: NSManagedObjectContext?) {
            guard let ctx = context, ctx.hasChanges else { return }
            do {
                try noteService.saveContext()
            } catch {
                print("Failed to save context:", error)
            }
        }

}
