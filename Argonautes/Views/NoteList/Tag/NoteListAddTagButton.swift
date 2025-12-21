import SwiftUI

struct NoteListAddTagButton: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        Button {
            viewModel.startAddingTag()
        } label: {
            HStack(spacing: 8){
                Image(systemName: "plus")
                Text("Add Tag")
                Spacer()
            }
            .font(.system(size: 18, weight: .regular))
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 45, alignment: .leading)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "#C0C0C0"), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canAddTag())
        .opacity(viewModel.canAddTag() ? 1.0 : 0.5)
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $viewModel.isShowingAddTagSheet) {
            TagAddModalView(viewModel: viewModel)
        }
    }
}
