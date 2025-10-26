import SwiftUI

struct NoteListAddTagButton: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        Button(action: {
            viewModel.showingAddTagModal = true
        }) {
            HStack(spacing: 8){
                Image(systemName: "plus")
                Text("Add Tag")
                Spacer()
            }
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.black)
                .frame(height: 45)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)

        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#EFEFEF")))
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(Color(hex: "cococo"), lineWidth: 1)
//        )
        .sheet(isPresented: $viewModel.showingAddTagModal) {
            TagAddModelView(viewModel: viewModel)
        }
    }
}
