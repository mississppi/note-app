import SwiftUI

struct TagEditModalView: View {
    @Binding var isPresented: Bool
    @Binding var tagName: String
    @ObservedObject var viewModel: NoteListViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("タグ名を編集")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("タグ名")
                    .font(.system(size: 16, weight: .semibold))
                TextField("タグ名を入力", text: $tagName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Text("キャンセル")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)

                Button(action: {

                }) {
                    Text("保存")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(tagName.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(tagName.isEmpty)
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
    }
}