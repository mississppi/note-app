import XCTest
import CoreData
@testable import Argonautes

/// NoteListViewModelのタグ管理機能をテスト
/// 
/// テスト対象:
/// - タグ作成時のバリデーション
/// - タグ削除時のノート処理
/// - タグ編集時の重複チェック
final class TagManagementTests: XCTestCase {
    
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
    
    // MARK: - Tag Creation Validation Tests
    
    /// 目的: 空のタグ名で保存しようとするとエラーになることを確認
    func testSaveAddedTag_WhenEmpty_ShouldSetError() {
        // Given: 空のタグ名
        viewModel.newTagName = ""
        
        // When: タグを保存
        viewModel.saveAddedTag()
        
        // Then: エラーが設定される
        XCTAssertEqual(viewModel.addTagError, .emptyTagName, "空のタグ名はエラーになるべき")
    }
    
    /// 目的: 空白のみのタグ名で保存しようとするとエラーになることを確認
    func testSaveAddedTag_WhenWhitespaceOnly_ShouldSetError() {
        // Given: 空白のみのタグ名
        viewModel.newTagName = "   "
        
        // When: タグを保存
        viewModel.saveAddedTag()
        
        // Then: エラーが設定される
        XCTAssertEqual(viewModel.addTagError, .emptyTagName, "空白のみのタグ名はエラーになるべき")
    }
    
    /// 目的: 重複したタグ名で保存しようとするとエラーになることを確認
    func testSaveAddedTag_WhenDuplicate_ShouldSetError() {
        // Given: 既存のタグ
        _ = service.createTag(name: "Work")
        try? service.saveContext()
        viewModel.fetchData()
        
        // When: 同じ名前で新規タグを作成しようとする
        viewModel.newTagName = "Work"
        viewModel.saveAddedTag()
        
        // Then: エラーが設定される
        XCTAssertEqual(viewModel.addTagError, .duplicateTag, "重複タグ名はエラーになるべき")
    }
    
    /// 目的: タグ名の前後の空白が自動でトリムされることを確認
    func testSaveAddedTag_ShouldTrimWhitespace() {
        // Given: 前後に空白があるタグ名
        viewModel.newTagName = "  NewTag  "
        
        // When: タグを保存
        viewModel.saveAddedTag()
        
        // Then: 空白が削除されたタグが作成される
        XCTAssertTrue(viewModel.tags.contains(where: { $0.name == "NewTag" }), "空白がトリムされたタグが作成されるべき")
        XCTAssertFalse(viewModel.tags.contains(where: { $0.name == "  NewTag  " }), "空白付きのタグは作成されないべき")
    }
    
    /// 目的: タグ作成成功時、モーダルが閉じ、新規タグが選択されることを確認
    func testSaveAddedTag_OnSuccess_ShouldCloseModalAndSelectTag() {
        // Given: 新しいタグ名
        viewModel.newTagName = "NewTag"
        viewModel.isShowingAddTagSheet = true
        
        // When: タグを保存
        viewModel.saveAddedTag()
        
        // Then: モーダルが閉じ、タグが選択される
        XCTAssertFalse(viewModel.isShowingAddTagSheet, "成功時はモーダルが閉じるべき")
        XCTAssertEqual(viewModel.selectedTag?.name, "NewTag", "作成したタグが選択されるべき")
        XCTAssertNil(viewModel.addTagError, "成功時はエラーがnilになるべき")
    }
    
    // MARK: - Tag Deletion Tests
    
    /// 目的: タグを削除すると、紐づくノートが全てゴミ箱に移動することを確認
    func testDeleteTag_ShouldMoveAllAssociatedNotesToTrash() {
        // Given: タグと紐づくノートを作成
        let tag = service.createTag(name: "ToDelete")
        let note1 = service.createNote(title: "Note 1", content: "", tag: tag)
        let note2 = service.createNote(title: "Note 2", content: "", tag: tag)
        let note3 = service.createNote(title: "Note 3", content: "", tag: tag)
        try? service.saveContext()
        
        // When: タグを削除
        viewModel.deleteTag( tag)
        
        // Then: 全てのノートがゴミ箱に移動
        XCTAssertTrue(note1.isTrashed, "ノート1はゴミ箱に移動すべき")
        XCTAssertTrue(note2.isTrashed, "ノート2はゴミ箱に移動すべき")
        XCTAssertTrue(note3.isTrashed, "ノート3はゴミ箱に移動すべき")
    }
    
    /// 目的: タグ削除時、各ノートのdeletedTagNameにタグ名が保存されることを確認
    func testDeleteTag_ShouldPreserveTagNameInDeletedTagName() {
        // Given: タグと紐づくノートを作成
        let tag = service.createTag(name: "ImportantTag")
        let note1 = service.createNote(title: "Note 1", content: "", tag: tag)
        let note2 = service.createNote(title: "Note 2", content: "", tag: tag)
        try? service.saveContext()
        
        // When: タグを削除
        viewModel.deleteTag( tag)
        
        // Then: deletedTagNameに元のタグ名が保存される
        XCTAssertEqual(note1.deletedTagName, "ImportantTag", "削除されたタグ名が保存されるべき")
        XCTAssertEqual(note2.deletedTagName, "ImportantTag", "削除されたタグ名が保存されるべき")
    }
    
