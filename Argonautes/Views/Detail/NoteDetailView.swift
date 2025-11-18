import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        Group {
            switch viewModel.detailContentType {
                case .archiveList:
                    ArchiveListView(viewModel: viewModel)

                case .noteDetail:
                    NoteDetailContentView(viewModel: viewModel)

                case .empty:
                    EmptyNoteView()
            }
        }
    }
}
