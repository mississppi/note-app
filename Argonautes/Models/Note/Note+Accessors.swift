import Foundation
import CoreData

extension Note {
    var displayTitle: String {
        let trimmed = (title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "無題" : trimmed
    }

    var noteStatus: NoteStatus {
        get {
            return NoteStatus(rawValue: self.status) ?? .active
        }
        set {
            self.status = newValue.rawValue
        }
    }
}
