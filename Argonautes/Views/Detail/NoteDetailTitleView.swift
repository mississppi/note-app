import SwiftUI

struct NoteDetailTitleView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        TextField("タイトル", text: $viewModel.selectedTitle)
            .font(.largeTitle)
            .fontWeight(.bold)
    }
}
