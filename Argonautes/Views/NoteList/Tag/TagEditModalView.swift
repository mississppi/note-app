import SwiftUI

struct TagEditModalView: View {
    @Binding var tagName: String
    @ObservedObject var viewModel: NoteListViewModel
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("タグ名を編集")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("#")
                        .foregroundColor(.gray)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.leading, 8)
                    TextField("タグ名を入力", text: $tagName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 16))
                        .focused($isNameFocused)
                        .onSubmit { viewModel.saveEditedTag()}

                }
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius:10)
                        .fill(Color(hex: "#EFEFEF"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#DDDDDD"), lineWidth: 1)
                )

                Text(viewModel.editTagError?.rawValue ?? "")
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
                    .opacity(viewModel.editTagError == nil ? 0 : 1)
            }

            Spacer()

            HStack {
                Spacer()
                Button("キャンセル") {
                    viewModel.isShowingTagEditSheet = false
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(.plain)
                Button("保存") {
                    viewModel.saveEditedTag()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(tagName.isEmpty)
                .buttonStyle(.plain)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(tagName.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                .cornerRadius(12)
            }
            .font(.system(size: 16, weight: .semibold))
        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .onAppear {
            isNameFocused = true
        }
    }
}