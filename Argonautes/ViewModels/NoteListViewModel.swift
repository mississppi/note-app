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
    
    // MARK: - Published Properties (Note List Management)
    @Published var notes: [Note] = []
    @Published var searchText: String = ""

    /// 現在選択されているノート
    /// - Note: `private(set)` により外部からは読み取り専用
    /// - didSet で selectedTitle と selectedContent を自動更新
    @Published private(set) var selectedNote: Note? {
        didSet {
            selectedTitle = selectedNote?.title ?? ""
            selectedContent = selectedNote?.content ?? ""
            // selectedNoteの変更に応じてdetailContentTypeを更新
            updateDetailContentType()
        }
    }

    // Mark: - Published Properties (Note Detail Management)
    @Published var selectedTitle: String = ""
    @Published var selectedContent: String = ""

    // タイトル入力欄のフォーカス状態
    @Published var isTitleFocused: Bool = false {
        didSet {
            if !isTitleFocused && oldValue {
                normalizeTitle()
            }
        }
    }

    // MARK: - Published Properties (Tag Management)
    @Published var tags: [Tag] = []
    @Published var selectedTag: Tag?
    @Published var selectedTagIndex: Int = 0
    @Published var tagTransitionDirection: TagTransitionDirection = .none

    @Published var isShowingAddTagSheet = false
    @Published var newTagName: String = ""
    @Published var addTagError: TagError? = nil

    // MARK: - Tag Editing State
    @Published var isShowingTagEditSheet = false
    @Published var editTagName: String = ""
    @Published var editTagError: TagError? = nil

    // MARK: - Published Properties (UI State)

    //Detail領域に表示するコンテンツの種類
    @Published private(set) var detailContentType: DetailContentType = .empty
    
    @Published var isShowingTrash: Bool = false {
        didSet {
            // isShowingTrashの変更に応じてdetailContentTypeを更新
            updateDetailContentType()
        }
    }
    @Published var archivedNotes: [Note] = []
    
    // MARK: - Private Properties

    private let noteService: NoteDataService
    private var cancellabels = Set<AnyCancellable>()

    // MARK: - Initialization    
    init(noteService: NoteDataService) {
        self.noteService = noteService
        
        $searchText
            .debounce(for: .milliseconds(NoteListViewModelConstants.searchDebounceMilliseconds), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.fetchNotes(searchText: searchText)
            }
            .store(in: &cancellabels)
        
        $selectedTitle
            .debounce(for: .milliseconds(NoteListViewModelConstants.titleDebounceMilliseconds), scheduler: RunLoop.main)
            .sink { [weak self] title in
                self?.autoSaveTitle(newTitle: title)
            }
            .store(in: &cancellabels)
        
        $selectedContent
            .debounce(for: .seconds(NoteListViewModelConstants.contentDebounceSeconds), scheduler: RunLoop.main)
            .sink { [weak self] content in
                self?.autoSaveContent(newContent: content)
            }
            .store(in: &cancellabels)
        
        //初回起動時に1件目を選択状態にする
        fetchDataAndSelectFirstNote()
    }
    
    // MARK: - Public Methods
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

    // ノートを選択し、必要に応じてゴミ箱を閉じる
    // - Parameters:
    //   - note: 選択するノート（nil の場合は選択解除）
    //   - closeTrashIfNeeded: ゴミ箱が開いている場合に閉じるかどうか
    //   - userInitiated: ユーザーの明示的な操作による選択かどうか
    func selectNote(
        _ note: Note?,
        closeTrashIfNeeded: Bool = false,
        userInitiated: Bool = false
    ) {
        if closeTrashIfNeeded && isShowingTrash {
            isShowingTrash = false
        }
        select(note: note, userInitiated: userInitiated)
    }
    
    // MARK: - Public Methods (Note CRUD)
    func addNewNote() {
        let newNote = noteService.createNote(
            title: NoteListViewModelConstants.newNoteTitle,
            content: "",
            status: .active,
            tag: selectedTag
        )
        
        self.notes.insert(newNote, at: 0)
        // ユーザ操作なので、userInitiated: true
        select(note: newNote, userInitiated: true)

        saveContextWithErrorHandling(operation: "save new note")
        fetchNotes(searchText: searchText, selectedTag: selectedTag)
    }
    
    // func archiveNote(note: Note){
    //     noteService.archiveNote(note)
    //     saveContextWithErrorHandling(operation: "archive note")
    // }
    func archiveNote(note: Note){
        noteService.archiveNote(note)
        saveContextWithErrorHandling(operation: "archive note")
        fetchNotes(searchText: searchText, selectedTag: selectedTag, statusFilter: .active)
        select(note: self.notes.first, userInitiated: false)
    }
    
    func deleteNote(note: Note) {
        noteService.deleteNote(note)
        saveContextWithErrorHandling(operation: "delete note")
    }
    
    // MARK: - Public Methods (Tag Management)

    func startAddingTag() {
        newTagName = ""
        addTagError = nil
        isShowingAddTagSheet = true
    }

    func startEditingSelectedTag() {
        guard let tag = selectedTag else { return }
        editTagName = tag.name ?? ""
        editTagError = nil
        isShowingTagEditSheet = true
    }

    func saveEditedTag() {
        let trimmed = editTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            editTagError = .emptyTagName
            return
        }

        guard let tag = selectedTag else {
            editTagError = .tagNotFound
            return
        }

        if tag.name == trimmed {
            isShowingTagEditSheet = false
            return
        }

        if tags.contains(where: {$0.name == trimmed && $0.uuid != tag.uuid}) {
            editTagError = .duplicateTag
            return
        }

        noteService.updateTag(tag, newName: trimmed)
        saveContextWithErrorHandling(operation: "save edited tag")
        
        editTagError = nil
        isShowingTagEditSheet = false
    }

    func saveAddedTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            addTagError = .emptyTagName
            return
        }

        if tags.contains(where: { $0.name == trimmed }) {
            addTagError = .duplicateTag 
            return
        }

        let newTag = noteService.createTag(name: trimmed)
        saveContextWithErrorHandling(operation: "save new tag")

        addTagError = nil
        newTagName = ""
        fetchData()
        selectedTag = newTag

        isShowingAddTagSheet = false // 成功時にモーダルが閉じる
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
    
    // func addNewTag() {
    //     let name = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
    //     guard !name.isEmpty else {
    //         addTagError = TagError.emptyTagName
    //         return
    //     }
        
    //     let existsTagNames = tags.compactMap{ $0.name }
    //     if existsTagNames.contains(newTagName) {
    //         addTagError = TagError.duplicateTag
    //         return
    //     }
        
    //     let newTag = noteService.createTag(name: newTagName)
        
    //     do {
    //         try noteService.saveContext()
    //         addTagError = nil
    //         newTagName = ""
    //         self.selectedTag = newTag
    //         fetchDataAndSelectLastTag()
    //     } catch {
    //         addTagError = TagError.unknownError
    //         logError("save new tag", error: error)
    //     }
    // }
    
    func moveNotes(fromOffsets: IndexSet, toOffset: Int) {
        var updated = notes
        updated.move(fromOffsets: fromOffsets, toOffset: toOffset)
        notes = updated
        saveNotesOrder()
    }

    // MARK: - Public Methods (Archive Management)

    func fetchArchivedNotes() {
        let predicate = NSPredicate(format: "status == %d", NoteStatus.archived.rawValue)
        let sortDescriptors = [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)]
        archivedNotes = noteService.fetchNotes(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func restoreNoteFromArchive(note: Note) {
        noteService.updateNote(
            note, 
            newTitle:nil, 
            newContent: nil,
            newStatus: .active,
            newTag: nil,
            newCursorPosition: nil,
            newOrder: nil
        )
        saveContextWithErrorHandling(operation: "restore note from archive")
        fetchArchivedNotes()
    }

    func deleteNotePermanently(note: Note) {
        noteService.deleteNote(note)
        saveContextWithErrorHandling(operation: "delete note permanently")
        fetchArchivedNotes()
    }


    // MARK: - Public Methods (Data Fetching)

    func fetchNotes(
        searchText: String = "",
        selectedTag: Tag? = nil,
        statusFilter: NoteStatus = .active
    ) {
        let searchPredicate = createSearchPredicate(for: searchText)
        let tagPredicate = createTagPredicate(for: selectedTag)
        
        let statusPredicate = createStatusPredicate(for: statusFilter)
        
        let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [searchPredicate, tagPredicate, statusPredicate].compactMap { $0 })
        self.notes = noteService.fetchNotes(
            predicate: finalPredicate, 
            sortDescriptors: [NSSortDescriptor(keyPath: \Note.order, ascending: true)]
        )
        
        select(note: self.notes.first, userInitiated: false)
        
    }


}

