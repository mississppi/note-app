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

}
