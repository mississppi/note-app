import SwiftUI

struct TagDeleteConfirmationView: View {
    let tagName: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trash")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("タグを削除")
                .font(.title)
                .fontWeight(.bold)

            Text("「\(tagName)」とそのタグに属する全てのノートをゴミ箱に移動しますか？")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 12) {
                Button("キャンセル") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)

                Button("ゴミ箱に移動") {
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