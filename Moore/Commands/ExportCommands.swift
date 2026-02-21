//
//  ExportCommands.swift
//  Moore
//
//  Created on 2026-02-21.
//

import SwiftUI
import AppKit

struct ExportCommands: Commands {
    @FocusedValue(\.noteListViewModel) private var viewModel: NoteListViewModel?
    
    var body: some Commands {
        CommandGroup(after: .importExport) {
            Button("エクスポート") {
                Task { @MainActor in
                    print("[ExportCommands] エクスポートボタンが押されました")
                    
                    guard let viewModel = viewModel else {
                        print("[ExportCommands] ViewModel not available")
                        return
                    }
                    
                    print("[ExportCommands] ViewModel取得成功、ノート数: \(viewModel.notes.count)")
                    
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.prompt = "エクスポート"
                    panel.message = "ノートをエクスポートするフォルダを選択してください"
                    
                    print("[ExportCommands] ダイアログ表示")
                    let result = panel.runModal()
                    print("[ExportCommands] ダイアログ結果: \(result == .OK ? "OK" : "Cancel")")
                    
                    guard result == .OK, let directory = panel.url else {
                        print("[ExportCommands] キャンセルされました")
                        return
                    }
                    
                    print("[ExportCommands] 選択されたフォルダ: \(directory.path)")
                    
                    // Get all non-trashed notes
                    let notesToExport = viewModel.notes.filter { $0.trashedAt == nil }
                    print("[ExportCommands] エクスポート対象: \(notesToExport.count)件")
                    
                    guard !notesToExport.isEmpty else {
                        print("[ExportCommands] エクスポートするノートがありません")
                        return
                    }
                    
                    // Start accessing security-scoped resource
                    guard directory.startAccessingSecurityScopedResource() else {
                        print("[ExportCommands] ❌ セキュリティスコープへのアクセス開始に失敗")
                        return
                    }
                    defer {
                        directory.stopAccessingSecurityScopedResource()
                    }
                    
                    // Export
                    let exportService = MarkdownExportService()
                    do {
                        print("[ExportCommands] エクスポート開始...")
                        try exportService.exportNotes(notesToExport, to: directory)
                        print("[ExportCommands] ✅ \(notesToExport.count)件のノートをエクスポートしました")
                    } catch {
                        print("[ExportCommands] ❌ エクスポート失敗: \(error)")
                        print("[ExportCommands] エラー詳細: \(error.localizedDescription)")
                    }
                }
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
            .disabled(viewModel == nil)
        }
    }
}
