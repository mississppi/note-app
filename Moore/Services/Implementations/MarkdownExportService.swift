import Foundation
import CoreData

class MarkdownExportService: ExportService {

    // MARK: - Constants
    private static let exportFolderPrefix = "Moore_Export_"
    private static let exportFolderDateFormat = "yyyy-MM-dd_HH-mm-ss"
    private static let fileDateFormat = "yyyy-MM-dd"
    private static let maxFilenameLength = 100
    private static let invalidFilenameCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
    
    func exportNotes(_ notes: [Note], to directory: URL) throws {
        Logger.info("[MarkdownExportService] エクスポート開始: \(notes.count)件のノート")
        Logger.info("[MarkdownExportService] 出力先: \(directory.path)")

        // Exportフォルダ作成
        let exportURL = try createExportFolder(in: directory)

        // Export each note
        for (index, note) in notes.enumerated() {
            Logger.info("[MarkdownExportService] ノート\(index + 1)/\(notes.count)をエクスポート中...")
            try exportNote(note, to: exportURL)
        }

        Logger.info("[MarkdownExportService] ✅ 完了: \(notes.count)件のノートを \(exportURL.path) にエクスポートしました")
    }

    /// エクスポート用フォルダを作成し、そのURLを返す
    private func createExportFolder(in directory: URL) throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Self.exportFolderDateFormat
        let timestamp = dateFormatter.string(from: Date())
        let exportFolderName = Self.exportFolderPrefix + timestamp
        let exportURL = directory.appendingPathComponent(exportFolderName)

        Logger.info("[MarkdownExportService] フォルダ作成: \(exportURL.path)")
        try FileManager.default.createDirectory(at: exportURL, withIntermediateDirectories: true)
        Logger.info("[MarkdownExportService] フォルダ作成成功")
        return exportURL
    }
    
    private func exportNote(_ note: Note, to directory: URL) throws {
        let markdown = generateMarkdown(for: note)
        let filename = generateFilename(for: note)
        let fileURL = directory.appendingPathComponent(filename)
        
        Logger.info("[MarkdownExportService]   - ファイル: \(filename)")
        try markdown.write(to: fileURL, atomically: true, encoding: .utf8)
        Logger.info("[MarkdownExportService]   - 書き込み完了")
    }
    
    private func generateMarkdown(for note: Note) -> String {
        var markdown = "---\n"
        
        // Title
        markdown += "title: \"\(escapeFrontmatter(note.title ?? "Untitled"))\"\n"
        
        // Date
        if let date = note.createdAt {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime]
            markdown += "date: \(isoFormatter.string(from: date))\n"
        }
        
        // Tags
        if let tag = note.tag, let tagName = tag.name {
            markdown += "tags:\n"
            markdown += "  - \(escapeFrontmatter(tagName))\n"
        }
        
        markdown += "---\n\n"
        
        // Content
        if let content = note.content, !content.isEmpty {
            markdown += content
        }
        
        return markdown
    }
    
    private func generateFilename(for note: Note) -> String {
        // Date prefix
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Self.fileDateFormat
        let dateString = note.createdAt.map { dateFormatter.string(from: $0) } ?? "0000-00-00"

        // Title (sanitized for filesystem)
        let title = note.title ?? "untitled"
        let sanitizedTitle = sanitizeFilename(title)

        return "\(dateString)-\(sanitizedTitle).md"
    }
    
    private func sanitizeFilename(_ string: String) -> String {
        let components = string.components(separatedBy: Self.invalidFilenameCharacters)
        let sanitized = components.joined(separator: "-")

        let trimmed = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > Self.maxFilenameLength {
            let index = trimmed.index(trimmed.startIndex, offsetBy: Self.maxFilenameLength)
            return String(trimmed[..<index])
        }

        return trimmed.isEmpty ? "untitled" : trimmed
    }
    
    private func escapeFrontmatter(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}
