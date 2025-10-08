import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: NoteListViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            NoteDetailTitleArea(viewModel: viewModel)
            NoteDetailContentArea(viewModel: viewModel)
        }
        .background(Color("FFFFFF"))
    }
}
