import SwiftUI

/// ゴミ箱のノート一覧表示View
struct TrashNotesListView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        List(viewModel.trashedNotes, id: \.self, selection: $viewModel.selectedTrashNote) { note in 
            TrashRow(note: note, viewModel: viewModel)
                .tag(note)
                .listRowInsets(EdgeInsets())
                .listRowBackground(
                    viewModel.selectedTrashNote?.objectID == note.objectID
                        ? Color.selectedNoteBackground
                        : Color.listBackground
                )
                .onTapGesture {
                    viewModel.selectedTrashNote = note
                }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.listBackground)
    }
}
