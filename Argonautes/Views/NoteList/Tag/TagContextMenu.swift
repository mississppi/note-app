import SwiftUI

struct TagContextMenu: View {
    let viewModel: NoteListViewModel
    let tag: Tag
    @State private var showDeleteAlert = false

    var body: some View {
        Button(action: {
            viewModel.startEditingSelectedTag()
        }) {
            Text("Edit Tag")
            Image(systemName: "pencil")
        }

        Divider()

        Button(role: .destructive, action: {
            showDeleteAlert = true
        }) {
            Text("Move to Trash")
            Image(systemName: "trash")
        }
        .alert("タグを削除", isPresented: $showDeleteAlert) {
            Button("削除", role: .destructive) {
                print("hoge")
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("「\(tag.name ?? "")」とそのタグに属する全てのノートを削除しますか？")
        }
    }
}