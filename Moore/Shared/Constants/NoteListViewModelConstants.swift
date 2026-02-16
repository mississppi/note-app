import Foundation

enum NoteListViewModelConstants {
    /// 新規ノートのデフォルトタイトル
    static let newNoteTitle = "new Note"
    /// デフォルトタグ名
    static let defaultTagName = "general"
    /// タグの最小数（これ以下にはできない）
    static let minTagCount = 1
    /// タグの最大数
    static let maxTagCount = 100
    /// 検索テキストのデバウンス時間（ミリ秒）
    static let searchDebounceMilliseconds = 500
    /// タイトル自動保存のデバウンス時間（ミリ秒）
    static let titleDebounceMilliseconds = 500
    /// コンテンツ自動保存のデバウンス時間（秒）
    static let contentDebounceSeconds: TimeInterval  = 1.0
}