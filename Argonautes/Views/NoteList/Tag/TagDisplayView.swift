import SwiftUI

struct TagDisplayView: View {
    let tag: Tag?
    let viewModel: NoteListViewModel

    var body: some View {
        Text(displayName)
            .font(.system(size: 15))
            .tagContextMenu(viewModel: viewModel, tag: tag)
    }

    private var displayName: String {
        tag?.name ?? "No Tag"
    }
}