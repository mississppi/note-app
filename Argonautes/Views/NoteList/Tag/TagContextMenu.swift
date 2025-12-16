import SwiftUI

struct TagContextMenu: View {
    let viewModel: NoteListViewModel
    let tag: Tag

    var body: some View {
        Button(action: {
            viewModel.startEditingSelectedTag()
        }) {
            Text("Edit Tag")
            Image(systemName: "pencil")
        }

        Divider()

        Button(role: .destructive, action: {
            viewModel.startDeletingTag(tag)
        }) {
            Text("Move to Trash")
            Image(systemName: "trash")
        }
    }
}