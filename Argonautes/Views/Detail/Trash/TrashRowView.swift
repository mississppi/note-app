import SwiftUI

struct TrashRowView: View {
    @ObservedObject var viewModel: NoteListViewModel
    let note: Note
    
    var body: some View {
        NoteRowView(note: note)
            .contextMenu {
                Button(action: {
                    print("hoge")
                }) {
                    Label("元に戻す", systemImage: "arrow.uturn.backword")
                }
                
                Button(action: {
                    print("あああ")
                }) {
                    Label("完全に削除", systemImage: "trash.fill")
                }
            }
    }
}
