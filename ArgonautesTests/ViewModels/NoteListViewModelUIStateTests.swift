import XCTest
import CoreData
@testable import Argonautes

/// NoteListViewModelのUI状態管理機能をテスト
final class NoteListViewModelUIStateTests: XCTestCase {
    
    var service: CoreDataNoteService!
    var persistenceController: PersistenceController!
    var viewContext: NSManagedObjectContext!
    var viewModel: NoteListViewModel!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        viewContext = persistenceController.container.viewContext
        service = CoreDataNoteService(context: viewContext)
        viewModel = NoteListViewModel(noteService: service)
    }
    
    override func tearDown() {
        viewModel = nil
        service = nil
        viewContext = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - DetailContentType Tests
    
    /// 目的: ノートが選択されていない場合、detailContentTypeがemptyになることを確認
    func testDetailContentType_WhenNoNoteSelected_ShouldBeEmpty() {
        // Given: ノートが選択されていない状態
        viewModel.select(note: nil, userInitiated: false)
        
        // Then
        XCTAssertEqual(viewModel.detailContentType, .empty, "ノート未選択時はemptyであるべき")
    }
    
    /// 目的: ノートが選択された場合、detailContentTypeがnoteDetailになることを確認
    func testDetailContentType_WhenNoteSelected_ShouldBeNoteDetail() {
        // Given: ノートを作成
        let note = service.createNote(title: "Test", content: "", tag: nil)
        try? service.saveContext()
        
        // When: ノートを選択
        viewModel.select(note: note, userInitiated: false)
        
        // Then
        XCTAssertEqual(viewModel.detailContentType, .noteDetail, "ノート選択時はnoteDetailであるべき")
    }
    
    /// 目的: ゴミ箱が表示され、何も選択されていない場合、detailContentTypeがtrashGuideになることを確認
    func testDetailContentType_WhenTrashShownAndNoTrashNoteSelected_ShouldBeTrashGuide() {
        // Given: ゴミ箱を表示
        viewModel.isShowingTrash = true
        viewModel.selectedTrashNote = nil
        
        // Then
        XCTAssertEqual(viewModel.detailContentType, .trashGuide, "ゴミ箱表示＋未選択時はtrashGuideであるべき")
    }
    
    /// 目的: ゴミ箱が表示され、ゴミ箱ノートが選択された場合、detailContentTypeがtrashNoteDetailになることを確認
    func testDetailContentType_WhenTrashNoteSelected_ShouldBeTrashNoteDetail() {
        // Given: ゴミ箱ノートを作成
        let note = service.createNote(title: "Trashed", content: "", tag: nil)
        service.trashNote(note)
        try? service.saveContext()
        
        viewModel.fetchTrashedNotes()
        
        // When: ゴミ箱を表示し、ノートを選択
        viewModel.isShowingTrash = true
        viewModel.selectedTrashNote = note
        
        // Then
        XCTAssertEqual(viewModel.detailContentType, .trashNoteDetail, "ゴミ箱ノート選択時はtrashNoteDetailであるべき")
    }
    
    /// 目的: ゴミ箱から通常モードに戻った時、detailContentTypeが正しく更新されることを確認
    func testDetailContentType_WhenSwitchingFromTrashToNormal_ShouldUpdate() {
        // Given: ゴミ箱モードで開始
        viewModel.isShowingTrash = true
        XCTAssertEqual(viewModel.detailContentType, .trashGuide)
        
        // When: 通常モードに戻る
        viewModel.isShowingTrash = false
        
        // Then
        XCTAssertEqual(viewModel.detailContentType, .empty, "通常モードに戻るとemptyになるべき")
    }
    
    // MARK: - ListContentType Tests
    
    /// 目的: 通常モード時、listContentTypeがnormalになることを確認
    func testListContentType_WhenNormalMode_ShouldBeNormal() {
        // Given: 通常モード
        viewModel.isShowingTrash = false
        
        // Then
        XCTAssertEqual(viewModel.listContentType, .normal, "通常モード時はnormalであるべき")
    }
    
    /// 目的: ゴミ箱モード時、listContentTypeがtrashになることを確認
    func testListContentType_WhenTrashMode_ShouldBeTrash() {
        // Given: ゴミ箱モード
        viewModel.isShowingTrash = true
        
        // Then
        XCTAssertEqual(viewModel.listContentType, .trash, "ゴミ箱モード時はtrashであるべき")
    }
    
    // MARK: - TrashContentType Tests
    
    /// 目的: ゴミ箱が空の場合、trashContentTypeがemptyになることを確認
    func testTrashContentType_WhenNoTrashedNotes_ShouldBeEmpty() {
        // Given: ゴミ箱が空
        viewModel.fetchTrashedNotes()
        
        // Then
        XCTAssertEqual(viewModel.trashContentType, .empty, "ゴミ箱が空の時はemptyであるべき")
    }
    
    /// 目的: ゴミ箱にノートがある場合、trashContentTypeがlistになることを確認
    func testTrashContentType_WhenTrashedNotesExist_ShouldBeList() {
        // Given: ゴミ箱ノートを作成
        let note = service.createNote(title: "Trashed", content: "", tag: nil)
        service.trashNote(note)
        try? service.saveContext()
        
        // When
        viewModel.fetchTrashedNotes()
        
        // Then
        XCTAssertEqual(viewModel.trashContentType, .list, "ゴミ箱にノートがある時はlistであるべき")
    }
    
    // MARK: - Trash Display Text Tests
    
    /// 目的: ゴミ箱が空の場合、trashedNotesCountTextがnilになることを確認
    func testTrashedNotesCountText_WhenEmpty_ShouldBeNil() {
        // Given: ゴミ箱が空
        viewModel.fetchTrashedNotes()
        
        // Then
        XCTAssertNil(viewModel.trashedNotesCountText, "ゴミ箱が空の時はnilであるべき")
    }
    
    /// 目的: ゴミ箱にノートがある場合、trashedNotesCountTextが正しい件数を表示することを確認
    func testTrashedNotesCountText_WhenNotesExist_ShouldShowCount() {
        // Given: ゴミ箱ノートを3件作成
        for i in 1...3 {
            let note = service.createNote(title: "Trashed \(i)", content: "", tag: nil)
            service.trashNote(note)
        }
        try? service.saveContext()
        
        // When
        viewModel.fetchTrashedNotes()
        
        // Then
        XCTAssertEqual(viewModel.trashedNotesCountText, "3件のノートがゴミ箱にあります")
    }
    
    /// 目的: ゴミ箱が空の場合、trashedNotesGuideTextがnilになることを確認
    func testTrashedNotesGuideText_WhenEmpty_ShouldBeNil() {
        // Given: ゴミ箱が空
        viewModel.fetchTrashedNotes()
        
        // Then
        XCTAssertNil(viewModel.trashedNotesGuideText, "ゴミ箱が空の時はnilであるべき")
    }
    
    /// 目的: ゴミ箱にノートがある場合、trashedNotesGuideTextが表示されることを確認
    func testTrashedNotesGuideText_WhenNotesExist_ShouldShowGuide() {
        // Given: ゴミ箱ノートを作成
        let note = service.createNote(title: "Trashed", content: "", tag: nil)
        service.trashNote(note)
        try? service.saveContext()
        
        // When
        viewModel.fetchTrashedNotes()
        
        // Then
        XCTAssertEqual(viewModel.trashedNotesGuideText, "ノートを復元するには、左側のリストから選択してください")
    }
    
    // MARK: - Title Normalization Tests
    
    /// 目的: タイトルの先頭・末尾の空白が削除されることを確認
    func testNormalizeTitle_ShouldTrimWhitespace() {
        // Given: スペース付きタイトルのノートを選択
        let note = service.createNote(title: "Test", content: "", tag: nil)
        try? service.saveContext()
        viewModel.select(note: note, userInitiated: false)
        
        // When: スペース付きタイトルに変更してフォーカスを外す
        viewModel.selectedTitle = "  Spaced Title  "
        viewModel.isTitleFocused = true
        viewModel.isTitleFocused = false // フォーカスを外す
        
        // Then: スペースが削除される
        XCTAssertEqual(viewModel.selectedTitle, "Spaced Title", "先頭・末尾の空白が削除されるべき")
    }
    
    /// 目的: 空のタイトルが「無題」になることを確認
    func testNormalizeTitle_WhenEmpty_ShouldSetToUntitled() {
        // Given: ノートを選択
        let note = service.createNote(title: "Test", content: "", tag: nil)
        try? service.saveContext()
        viewModel.select(note: note, userInitiated: false)
        
        // When: 空のタイトルに変更してフォーカスを外す
        viewModel.selectedTitle = ""
        viewModel.isTitleFocused = true
        viewModel.isTitleFocused = false
        
        // Then: 「無題」になる
        XCTAssertEqual(viewModel.selectedTitle, "無題", "空のタイトルは「無題」になるべき")
    }
    
    /// 目的: 空白のみのタイトルが「無題」になることを確認
    func testNormalizeTitle_WhenWhitespaceOnly_ShouldSetToUntitled() {
        // Given: ノートを選択
        let note = service.createNote(title: "Test", content: "", tag: nil)
        try? service.saveContext()
        viewModel.select(note: note, userInitiated: false)
        
        // When: 空白のみのタイトルに変更してフォーカスを外す
        viewModel.selectedTitle = "   "
        viewModel.isTitleFocused = true
        viewModel.isTitleFocused = false
        
        // Then: 「無題」になる
        XCTAssertEqual(viewModel.selectedTitle, "無題", "空白のみのタイトルは「無題」になるべき")
    }
    
    /// 目的: タイトルの改行が空白に置き換えられることを確認
    func testNormalizeTitle_ShouldReplaceNewlinesWithSpace() {
        // Given: ノートを選択
        let note = service.createNote(title: "Test", content: "", tag: nil)
        try? service.saveContext()
        viewModel.select(note: note, userInitiated: false)
        
        // When: 改行を含むタイトルに変更してフォーカスを外す
        viewModel.selectedTitle = "Line1\nLine2\nLine3"
        viewModel.isTitleFocused = true
        viewModel.isTitleFocused = false
        
        // Then: 改行が空白に置き換えられる
        XCTAssertEqual(viewModel.selectedTitle, "Line1 Line2 Line3", "改行が空白に置き換えられるべき")
    }
    
    /// 目的: 連続する空白が1つにまとめられることを確認
    func testNormalizeTitle_ShouldCollapseMultipleSpaces() {
        // Given: ノートを選択
        let note = service.createNote(title: "Test", content: "", tag: nil)
        try? service.saveContext()
        viewModel.select(note: note, userInitiated: false)
        
        // When: 連続空白を含むタイトルに変更してフォーカスを外す
        viewModel.selectedTitle = "Multiple    Spaces    Here"
        viewModel.isTitleFocused = true
        viewModel.isTitleFocused = false
        
        // Then: 連続空白が1つにまとめられる
        XCTAssertEqual(viewModel.selectedTitle, "Multiple Spaces Here", "連続空白が1つにまとめられるべき")
    }
    
    // MARK: - Trash Note Detail Properties Tests
    
    /// 目的: selectedTrashNoteのタイトルが正しく取得できることを確認
    func testSelectedTrashNoteTitle_WhenNoteSelected_ShouldReturnTitle() {
        // Given: ゴミ箱ノートを作成
        let note = service.createNote(title: "Trashed Note", content: "", tag: nil)
        service.trashNote(note)
        try? service.saveContext()
        
        // When: ゴミ箱ノートを選択
        viewModel.selectedTrashNote = note
        
        // Then
        XCTAssertEqual(viewModel.selectedTrashNoteTitle, "Trashed Note")
    }
    
    /// 目的: selectedTrashNoteがnilの時、タイトルが「無題」になることを確認
    func testSelectedTrashNoteTitle_WhenNoNoteSelected_ShouldReturnUntitled() {
        // Given: ゴミ箱ノート未選択
        viewModel.selectedTrashNote = nil
        
        // Then
        XCTAssertEqual(viewModel.selectedTrashNoteTitle, "無題")
    }
    
    /// 目的: selectedTrashNoteのコンテンツが正しく取得できることを確認
    func testSelectedTrashNoteContent_WhenNoteSelected_ShouldReturnContent() {
        // Given: ゴミ箱ノートを作成
        let note = service.createNote(title: "Test", content: "Content here", tag: nil)
        service.trashNote(note)
        try? service.saveContext()
        
        // When: ゴミ箱ノートを選択
        viewModel.selectedTrashNote = note
        
        // Then
        XCTAssertEqual(viewModel.selectedTrashNoteContent, "Content here")
    }
    
    /// 目的: selectedTrashNoteがnilの時、コンテンツが空文字列になることを確認
    func testSelectedTrashNoteContent_WhenNoNoteSelected_ShouldReturnEmpty() {
        // Given: ゴミ箱ノート未選択
        viewModel.selectedTrashNote = nil
        
        // Then
        XCTAssertEqual(viewModel.selectedTrashNoteContent, "")
    }
}
