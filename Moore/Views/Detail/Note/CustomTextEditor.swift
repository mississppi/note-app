import SwiftUI
import AppKit

/// キーボードショートカット対応のカスタムテキストエディタ
class CustomNSTextView: NSTextView {
    
    override func keyDown(with event: NSEvent) {
        if handleKeyboardShortcut(event) {
            return
        }
        super.keyDown(with: event)
    }
    
    /// キーボードショートカットを判定・処理
    private func handleKeyboardShortcut(_ event: NSEvent) -> Bool {
        let cmd = event.modifierFlags.contains(.command)
        let shift = event.modifierFlags.contains(.shift)
        let key = event.characters?.lowercased() ?? ""
        
        switch (cmd, shift, key) {
        case (true, false, "c"):
            return handleCopy()
        case (true, false, "t"):
            return handleInsertDateBlock()
        default:
            return false
        }
    }
    
    /// Cmd+C: 選択なしの場合は行コピー
    private func handleCopy() -> Bool {
        if selectedRange().length == 0 {
            copyCurrentLine()
            return true
        }
        return false
    }
    
    /// カーソル行をコピー（改行なし）
    private func copyCurrentLine() {
        let text = string as NSString
        let cursorPosition = selectedRange().location
        
        let lineRange = text.lineRange(for: NSRange(location: cursorPosition, length: 0))
        let lineText = text.substring(with: lineRange)
        
        // 改行文字を除去
        let trimmedText = lineText.trimmingCharacters(in: .newlines)
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(trimmedText, forType: .string)
    }
    
    /// Cmd+T: 日付ブロックを挿入
    private func handleInsertDateBlock() -> Bool {
        let currentText = string
        let endPosition = currentText.count
        
        // 今日の日付を取得
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let todayString = dateFormatter.string(from: Date())
        
        // 挿入するテキスト
        let dateBlock = "\n\n---\n\(todayString)\n"
        
        // 末尾に挿入
        if let textStorage = textStorage {
            textStorage.replaceCharacters(in: NSRange(location: endPosition, length: 0), with: dateBlock)
            
            // カーソルを最後に移動
            setSelectedRange(NSRange(location: currentText.count + dateBlock.count, length: 0))
        }
        
        return true
    }
}

/// カスタムテキストエディタ
struct CustomTextEditor: NSViewRepresentable {
    @Binding var text: String
    var font: NSFont?
    var backgroundColor: NSColor?
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        
        // CustomNSTextViewに差し替え
        let textView = CustomNSTextView()
        textView.autoresizingMask = [.width, .height]
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        
        scrollView.documentView = textView
        
        textView.delegate = context.coordinator
        
        // CoordinatorにMarkdownEngineをセットアップ
        context.coordinator.setupEngine(for: textView)
        
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        
        if let font = font {
            textView.font = font
        }
        
        if let backgroundColor = backgroundColor {
            textView.backgroundColor = backgroundColor
        }
        
        textView.textContainerInset = NSSize(width: 10, height: 10)
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? CustomNSTextView else {
            return
        }
        
        if textView.string != text {
            textView.string = text
            // テキストが変更された時は即座にMarkdown装飾を適用
            context.coordinator.markdownEngine?.applyMarkdownImmediately()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CustomTextEditor
        fileprivate var markdownEngine: MarkdownEngine?
        
        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }
        
        /// MarkdownEngineをセットアップする
        func setupEngine(for textView: NSTextView) {
            markdownEngine = MarkdownEngine(textView: textView)
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            // SwiftUIバインディングを更新
            parent.text = textView.string
            
            // Markdown装飾の適用はEngineに委譲
            markdownEngine?.handleTextChange()
        }
    }
}
