import SwiftUI
import CoreData
import Argonautes

struct NoteListView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            NoteListTagArea(viewModel: viewModel)
        }
        .padding(.horizontal, 24)
        .onAppear {
            viewModel.fetchNotes()
        }
    }
}
