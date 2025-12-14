import SwiftUI

struct TrashRowView: View {
    let note: Note
    @ObservedObject var viewModel: NoteListViewModel

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(note.title ?? "無題")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                // if let content = note.content, !content.isEmpty {
                //     Text(content)
                //         .font(.system(size: 14))
                //         .foregroundColor(.gray)
                //         .lineLimit(2)
                // }

                if let trashedAt = note.trashedAt {
                    Text("削除日 : \(trashedAt, style: .relative)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        // .contextMenu {
        //     // 復元ボタン
        //     Button(action: {
        //         viewModel.restoreNoteFromArchive(note: note)
        //     }) {
        //         Text("復元")
        //         Image(systemName: "arrow.uturn.left")
        //     }

        //     Divider()

        //     Button(role: .destructive) {
        //         viewModel.deleteNotePermanently(note: note)
        //     } label: {
        //         Text("完全に削除")
        //         Image(systemName: "trash")
        //     }   
        // }
    }
}