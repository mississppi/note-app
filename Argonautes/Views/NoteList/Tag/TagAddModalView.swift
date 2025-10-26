import SwiftUI

struct TagAddModalView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("タグを追加")
                .font(.system(size: 20, weight: .bold))
            
            HStack {
                Text("#")
                    .foregroundColor(.gray)
                TextField("新しいタグ", text: $viewModel.newTagName)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical,8)
            .background(Color("#808080"))
            .cornerRadius(8)

            
            if let error = viewModel.addTagError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            HStack {
                Spacer()
                Button("キャンセル") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("追加") {
                    viewModel.addNewTag()
                    if viewModel.addTagError == nil {
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(viewModel.newTagName.isEmpty)
            }
        }
        .padding(20)
        .frame(minWidth: 300, minHeight: 200)
    }
}