// MARK: - Private Methods

private extension NoteListViewModel {

    // MARK: Predicate Creation

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
    
    // MARK: Helper Methods

    func getSelectedTagIndex() -> Int? {
        guard let selectedTag = selectedTag,
                let selectedTagIndex = tags.firstIndex(of: selectedTag) else {
            return nil
        }
        return selectedTagIndex
    }
    
    // MARK: Auto-Save (Note Detail)

    func autoSaveTitle(newTitle: String) {
        guard let note = selectedNote else {return}
        guard note.title != newTitle else { return }

        noteService.updateNote(note, newTitle: newTitle, newContent: nil, newStatus: nil, newTag: nil, newCursorPosition: nil, newOrder: nil)
        
        saveContextWithErrorHandling(operation: "auto-save title")
    }
    
    func autoSaveContent(newContent: String) {
        guard let note = selectedNote else {return}
        guard note.content != newContent else { return }
        noteService.updateNote(note, newTitle: nil, newContent: newContent, newStatus: nil, newTag: nil, newCursorPosition: nil, newOrder: nil)
        
        saveContextWithErrorHandling(operation: "auto-save content")
    }

    func normalizeTitle() {
        let trimmed = selectedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard selectedTitle != trimmed else { return }
        selectedTitle = trimmed
    }
    
    // MARK: Initial Data Loading

    func fetchDataAndSelectFirstNote() {
        self.notes = noteService.fetchNotes(predicate: nil, sortDescriptors: nil)
        select(note: self.notes.first, userInitiated: false)
    }
    
    // MARK: Note Order Management

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
        
        saveContextWithErrorHandling(operation: "save note order")
        fetchNotes(searchText: searchText, selectedTag: selectedTag) .self
    }

    // MARK: UI State Management
    func updateDetailContentType() {
        if isShowingTrash {
            detailContentType = .archiveList
        } else if selectedNote != nil {
            detailContentType = .noteDetail
        } else {
            detailContentType = .empty
        }
    }

    /// エラーログを出力する統一メソッド
    /// - Parameters:
    ///     - operation: 失敗した操作の説明
    ///     - error: 発生したエラー
    func logError(_ operation: String, error: Error) {
        print("[\(type(of: self))] Failed to \(operation): \(error.localizedDescription)")
    }

    func saveContextWithErrorHandling(operation: String) {
        do {
            try noteService.saveContext()
        } catch {
            logError(operation, error: error)
        }
    }
}
