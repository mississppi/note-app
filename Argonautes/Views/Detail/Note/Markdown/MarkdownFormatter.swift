import AppKit

/// Markdownテキストに装飾を適用するフォーマッター
class MarkdownFormatter {
    
    // MARK: - フォント定義
    
    private static func headingFonts(basedOn baseFont: NSFont) -> [NSFont] {
        let baseSize = baseFont.pointSize
        return MarkdownConstants.headingFontMultipliers.map { multiplier in
            NSFont.boldSystemFont(ofSize: baseSize * multiplier)
        }
    }
    
    private static func codeFont(basedOn baseFont: NSFont) -> NSFont {
        return NSFont.monospacedSystemFont(ofSize: baseFont.pointSize * MarkdownConstants.codeFontMultiplier, weight: .regular)
    }
    
    private static func boldFont(basedOn baseFont: NSFont) -> NSFont {
        return NSFontManager.shared.convert(baseFont, toHaveTrait: .boldFontMask)
    }
    
    private static func italicFont(basedOn baseFont: NSFont) -> NSFont {
        return NSFontManager.shared.convert(baseFont, toHaveTrait: .italicFontMask)
    }
    
    // MARK: - 色定義（MarkdownConstantsを参照）
    
    // MARK: - Markdown装飾適用
    
    /// 指定されたテキストにMarkdown装飾を適用
    /// - Parameters:
    ///   - attributedString: 装飾を適用する対象のAttributedString
    ///   - baseFont: ベースフォント（装飾がない部分に使用）
    ///   - range: 装飾を適用する範囲（nilの場合は全体）
    ///   - excludeRange: 装飾を適用しない範囲（IME変換中など）
    static func applyMarkdown(to attributedString: NSMutableAttributedString,
                             baseFont: NSFont,
                             in range: NSRange? = nil,
                             excluding excludeRange: NSRange? = nil) {
        let targetRange = range ?? NSRange(location: 0, length: attributedString.length)
        
        // 段落スタイルを設定（行間調整）
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = MarkdownConstants.lineSpacing
        paragraphStyle.paragraphSpacing = MarkdownConstants.paragraphSpacing
        
        // デフォルト属性をリセット（ベースフォントと段落スタイルを使用）
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: MarkdownConstants.defaultTextColor,
            .paragraphStyle: paragraphStyle
        ]
        attributedString.addAttributes(defaultAttributes, range: targetRange)
        
        let text = attributedString.string as NSString
        
        // 除外範囲チェック用のヘルパー
        let shouldSkip: (NSRange) -> Bool = { matchRange in
            guard let excludeRange = excludeRange else { return false }
            return NSIntersectionRange(matchRange, excludeRange).length > 0
        }
        
        // 1. 画像 ![alt](path) - 一時的に無効化
        // applyImages(to: attributedString, in: targetRange, text: text, shouldSkip: shouldSkip)
        
        // 2. 見出し（行頭の # ）
        applyHeadings(to: attributedString, baseFont: baseFont, in: targetRange, text: text, shouldSkip: shouldSkip)
        
        // 3. 太字 **text**
        applyBold(to: attributedString, baseFont: baseFont, in: targetRange, text: text, shouldSkip: shouldSkip)
        
        // 4. イタリック *text* (太字の後に処理)
        applyItalic(to: attributedString, baseFont: baseFont, in: targetRange, text: text, shouldSkip: shouldSkip)
        
