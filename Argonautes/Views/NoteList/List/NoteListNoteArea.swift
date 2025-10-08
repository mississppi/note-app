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
        
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(hex: "EFEFEF"))
        .onAppear{
            viewModel.fetchNotes()
        }
    }
}
