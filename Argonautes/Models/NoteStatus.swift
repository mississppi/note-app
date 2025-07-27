import Foundation

enum NoteStatus: Int16, CaseIterable, Identifiable {
    case active = 0
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
