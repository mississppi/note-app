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
                        ? Color(hex: "#E6E6E6")
                        : Color(hex: "#EFEFEF")
                )
                .onTapGesture {
                    viewModel.selectedTrashNote = note
                }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "#EFEFEF"))
    }
}
