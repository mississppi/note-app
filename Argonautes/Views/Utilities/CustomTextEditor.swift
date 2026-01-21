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
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CustomTextEditor
        
        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            parent.text = textView.string
        }
    }
}
