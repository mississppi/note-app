import SwiftUI

struct TagContextMenuModifier: ViewModifier {
    let viewModel: NoteListViewModel
    let tag: Tag?

    func body(content: Content) -> some View {
        Group {
            if let tag = tag {
                content.contextMenu {
                    TagContextMenu(viewModel: viewModel, tag: tag)
                }
            } else {
                content
            }
        }
    }
}

extension View {
    func tagContextMenu(viewModel: NoteListViewModel, tag: Tag?) -> some View {
        modifier(TagContextMenuModifier(viewModel: viewModel, tag: tag))
    }
}