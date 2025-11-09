import SwiftUI

struct NoteDetailTitleView: View {
    @ObservedObject var viewModel: NoteListViewModel
    @FocusState private var titleFocused: Bool
    
    var body: some View {
        TextField("無題", text: $viewModel.selectedTitle)
            .font(.largeTitle)
            .fontWeight(.bold)
            .textFieldStyle(.plain)
            .focused($titleFocused)
            .padding(.vertical, 4)
            .onChange(of: titleFocused) { _, focused in
                // フォーカスが外れたタイミングで前後の空白を正規化
                if !focused {
                    viewModel.selectedTitle = viewModel.selectedTitle
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
    }
}
