import SwiftUI

struct NoteListTagView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var tagTransition: AnyTransition {
        switch viewModel.tagTransitionDirection {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ).combined(with: .opacity)
        case .backward:
            return .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)
            ).combined(with: .opacity)
        case .none:
            return .identity
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            NoteListChevronButton(direction: .left) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    viewModel.selectPreviousTag()
                }
            }
            
            Spacer()
            
            TagDisplayView(
                tag: viewModel.selectedTag,viewModel: viewModel)
                .frame(width: 100, alignment: .center)
                .transition(tagTransition)
                .id(viewModel.selectedTag?.uuid)
            
            Spacer()
            NoteListChevronButton(direction: .right) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    viewModel.selectNextTag()
                }
            }
        }
        .frame(height: 75)
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $viewModel.isShowingTagEditSheet) {
            TagEditModalView(
                tagName: $viewModel.editTagName,
                viewModel: viewModel
            )
        }
    }
}
