import Foundation

enum NoteStatus: Int16, CaseIterable, Identifiable {
    case atcive = 0
    case archived = 1
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .atcive:
            return "アクティブ"
        case .archived:
            return "アーカイブ済み"
        }
    }
}
