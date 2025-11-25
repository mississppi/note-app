import SwiftUI

struct TagAddModalView: View {
    @ObservedObject var viewModel: NoteListViewModel
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("タグを追加")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 8)
            
            // Input
            HStack(spacing: 8) {
                Text("#")
                    .foregroundColor(.gray)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.leading, 8)
                
                TextField("新しいタグ", text: $viewModel.newTagName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
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
            
            Text(viewModel.addTagErrorMessage)
                .font(.caption)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
                .opacity(viewModel.addTagErrorMessage.isEmpty ? 0 : 1)
            
            // Buttons (right aligned)
            HStack {
                Spacer()
                Button("キャンセル") {
                    viewModel.showingAddTagModal = false
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
                
                Button("追加") {
                    viewModel.addNewTag()
                }
                .disabled(viewModel.newTagName.isEmpty)
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.plain)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(viewModel.newTagName.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                .cornerRadius(12)
            }
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