    /// 目的: タグ削除後、そのタグが存在しなくなることを確認
    func testDeleteTag_ShouldRemoveTagFromDatabase() {
        // Given: タグを作成
        let tag = service.createTag(name: "ToDelete")
        try? service.saveContext()
        viewModel.fetchData()
        
        let initialCount = viewModel.tags.count
        
        // When: タグを削除
        viewModel.deleteTag( tag)
        
        // Then: タグが削除される
        XCTAssertEqual(viewModel.tags.count, initialCount - 1, "タグが1つ減るべき")
        XCTAssertFalse(viewModel.tags.contains(where: { $0.name == "ToDelete" }), "削除したタグは存在しないべき")
    }
    
    /// 目的: 他のタグに紐づくノートは影響を受けないことを確認
    func testDeleteTag_ShouldNotAffectNotesWithOtherTags() {
        // Given: 2つのタグと、それぞれに紐づくノートを作成
        let tag1 = service.createTag(name: "Tag1")
        let tag2 = service.createTag(name: "Tag2")
        let note1 = service.createNote(title: "Note 1", content: "", tag: tag1)
        let note2 = service.createNote(title: "Note 2", content: "", tag: tag2)
        try? service.saveContext()
        
        // When: tag1を削除
        viewModel.deleteTag( tag1)
        
        // Then: tag2のノートは影響を受けない
        XCTAssertTrue(note1.isTrashed, "tag1のノートはゴミ箱に移動すべき")
        XCTAssertFalse(note2.isTrashed, "tag2のノートは影響を受けないべき")
        XCTAssertEqual(note2.tag?.name, "Tag2", "tag2のノートのタグは変わらないべき")
    }
    
    // MARK: - Tag Edit Validation Tests
    
    /// 目的: タグ編集時、空のタグ名はエラーになることを確認
    func testSaveEditedTag_WhenEmpty_ShouldSetError() {
        // Given: 既存のタグ
        let tag = service.createTag(name: "Original")
        try? service.saveContext()
        viewModel.selectedTag = tag
        
        // When: 空のタグ名で保存しようとする
        viewModel.editTagName = ""
        viewModel.saveEditedTag()
        
        // Then: エラーが設定される
        XCTAssertEqual(viewModel.editTagError, .emptyTagName, "空のタグ名はエラーになるべき")
    }
    
    /// 目的: タグ編集時、空白のみのタグ名はエラーになることを確認
    func testSaveEditedTag_WhenWhitespaceOnly_ShouldSetError() {
        // Given: 既存のタグ
        let tag = service.createTag(name: "Original")
        try? service.saveContext()
        viewModel.selectedTag = tag
        
        // When: 空白のみのタグ名で保存しようとする
        viewModel.editTagName = "   "
        viewModel.saveEditedTag()
        
        // Then: エラーが設定される
        XCTAssertEqual(viewModel.editTagError, .emptyTagName, "空白のみのタグ名はエラーになるべき")
    }
    
    /// 目的: タグ編集時、他の既存タグと重複した名前はエラーになることを確認
    func testSaveEditedTag_WhenDuplicateWithOtherTag_ShouldSetError() {
        // Given: 2つのタグ
        let tag1 = service.createTag(name: "Tag1")
        let tag2 = service.createTag(name: "Tag2")
        try? service.saveContext()
        viewModel.fetchData()
        viewModel.selectedTag = tag1
        
        // When: tag2と同じ名前に変更しようとする
        viewModel.editTagName = "Tag2"
        viewModel.saveEditedTag()
        
        // Then: エラーが設定される
        XCTAssertEqual(viewModel.editTagError, .duplicateTag, "重複タグ名はエラーになるべき")
    }
    
    /// 目的: タグ編集時、同じ名前（変更なし）は許可されることを確認
    func testSaveEditedTag_WhenSameName_ShouldSucceed() {
        // Given: 既存のタグ
        let tag = service.createTag(name: "TagName")
        try? service.saveContext()
        viewModel.fetchData()
        viewModel.selectedTag = tag
        viewModel.isShowingTagEditSheet = true
        
        // When: 同じ名前で保存
        viewModel.editTagName = "TagName"
        viewModel.saveEditedTag()
        
        // Then: エラーなく保存される
        XCTAssertNil(viewModel.editTagError, "同じ名前の場合はエラーにならないべき")
        XCTAssertFalse(viewModel.isShowingTagEditSheet, "モーダルが閉じるべき")
    }
    
    /// 目的: タグ編集成功時、タグ名が更新されることを確認
    func testSaveEditedTag_OnSuccess_ShouldUpdateTagName() {
        // Given: 既存のタグ
        let tag = service.createTag(name: "OldName")
        try? service.saveContext()
        viewModel.fetchData()
        viewModel.selectedTag = tag
        
        // When: 新しい名前で保存
        viewModel.editTagName = "NewName"
        viewModel.saveEditedTag()
        
        // Then: タグ名が更新される
        XCTAssertEqual(tag.name, "NewName", "タグ名が更新されるべき")
        XCTAssertTrue(viewModel.tags.contains(where: { $0.name == "NewName" }), "新しい名前のタグが存在するべき")
    }
    
    /// 目的: タグ編集時、前後の空白が自動でトリムされることを確認
    func testSaveEditedTag_ShouldTrimWhitespace() {
        // Given: 既存のタグ
        let tag = service.createTag(name: "OldName")
        try? service.saveContext()
        viewModel.selectedTag = tag
        
        // When: 前後に空白があるタグ名で保存
        viewModel.editTagName = "  NewName  "
        viewModel.saveEditedTag()
        
        // Then: 空白が削除されたタグ名に更新される
        XCTAssertEqual(tag.name, "NewName", "空白がトリムされたタグ名になるべき")
    }
}