        // 5. インラインコード `code`
        applyInlineCode(to: attributedString, baseFont: baseFont, in: targetRange, text: text, shouldSkip: shouldSkip)
    }
    
    // MARK: - 個別パターン適用
    
    private static func applyHeadings(to attributedString: NSMutableAttributedString,
                                     baseFont: NSFont,
                                     in range: NSRange,
                                     text: NSString,
                                     shouldSkip: (NSRange) -> Bool) {
        // スペースまたはタブのみマッチ（改行を除外）
        let pattern = "^(#{1,6})[ \\t]+(.+)$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) else { return }
        let fonts = headingFonts(basedOn: baseFont)
        
        regex.enumerateMatches(in: text as String, options: [], range: range) { match, _, _ in
            guard let match = match else { return }
            if shouldSkip(match.range) { return }
            
            let hashesRange = match.range(at: 1)
            let contentRange = match.range(at: 2)
            let level = min(hashesRange.length - 1, fonts.count - 1)
            
            attributedString.addAttribute(.font, value: fonts[level], range: contentRange)
        }
    }
    
    private static func applyBold(to attributedString: NSMutableAttributedString,
                                 baseFont: NSFont,
                                 in range: NSRange,
                                 text: NSString,
                                 shouldSkip: (NSRange) -> Bool) {
        let pattern = "\\*\\*(.+?)\\*\\*"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        
        regex.enumerateMatches(in: text as String, options: [], range: range) { match, _, _ in
            guard let match = match, match.numberOfRanges > 1 else { return }
            let contentRange = match.range(at: 1)
            if shouldSkip(contentRange) { return }
            
            attributedString.addAttribute(.font, value: boldFont(basedOn: baseFont), range: contentRange)
        }
    }
    
    private static func applyItalic(to attributedString: NSMutableAttributedString,
                                   baseFont: NSFont,
                                   in range: NSRange,
                                   text: NSString,
                                   shouldSkip: (NSRange) -> Bool) {
        // *text* だが **text** は除外（太字を優先）
        let pattern = "(?<!\\*)\\*(?!\\*)(.+?)(?<!\\*)\\*(?!\\*)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        
        regex.enumerateMatches(in: text as String, options: [], range: range) { match, _, _ in
            guard let match = match, match.numberOfRanges > 1 else { return }
            let contentRange = match.range(at: 1)
            if shouldSkip(contentRange) { return }
            
            attributedString.addAttribute(.font, value: italicFont(basedOn: baseFont), range: contentRange)
        }
    }
    
    private static func applyInlineCode(to attributedString: NSMutableAttributedString,
                                       baseFont: NSFont,
                                       in range: NSRange,
                                       text: NSString,
                                       shouldSkip: (NSRange) -> Bool) {
        let pattern = "`([^`]+)`"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        
        regex.enumerateMatches(in: text as String, options: [], range: range) { match, _, _ in
            guard let match = match, match.numberOfRanges > 1 else { return }
            let contentRange = match.range(at: 1)
            if shouldSkip(contentRange) { return }
            
            attributedString.addAttribute(.font, value: codeFont(basedOn: baseFont), range: contentRange)
            attributedString.addAttribute(.backgroundColor, value: MarkdownConstants.codeBackgroundColor, range: contentRange)
            attributedString.addAttribute(.foregroundColor, value: MarkdownConstants.codeForegroundColor, range: contentRange)
        }
    }
    
    private static func applyImages(
        to attributedString: NSMutableAttributedString,
        in range: NSRange,
        text: NSString,
        shouldSkip: (NSRange) -> Bool
    ) {
        let pattern = "!\\[([^\\]]*)\\]\\(([^)]+)\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        
        // マッチを逆順で処理（位置がずれないように）
        let matches = regex.matches(in: text as String, options: [], range: range).reversed()
        
        for match in matches {
            guard match.numberOfRanges > 2 else { continue }
            
            let fullRange = match.range
            if shouldSkip(fullRange) { continue }
            
            let altRange = match.range(at: 1)
            let pathRange = match.range(at: 2)
            
            guard let pathSwiftRange = Range(pathRange, in: text as String) else { continue }
            let imagePath = String(text.substring(with: pathRange))
            
            // ImageStorageManagerでパス解決
            guard let imageURL = ImageStorageManager.shared.resolveImagePath(imagePath),
                  let image = NSImage(contentsOf: imageURL) else {
                // 画像が見つからない場合はスキップ
                continue
            }
            
            // NSTextAttachmentで画像を埋め込み
            let attachment = NSTextAttachment()
            attachment.image = image
            
            // 画像サイズを調整（エディタ幅に合わせる）
            let maxWidth = MarkdownConstants.imageMaxWidth
            let imageSize = image.size
            if imageSize.width > maxWidth {
                let scale = maxWidth / imageSize.width
                attachment.bounds = CGRect(
                    x: 0,
                    y: 0,
                    width: maxWidth,
                    height: imageSize.height * scale
                )
            } else {
                attachment.bounds = CGRect(
                    origin: .zero,
                    size: imageSize
                )
            }
            
            // Markdown記法を画像で置き換え
            let attachmentString = NSAttributedString(attachment: attachment)
            attributedString.replaceCharacters(in: fullRange, with: attachmentString)
        }
    }
}
