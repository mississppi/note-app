import SwiftUI

struct TrashRestoreConfirmationModalView: View {
    let noteTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.uturn.left.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("ノートを復元")
                .font(.title)
                .fontWeight(.bold)

            Text("「\(noteTitle)」をゴミ箱から復元しますか？")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 12) {
                Button("キャンセル") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button("復元") {
                    onConfirm()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(40)
        .frame(width: 400)
    }
}
