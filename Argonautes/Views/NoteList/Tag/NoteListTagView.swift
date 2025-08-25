import SwiftUI

struct NoteListTagView: View {
    @ObservedObject var viewModel: NoteListViewModel

    var body: some View {
        HStack {
            NoteListChevronButton(direction: .left) {
                // 左矢印アクションのロジック
            }
            Spacer()
            Text("Daily")
                .font(.system(size: 15))
            
            Spacer()
            NoteListChevronButton(direction: .right) {
                // 右矢印アクションのロジック
            }

        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.2))
    }
}
