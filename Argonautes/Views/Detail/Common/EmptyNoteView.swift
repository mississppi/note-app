import SwiftUI

struct EmptyNoteView: View {
    @ObservedObject var viewModel: NoteListViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("No Note")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)

            // NoteDetailAddNoteButton(viewModel: viewModel)
            // .padding([.top, .trailing], 12),
            // alignment: .topTrailing
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            NoteDetailAddNoteButton(viewModel: viewModel)
                .padding([.top, .trailing], 12),
            alignment: .topTrailing
        )
    }
}