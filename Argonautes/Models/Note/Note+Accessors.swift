import Foundation
import CoreData

extension Note {
    /// UI表示用の整形済みタイトル
    /// 
    /// タイトルが nil、空文字、または空白のみの場合は "無題" を返します。
    /// それ以外の場合はトリム後のタイトルを返します。
    var displayTitle: String {
        let trimmed = (title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "無題" : trimmed
    }

    /// Core Data の Int16 status を型安全な NoteStatus enum にラップ
    /// 
    /// - Note: 
    ///   - get: Int16 の status を NoteStatus に変換（不正な値は .active として扱う）
    ///   - set: NoteStatus の rawValue を Int16 の status に設定
    var noteStatus: NoteStatus {
        get {
            return NoteStatus(rawValue: self.status) ?? .active
        }
        set {
            self.status = newValue.rawValue
        }
    }
}
