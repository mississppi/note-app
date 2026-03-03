import SwiftUI
import AppKit

struct ImportExportCommands: Commands {
    @FocusedValue(\.noteListViewModel) private var viewModel: NoteListViewModel?
    
    var body: some Commands {
        CommandGroup(after: .importExport) {
            Button("インポート") {
                Task { @MainActor in
                    handleImport()
                }
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])
            .disabled(viewModel == nil)
            Button("エクスポート") {
                Task { @MainActor in
                    handleExport()
                }
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
            .disabled(viewModel == nil)
        }
    }

    private func handleImport() {
        Logger.info("[ImportExportCommands] インポートボタンが押されました")
        guard let viewModel = viewModel else {
            Logger.error("[ImportExportCommands] ViewModel not available")
            return
        }
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "インポート"
        panel.message = "Mooreエクスポートフォルダを選択してください"
        let result = panel.runModal()
        guard isPanelSelectionValid(result: result, panel: panel) else {
            Logger.info("[ImportExportCommands] キャンセルされました")
            return
        }
        let directory = panel.url!
        Logger.info("[ImportExportCommands] インポート対象フォルダ: \(directory.path)")
        // viewModel.importNotes(from: directory)
    }

    private func handleExport() {
        Logger.info("[ImportExportCommands] エクスポートボタンが押されました")
        guard let viewModel = viewModel else {
            Logger.error("[ImportExportCommands] ViewModel not available")
            return
        }
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "エクスポート"
        panel.message = "ノートをエクスポートするフォルダを選択してください"
        let result = panel.runModal()
        guard isPanelSelectionValid(result: result, panel: panel) else {
            Logger.info("[ImportExportCommands] キャンセルされました")
            return
        }
        let directory = panel.url!
        Logger.info("[ImportExportCommands] 選択されたフォルダ: \(directory.path)")
        
        // エクスポート実行
        let notesToExport = viewModel.notes.filter { !$0.isTrashed }
        viewModel.exportNotes(notesToExport, to: directory)
        
        // 完了通知
        showExportCompletionAlert(noteCount: notesToExport.count, directory: directory)
    }
    
    /// エクスポート完了アラート表示
    private func showExportCompletionAlert(noteCount: Int, directory: URL) {
        let alert = NSAlert()
        alert.messageText = "エクスポート完了"
        alert.informativeText = "\(noteCount)件のノートをエクスポートしました\n\n保存先:\n\(directory.path)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    /// パネル選択判定（インポート・エクスポート共通）
    private func isPanelSelectionValid(result: NSApplication.ModalResponse, panel: NSOpenPanel) -> Bool {
        return result == .OK && panel.url != nil
    }
}
