import Foundation

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
