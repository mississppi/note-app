import AppKit

/// Markdown装飾適用のタイミングとロジックを管理するエンジン
class MarkdownEngine {
    
    // MARK: - Properties
    
    private weak var textView: NSTextView?
    private var formatTimer: Timer?
    private let formattingDelay: TimeInterval
    
    // MARK: - Initialization
    
    /// イニシャライザ
    /// - Parameters:
    ///   - textView: 対象のNSTextView
    ///   - formattingDelay: 装飾適用までの遅延時間（デフォルト0.3秒）
    init(textView: NSTextView, formattingDelay: TimeInterval = 0.3) {
        self.textView = textView
        self.formattingDelay = formattingDelay
    }
    
    // MARK: - Public Methods
    
    /// テキスト変更時に呼び出される
    /// タイマーをリセットし、一定時間後にMarkdown装飾を適用する
    func handleTextChange() {
        // 既存のタイマーをキャンセル
        cancelFormatting()
        
        // IME変換中は装飾を適用しない
        guard let textView = textView, !isIMEActive() else {
            return
        }
        
        // 遅延後にMarkdown装飾を適用
        formatTimer = Timer.scheduledTimer(
            withTimeInterval: formattingDelay,
            repeats: false
        ) { [weak self] _ in
            self?.applyMarkdownFormatting()
        }
    }
    
    /// 即座にMarkdown装飾を適用する（Timer経由せず）
    /// 主に初期化時や強制更新時に使用
    func applyMarkdownImmediately() {
        cancelFormatting()
        applyMarkdownFormatting()
    }
    
    /// タイマーをキャンセルする
    func cancelFormatting() {
        formatTimer?.invalidate()
        formatTimer = nil
    }
    
    // MARK: - Private Methods
    
    /// IME（日本語入力）が有効かどうかを判定
    private func isIMEActive() -> Bool {
        guard let textView = textView else { return false }
        return textView.hasMarkedText()
    }
    
    /// IME変換中の範囲を取得
    private func getIMERange() -> NSRange? {
        guard let textView = textView, isIMEActive() else {
            return nil
        }
        return textView.markedRange()
    }
    
    /// Markdown装飾を適用する
    private func applyMarkdownFormatting() {
        guard let textView = textView else { return }
        
        // IME変換中なら何もしない
        if isIMEActive() {
            return
        }
        
        guard let textStorage = textView.textStorage else { return }
        
        // 現在の選択範囲を保存
        let selectedRange = textView.selectedRange()
        
        // ベースフォントを取得
        let baseFont = textView.font ?? NSFont.systemFont(ofSize: 14)
        
        // IME変換中の範囲を除外
        let excludeRange = getIMERange()
        
        // Markdown装飾を適用
        textStorage.beginEditing()
        let mutableAttrString = NSMutableAttributedString(attributedString: textStorage)
        MarkdownFormatter.applyMarkdown(
            to: mutableAttrString,
            baseFont: baseFont,
            excluding: excludeRange
        )
        textStorage.setAttributedString(mutableAttrString)
        textStorage.endEditing()
        
        // 選択範囲を復元（範囲チェック付き）
        restoreSelection(selectedRange, in: textView)
    }
    
    /// 選択範囲を安全に復元する
    private func restoreSelection(_ range: NSRange, in textView: NSTextView) {
        guard let textStorage = textView.textStorage else { return }
        
        let maxLength = textStorage.length
        var safeRange = range
        
        // 範囲が有効かチェックして調整
        if safeRange.location > maxLength {
            safeRange.location = maxLength
            safeRange.length = 0
        } else if safeRange.location + safeRange.length > maxLength {
            safeRange.length = maxLength - safeRange.location
        }
        
        textView.setSelectedRange(safeRange)
    }
    
    // MARK: - Cleanup
    
    deinit {
        cancelFormatting()
    }
}
