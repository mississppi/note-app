import Foundation
import CoreData

/// Service for exporting notes
protocol ExportService {
    /// Export notes to a specified directory
    /// - Parameters:
    ///   - notes: Array of notes to export
    ///   - directory: Target directory URL
    func exportNotes(_ notes: [Note], to directory: URL) throws
}
