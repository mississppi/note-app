import SwiftUI
import CoreData
import Argonautes

struct NoteListView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            NoteListTagArea(viewModel: viewModel)
            NoteListSearchArea(viewModel: viewModel)
//                .padding(.bottom, 8)
            Rectangle()
                .fill(Color(hex: "#C0C0C0"))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            NotesListArea(viewModel: viewModel)
            NoteListTrashArea(viewModel: viewModel)
        }
        .padding(.horizontal, 24)
        .background(Color(hex: "#EFEFEF"))
        .onAppear {
//            viewModel.fetchNotes()
            viewModel.fetchData()
        }
    }
}
