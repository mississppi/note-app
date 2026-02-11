import Foundation
import AppKit

/// 画像ファイルの保存と管理を担当するマネージャー
class ImageStorageManager {
    
    // MARK: - Singleton
    
    static let shared = ImageStorageManager()
    
    private init() {
        // ディレクトリを初期化時に作成
        ensureImagesDirectoryExists()
    }
    
    // MARK: - Properties
    
    /// 画像保存先のディレクトリ
    /// ~/Library/Application Support/mississippistudio.Argonautes/Images/
    var imagesDirectory: URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        
        let appDir = appSupport.appendingPathComponent("mississippistudio.Argonautes")
        return appDir.appendingPathComponent("Images")
    }
    
    // MARK: - Public Methods
    
    /// 画像ファイルを保存してMarkdownパスを返す
    /// - Parameter sourceURL: コピー元の画像ファイルURL
    /// - Returns: Markdown記法で使用するパス (例: "images/uuid.jpg")、失敗時はnil
    func saveImage(from sourceURL: URL) -> String? {
        // ディレクトリが存在するか確認
        ensureImagesDirectoryExists()
        
        // UUID生成
        let uuid = UUID().uuidString
        let ext = sourceURL.pathExtension.lowercased()
        
        // 画像形式の検証
        guard isValidImageExtension(ext) else {
            print("⚠️ Unsupported image format: \(ext)")
            return nil
        }
        
        let filename = "\(uuid).\(ext)"
        let destURL = imagesDirectory.appendingPathComponent(filename)
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destURL)
            print("✅ Image saved: \(filename)")
            return "images/\(filename)"
        } catch {
            print("❌ Failed to save image: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Markdownパス（例: "images/uuid.jpg"）から実際のファイルURLを解決
    /// - Parameter markdownPath: Markdown内のパス
    /// - Returns: 実際のファイルURL、解決できない場合はnil
    func resolveImagePath(_ markdownPath: String) -> URL? {
        // "images/" で始まるパスのみ処理
        guard markdownPath.hasPrefix("images/") else {
            return nil
        }
        
        let filename = String(markdownPath.dropFirst("images/".count))
        let imageURL = imagesDirectory.appendingPathComponent(filename)
        
        // ファイルが存在するか確認
        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            print("⚠️ Image file not found: \(filename)")
            return nil
        }
        
        return imageURL
    }
    
    /// 画像ファイルを削除
    /// - Parameter markdownPath: Markdown内のパス
    /// - Returns: 成功したかどうか
    @discardableResult
    func deleteImage(at markdownPath: String) -> Bool {
        guard let imageURL = resolveImagePath(markdownPath) else {
            return false
        }
        
        do {
            try FileManager.default.removeItem(at: imageURL)
            print("✅ Image deleted: \(markdownPath)")
            return true
        } catch {
            print("❌ Failed to delete image: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 孤立した画像（どのノートからも参照されていない画像）を検出
    /// - Parameter allMarkdownTexts: すべてのノートのテキスト配列
    /// - Returns: 孤立画像のパス配列
    func findOrphanedImages(in allMarkdownTexts: [String]) -> [String] {
        // すべてのMarkdownテキストから画像パスを抽出
        let referencedPaths = Set(allMarkdownTexts.flatMap { text in
            extractImagePaths(from: text)
        })
        
        // ディレクトリ内のすべての画像ファイルを取得
        guard let allFiles = try? FileManager.default.contentsOfDirectory(
            at: imagesDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        
        let allImagePaths = allFiles
            .filter { isValidImageExtension($0.pathExtension.lowercased()) }
            .map { "images/\($0.lastPathComponent)" }
        
        // 参照されていない画像を抽出
        return allImagePaths.filter { !referencedPaths.contains($0) }
    }
    
    // MARK: - Private Methods
    
    /// 画像ディレクトリが存在することを保証（なければ作成）
    private func ensureImagesDirectoryExists() {
        let dirURL = imagesDirectory
        
        if !FileManager.default.fileExists(atPath: dirURL.path) {
            do {
                try FileManager.default.createDirectory(
                    at: dirURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print("Failed to create images directory: \(error.localizedDescription)")
            }
        }
    }
    
    /// 有効な画像拡張子かどうかを判定
    private func isValidImageExtension(_ ext: String) -> Bool {
        let validExtensions = ["jpg", "jpeg", "png", "gif", "heic", "heif", "webp", "bmp", "tiff", "tif"]
        return validExtensions.contains(ext.lowercased())
    }
    
    /// Markdownテキストから画像パスを抽出
    private func extractImagePaths(from markdown: String) -> [String] {
        let pattern = "!\\[.*?\\]\\((images/[^)]+)\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let matches = regex.matches(
            in: markdown,
            options: [],
            range: NSRange(location: 0, length: markdown.utf16.count)
        )
        
        return matches.compactMap { match in
            guard match.numberOfRanges > 1 else { return nil }
            let range = match.range(at: 1)
            guard let swiftRange = Range(range, in: markdown) else { return nil }
            return String(markdown[swiftRange])
        }
    }
}
