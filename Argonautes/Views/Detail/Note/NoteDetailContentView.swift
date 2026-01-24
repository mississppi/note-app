import SwiftUI

struct NoteDetailContentView: View {
    @ObservedObject var viewModel: NoteListViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            NoteDetailTitleArea(viewModel: viewModel)
            NoteDetailContentArea(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("#F2F2F7"))
        .overlay(
            NoteDetailAddNoteButton(viewModel: viewModel)
                .padding([.top, .trailing], 12),
            alignment: .topTrailing
        )
    }
}