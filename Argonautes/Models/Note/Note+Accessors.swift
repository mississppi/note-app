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

    /// ゴミ箱での削除日表示文字列
    /// 
    /// trashedAtがnilの場合は空文字を返します。
    /// それ以外の場合は「削除日: YYYY/M/D」形式で
    var formattedTrashedDate: String {
        guard let trashedAt = trashedAt else { return "" }
        return "削除日: \(trashedAt.formatted(.dateTime.year().month().day()))"
    }

}
