//
//  ImportExportCommands.swift
//  Moore
//
//  Created on 2026-02-22.
//

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
        guard result == .OK, let directory = panel.url else {
            Logger.info("[ImportExportCommands] キャンセルされました")
            return
        }
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
        guard result == .OK, let directory = panel.url else {
            Logger.info("[ImportExportCommands] キャンセルされました")
            return
        }
        Logger.info("[ImportExportCommands] 選択されたフォルダ: \(directory.path)")
        viewModel.exportNotes(to: directory)
    }
}
