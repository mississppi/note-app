import SwiftUI

struct NoteDetailTitleArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        HStack {
            //空タイトルでも常に入力欄を表示
            NoteDetailTitleView(viewModel: viewModel)
                .disabled(viewModel.selectedNote == nil)
            Spacer()
        }
        .padding()
        .background(Color("#F2F2F7"))
    }
}
