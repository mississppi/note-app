import SwiftUI

struct NoteDetailTitleView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        TextField("タイトル", text: $viewModel.selectedTitle)
            .font(.largeTitle)
            .fontWeight(.bold)
            .textFieldStyle(PlainTextFieldStyle()) // 枠線を外す
            .background(Color.clear)               // 背景色を透明にする
            .foregroundColor(.primary)
            .padding(.vertical, 4)
    }
}
