import AppKit

/// Markdownテキストに装飾を適用するフォーマッター
class MarkdownFormatter {
    
    // MARK: - フォント定義
    
    private static func headingFonts(basedOn baseFont: NSFont) -> [NSFont] {
        let baseSize = baseFont.pointSize
        return [
            NSFont.boldSystemFont(ofSize: baseSize * 1.7), // H1
            NSFont.boldSystemFont(ofSize: baseSize * 1.4), // H2
            NSFont.boldSystemFont(ofSize: baseSize * 1.3), // H3
            NSFont.boldSystemFont(ofSize: baseSize * 1.15), // H4
            NSFont.boldSystemFont(ofSize: baseSize * 1.0), // H5
            NSFont.boldSystemFont(ofSize: baseSize * 0.85)  // H6
        ]
    }
    
    private static func codeFont(basedOn baseFont: NSFont) -> NSFont {
        return NSFont.monospacedSystemFont(ofSize: baseFont.pointSize * 0.93, weight: .regular)
    }
    
    private static func boldFont(basedOn baseFont: NSFont) -> NSFont {
        return NSFontManager.shared.convert(baseFont, toHaveTrait: .boldFontMask)
    }
    
    private static func italicFont(basedOn baseFont: NSFont) -> NSFont {
        return NSFontManager.shared.convert(baseFont, toHaveTrait: .italicFontMask)
    }
    
    // MARK: - 色定義
    
    private static let codeBackgroundColor = NSColor.controlBackgroundColor
    private static let codeForegroundColor = NSColor.systemRed
    
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
        
        // デフォルト属性をリセット（ベースフォントを使用）
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: NSColor.controlTextColor
        ]
        attributedString.addAttributes(defaultAttributes, range: targetRange)
        
        let text = attributedString.string as NSString
        
        // 除外範囲チェック用のヘルパー
        let shouldSkip: (NSRange) -> Bool = { matchRange in
            guard let excludeRange = excludeRange else { return false }
            return NSIntersectionRange(matchRange, excludeRange).length > 0
        }
        
        // 1. 見出し（行頭の # ）
        applyHeadings(to: attributedString, baseFont: baseFont, in: targetRange, text: text, shouldSkip: shouldSkip)
        
        // 2. 太字 **text**
        applyBold(to: attributedString, baseFont: baseFont, in: targetRange, text: text, shouldSkip: shouldSkip)
        
        // 3. イタリック *text* (太字の後に処理)
        applyItalic(to: attributedString, baseFont: baseFont, in: targetRange, text: text, shouldSkip: shouldSkip)
        
        // 4. インラインコード `code`
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
            attributedString.addAttribute(.backgroundColor, value: codeBackgroundColor, range: contentRange)
            attributedString.addAttribute(.foregroundColor, value: codeForegroundColor, range: contentRange)
        }
    }
}
