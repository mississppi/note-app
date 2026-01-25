import SwiftUI

struct TagContextMenuModifier: ViewModifier {
    let viewModel: NoteListViewModel
    let tag: Tag?

    func body(content: Content) -> some View {
        content.contextMenu {
            if let tag = tag {
                TagContextMenu(viewModel: viewModel, tag: tag)
            }
        }
    }
}

extension View {
    func tagContextMenu(viewModel: NoteListViewModel, tag: Tag?) -> some View {
        modifier(TagContextMenuModifier(viewModel: viewModel, tag: tag))
    }
}