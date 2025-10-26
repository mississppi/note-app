import SwiftUI
import CoreData
import Argonautes

struct NoteListView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            NoteListTagArea(viewModel: viewModel)
            NoteListSearchArea(viewModel: viewModel)
            Spacer()
            NoteListNoteArea(viewModel: viewModel)
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
