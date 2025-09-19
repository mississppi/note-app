import SwiftUI

struct NoteDetailTitleView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        Text(viewModel.selectedNote?.title ?? "")
            .font(.largeTitle)
            .fontWeight(.bold)
    }
}
