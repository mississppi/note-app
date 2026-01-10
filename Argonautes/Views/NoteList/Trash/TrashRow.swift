import SwiftUI

struct TrashRowView: View {
    let note: Note
    @ObservedObject var viewModel: NoteListViewModel
    @State private var showingRestoreConfirmation = false
    @State private var showingDeleteConfirmation = false

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
                    Text("削除日: \(trashedAt, format: .dateTime.year().month().day().hour().minute())")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            Spacer()
            
            // ボタンエリア
            HStack(spacing: 8) {
                // 復元ボタン
                Button(action: {
                    showingRestoreConfirmation = true
                }) {
                    Image(systemName: "arrow.uturn.left")
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .help("復元")

                // 完全削除ボタン
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .help("完全に削除")
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .sheet(isPresented: $showingRestoreConfirmation) {
            TrashRestoreConfirmationModalView(
                noteTitle: note.title ?? "無題",
                onConfirm: {
                    // viewModel.restoreNoteFromTrash(note: note)
                    // showingRestoreConfirmation = false
                },
                onCancel: {
                    showingRestoreConfirmation = false
                }
            )
        }
        .sheet(isPresented: $showingDeleteConfirmation) {
            TrashDeleteConfirmationModalView(
                noteTitle: note.title ?? "無題",
                onConfirm: {
                    viewModel.deleteNotePermanently(note: note)
                    showingDeleteConfirmation = false
                },
                onCancel: {
                    showingDeleteConfirmation = false
                }
            )
        }
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