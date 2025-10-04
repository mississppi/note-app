import SwiftUI

struct NoteListArchiveButton: View {
    @ObservedObject var viewModel: NoteListViewModel
    let note: Note

    var body: some View {
        Button(action: {
            viewModel.archiveNote(note: note)
        }) {
            Text("削除")
            Image(systemName: "trash")
        }
    }
}
