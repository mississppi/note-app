import SwiftUI

struct NoteDetailTitleArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        HStack {
            if let title = viewModel.selectedNote?.title, !title.isEmpty {
                NoteDetailTitleView(viewModel: viewModel)
            }
            Spacer()
        }
        .padding()
        .background(Color("F2F2F7"))
    }
}
