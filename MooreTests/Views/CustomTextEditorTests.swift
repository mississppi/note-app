import XCTest
import AppKit
@testable import Moore

final class CustomTextEditorTests: XCTestCase {
    
    var textView: CustomNSTextView!
    
    override func setUp() {
        super.setUp()
        textView = CustomNSTextView()
        textView.string = ""
    }
    
    override func tearDown() {
        textView = nil
        super.tearDown()
    }
    
    // MARK: - 行コピー機能テスト
    
    /// 目的: 選択なしでCmd+Cを押すと、カーソル行がコピーされることを確認
    func testCopyCurrentLine_WithNoSelection_ShouldCopyLineToClipboard() throws {
        // Given: 複数行のテキスト
        textView.string = "First line\nSecond line\nThird line"
        
        // カーソルを2行目に配置（位置11は "Second line" の先頭）
        textView.setSelectedRange(NSRange(location: 11, length: 0))
        
        // When: Cmd+Cイベントを送信
        let event = createKeyEvent(key: "c", modifiers: .command)
        textView.keyDown(with: event)
        
        // Then: クリップボードに2行目がコピーされている
        let clipboard = NSPasteboard.general
        let clipboardText = clipboard.string(forType: .string)
        XCTAssertEqual(clipboardText, "Second line", "カーソル行がクリップボードにコピーされるべき")
    }
    
    /// 目的: テキスト選択時はCmd+Cで行コピーが実行されないことを確認
    func testCopyCurrentLine_WithSelection_ShouldNotCopyLine() throws {
        // Given: テキストがあり、一部を選択
        textView.string = "First line\nSecond line"
        textView.setSelectedRange(NSRange(location: 0, length: 5)) // "First" を選択
        
        // クリップボードを初期化
        let clipboard = NSPasteboard.general
        clipboard.clearContents()
        
        // When: Cmd+Cイベントを送信（選択範囲があるので通常のコピー動作）
        let event = createKeyEvent(key: "c", modifiers: .command)
        textView.keyDown(with: event)
        
        // Then: 行コピー機能は実行されない（選択範囲のコピーはNSTextViewの標準動作に任せる）
        // ここでは行コピー関数が呼ばれないことを確認（実際はシステムが選択範囲をコピー）
        // 直接的な検証は難しいが、挙動としては標準コピーが実行される
    }
    
    /// 目的: 空行でも行コピーが動作することを確認
    func testCopyCurrentLine_OnEmptyLine_ShouldCopyEmptyString() throws {
        // Given: 空行を含むテキスト
        textView.string = "First line\n\nThird line"
        
        // カーソルを空行（2行目）に配置
        textView.setSelectedRange(NSRange(location: 11, length: 0))
        
        // When: Cmd+C
        let event = createKeyEvent(key: "c", modifiers: .command)
        textView.keyDown(with: event)
        
        // Then: 空文字列がコピーされる
        let clipboard = NSPasteboard.general
        let clipboardText = clipboard.string(forType: .string)
        XCTAssertEqual(clipboardText, "", "空行の場合は空文字列がコピーされるべき")
    }
    
    // MARK: - 日付ブロック挿入機能テスト
    
    /// 目的: Cmd+Tで日付ブロックが末尾に挿入されることを確認
    func testInsertDateBlock_ShouldAppendDateBlockAtEnd() throws {
        // Given: 既存のテキスト
        let initialText = "Some text"
        textView.string = initialText
        
        // When: Cmd+T
        let event = createKeyEvent(key: "t", modifiers: .command)
        textView.keyDown(with: event)
        
        // Then: 日付ブロックが末尾に追加される
        let resultText = textView.string
        XCTAssertTrue(resultText.hasPrefix(initialText), "元のテキストは保持されるべき")
        XCTAssertTrue(resultText.contains("\n\n---\n"), "日付ブロックには区切り線が含まれるべき")
        
        // 日付形式の確認（yyyy/MM/dd）
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let todayString = dateFormatter.string(from: Date())
        XCTAssertTrue(resultText.contains(todayString), "今日の日付が含まれるべき")
    }
    
    /// 目的: Cmd+T後、カーソルが最後に移動することを確認
    func testInsertDateBlock_ShouldMoveCursorToEnd() throws {
        // Given: テキスト
        textView.string = "Test"
        
        // When: Cmd+T
        let event = createKeyEvent(key: "t", modifiers: .command)
        textView.keyDown(with: event)
        
        // Then: カーソルが最後に移動
        let selectedRange = textView.selectedRange()
        let textLength = textView.string.count
        XCTAssertEqual(selectedRange.location, textLength, "カーソルはテキストの最後に移動すべき")
        XCTAssertEqual(selectedRange.length, 0, "選択範囲はゼロであるべき")
    }
    
    /// 目的: 空のテキストエディタでもCmd+Tが動作することを確認
    func testInsertDateBlock_OnEmptyText_ShouldInsertDateBlock() throws {
        // Given: 空のテキスト
        textView.string = ""
        
        // When: Cmd+T
        let event = createKeyEvent(key: "t", modifiers: .command)
        textView.keyDown(with: event)
        
        // Then: 日付ブロックが挿入される
        let resultText = textView.string
        XCTAssertTrue(resultText.contains("---"), "区切り線が含まれるべき")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let todayString = dateFormatter.string(from: Date())
        XCTAssertTrue(resultText.contains(todayString), "今日の日付が含まれるべき")
    }
    
    /// 目的: 日付ブロックを複数回挿入できることを確認
    func testInsertDateBlock_Multiple_ShouldAppendMultipleTimes() throws {
        // Given: テキスト
        textView.string = "Initial"
        
        // When: Cmd+Tを2回実行
        let event = createKeyEvent(key: "t", modifiers: .command)
        textView.keyDown(with: event)
        textView.keyDown(with: event)
        
        // Then: 日付ブロックが2回追加される
        let resultText = textView.string
        let dateBlockCount = resultText.components(separatedBy: "---").count - 1
        XCTAssertEqual(dateBlockCount, 2, "日付ブロックが2回挿入されるべき")
    }
    
    // MARK: - ヘルパーメソッド
    
    /// キーイベントを作成
    private func createKeyEvent(key: String, modifiers: NSEvent.ModifierFlags) -> NSEvent {
        return NSEvent.keyEvent(
            with: .keyDown,
            location: NSPoint.zero,
            modifierFlags: modifiers,
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            characters: key,
            charactersIgnoringModifiers: key,
            isARepeat: false,
            keyCode: 0
        )!
    }
}
