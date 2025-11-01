import Foundation

enum TagError: String, Error {
    //追加時のエラー
    case emptyTagName = "タグ名を入力してください。"
    case duplicateTag = "このタグはすでに存在します。"

    //その他のエラー
    case unknownError = "不明なエラーが発生しました。"
}