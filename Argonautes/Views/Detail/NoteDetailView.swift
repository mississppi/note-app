import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        viewModel.detailContentType.view(viewModel: viewModel)
    }
}
