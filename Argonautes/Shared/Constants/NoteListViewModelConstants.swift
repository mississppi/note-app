import Foundation

enum NoteListViewModelConstants {
    /// 新規ノートのデフォルトタイトル
    static let newNoteTitle = "new Note"
    /// 検索テキストのデバウンス時間（ミリ秒）
    static let searchDebounceMilliseconds = 500
    /// タイトル自動保存のデバウンス時間（ミリ秒）
    static let titleDebounceMilliseconds = 500
    /// コンテンツ自動保存のデバウンス時間（秒）
    static let contentDebounceSeconds: TimeInterval  = 1.0
    /// タグの最大数
    static let maxTagCount = 100
}