import Foundation

/// ノートの状態を表す列挙型
///
/// Core Data の status 属性に対応します。
/// - Note: rawValue は Int16 で保存されます
enum NoteStatus: Int16, CaseIterable, Identifiable {
    /// アクティブ（通常表示されるノート）
    case active = 0

    /// アーカイブ済み（ゴミ箱に移動されたノート）
    case archived = 1
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .active:
            return "アクティブ"
        case .archived:
            return "アーカイブ済み"
        }
    }
}
