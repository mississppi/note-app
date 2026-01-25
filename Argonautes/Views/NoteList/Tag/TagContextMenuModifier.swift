import SwiftUI

struct TagContextMenuModifier: ViewModifier {
    let viewModel: NoteListViewModel
    let tag: Tag

    func body(content: Content) -> some View {
        content.contextMenu {
            TagContextMenu(viewModel: viewModel, tag: tag)
        }
    }
}

extension View {
    @ViewBuilder
    func tagContextMenu(viewModel: NoteListViewModel, tag: Tag?) -> some View {
        if let tag = tag {
            self.modifier(TagContextMenuModifier(viewModel: viewModel, tag: tag))
        } else {
            self
        }
    }
}