import SwiftUI

struct TagAddModalView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    @Environment(\.dismiss) var dismiss
    
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
            
            // Error message (left aligned)
            if let error = viewModel.addTagError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
            }
            
            // Buttons (right aligned)
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
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
                    viewModel.addNewTag()
                    if viewModel.addTagError == nil {
                        dismiss()
                    }
                }){
                    Text("追加")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.newTagName.isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(viewModel.newTagName.isEmpty)
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
