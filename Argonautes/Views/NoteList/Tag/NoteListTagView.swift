import SwiftUI

struct NoteListTagView: View {
    @ObservedObject var viewModel: NoteListViewModel

    var body: some View {
        HStack {
            NoteListChevronButton(direction: .left) {
                viewModel.selectPreviousTag()
            }
            Spacer()
            if let  selectedTag = viewModel.selectedTag {
                Text(selectedTag.name ?? "No Tag")
                    .font(.system(size: 15))
            } else {
                Text("No Tag")
                    .font(.system(size: 15))
            }
            
            Spacer()
            NoteListChevronButton(direction: .right) {
                viewModel.selectNextTag()
            }

        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.2))
    }
}
