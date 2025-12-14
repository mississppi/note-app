import SwiftUI

struct NoteListArchiveButton: View {
    @ObservedObject var viewModel: NoteListViewModel
    let note: Note

    var body: some View {
        Button(action: {
            viewModel.trashNote(note: note)
        }) {
            Text("ゴミ箱に移動")
            Image(systemName: "trash")
        }
    }
}
