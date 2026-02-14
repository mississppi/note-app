import AppKit

/// Markdown関連の定数定義
enum MarkdownConstants {
    
    // MARK: - Formatting Timing
    
    /// Markdown装飾適用までの遅延時間（秒）
    static let formattingDelay: TimeInterval = 0.1
    
    // MARK: - Font Size Multipliers
    
    /// 見出しのフォントサイズ倍率（H1〜H6）
    static let headingFontMultipliers: [CGFloat] = [1.7, 1.4, 1.3, 1.15, 1.0, 0.85]
    
    /// コードブロックのフォントサイズ倍率
    static let codeFontMultiplier: CGFloat = 0.93
    
    // MARK: - Paragraph Spacing
    
    /// 行間の追加スペース（ポイント）
    static let lineSpacing: CGFloat = 3.0
    
    /// 段落間の追加スペース（ポイント）
    static let paragraphSpacing: CGFloat = 7.0
    
    // MARK: - Colors
    
    /// インラインコードの背景色
    static let codeBackgroundColor = NSColor.controlBackgroundColor
    
    /// インラインコードの文字色
    static let codeForegroundColor = NSColor.systemRed
    
    /// デフォルトテキストの文字色
    static let defaultTextColor = NSColor.controlTextColor
    
    // MARK: - Image Settings
    
    /// 画像の最大表示幅（ポイント）
    static let imageMaxWidth: CGFloat = 600.0
}
