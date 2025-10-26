import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            NoteDetailTitleArea(viewModel: viewModel)
//            Divider()
            Group {
                if let _ = viewModel.selectedNote {
                    NoteDetailContentArea(viewModel: viewModel)
//                    MarkdownEditorView(viewModel: viewModel)
                } else {
                    Text("No Note")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            NoteDetailAddNoteButton(viewModel: viewModel)
                .padding([.top, .trailing], 12)
            , alignment: .topTrailing
        )
    }
}
