import SwiftUI
import CoreData
import Argonautes

struct NoteListNoteArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        List(viewModel.notes, id: \.self, selection: $viewModel.selectedNote) { note in
            NoteRowView(note: note)
                .contextMenu {
                    NoteListArchiveButton(viewModel: viewModel, note: note)
                }
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "cceeac"))
        .onAppear{
            viewModel.fetchNotes()
        }
    }
}
