import AppKit

final class KeyboardShortcutManager {
    static let shared = KeyboardShortcutManager()
    
    private init() {}
    
    func setupShortcuts(with viewModel: NoteListViewModel) {
        let saveNoteShortcut = NSMenuItem(title: "", action: #selector(saveNoteShortcut(_:)), keyEquivalent: "s")
        saveNoteShortcut.keyEquivalentModifierMask = [.command]
        
        if let fileMenu = NSApp.mainMenu?.item(withTitle: "File")?.submenu {
            fileMenu.addItem(saveNoteShortcut)
        }
    }
    
    @objc private func saveNoteShortcut(_ sender: Any?) {
        print("start new note!")
    }
}
