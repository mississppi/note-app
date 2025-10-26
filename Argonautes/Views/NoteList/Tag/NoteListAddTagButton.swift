import SwiftUI

struct NoteListAddTagButton: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        Button{
            viewModel.showingAddTagModal = true
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
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $viewModel.showingAddTagModal) {
            TagAddModalView(viewModel: viewModel)
        }
    }
}
