import Foundation
import CoreData

extension Note {
    var noteStatus: NoteStatus {
        get {
            return NoteStatus(rawValue: self.status) ?? .active
        }
        set {
            self.status = newValue.rawValue
        }
    }
}
