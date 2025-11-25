import Foundation

enum TagError: String, Error {
    /// タグ名が空の場合
    case emptyTagName = "タグ名を入力してください。"

    /// 同じ名前のタグが既に存在する場合
    case duplicateTag = "このタグはすでに存在します。"

    /// タグが見つからない場合
    case tagNotFound = "タグが見つかりません。"

    /// 予期しないエラーが発生した場合
    case unknownError = "不明なエラーが発生しました。"
}