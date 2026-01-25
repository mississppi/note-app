import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        viewModel.detailContentType.view(viewModel: viewModel)
            .background(Color(hex: "#F2F2F7"))
    }
}
