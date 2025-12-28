import SwiftUI

struct TrashDeleteConfirmationModalView: View {
    let noteTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trash.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("ノートを完全に削除")
                .font(.title)
                .fontWeight(.bold)

            Text("「\(noteTitle)」を完全に削除しますか？\nこの操作は取り消せません。")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 12) {
                Button("キャンセル") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button("完全に削除") {
                    onConfirm()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(40)
        .frame(width: 400)
    }
}
