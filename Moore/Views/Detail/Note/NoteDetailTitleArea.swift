import SwiftUI

struct NoteDetailTitleArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        HStack {
            //空タイトルでも常に入力欄を表示
            NoteDetailTitleView(viewModel: viewModel)
                .disabled(viewModel.selectedNote == nil)

            //　ロックボタン
            // Button(action: {
            //     viewModel.toggleLockButtonAction()
            // }) {
            //     Image(systemName: viewModel.lockButtonIcon)
            //         .font(.title2)
            //         .foregroundColor(viewModel.lockButtonColor)
            //         .help(viewModel.lockButtonHelp)
            // }
            // .buttonStyle(PlainButtonStyle())
            // .opacity(viewModel.isLockButtonVisible ? 1 : 0)
            // .disabled(!viewModel.isLockButtonVisible)
            Spacer()
        }
        .padding()
    }
}
