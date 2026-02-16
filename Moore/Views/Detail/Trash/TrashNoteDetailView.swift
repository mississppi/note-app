import SwiftUI

/// ゴミ箱で選択されたノートの詳細View
struct TrashNoteDetailView: View {
    @ObservedObject var viewModel: NoteListViewModel
    @State private var showingRestoreConfirmation = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 24) {
            // タイトル
            Text(viewModel.selectedTrashNoteTitle)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            // 削除日時
            Text(viewModel.selectedTrashNoteDeletedDateText)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            // プレビュー
            ScrollView {
                Text(viewModel.selectedTrashNoteContent)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(maxHeight: 300)
            .background(Color(NSColor.textBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            
            Spacer()
            
            // ボタンエリア
            VStack(spacing: 12) {
                Button(action: {
                    showingRestoreConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.left")
                        Text("復元する")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("完全に削除")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
        .sheet(isPresented: $showingRestoreConfirmation) {
            TrashRestoreConfirmationModalView(
                noteTitle: viewModel.selectedTrashNoteTitle,
                onConfirm: {
                    if let note = viewModel.selectedTrashNote {
                        viewModel.restoreNoteFromTrash(note: note)
                    }
                    showingRestoreConfirmation = false
                    },
                    onCancel: {
                        showingRestoreConfirmation = false
                    }
                )
            }
            .sheet(isPresented: $showingDeleteConfirmation) {
                TrashDeleteConfirmationModalView(
                    noteTitle: viewModel.selectedTrashNoteTitle,
                    onConfirm: {
                        if let note = viewModel.selectedTrashNote {
                            viewModel.deleteNotePermanently(note: note)
                        }
                        showingDeleteConfirmation = false
                    },
                    onCancel: {
                        showingDeleteConfirmation = false
                    }
                )
            }
    }
}
