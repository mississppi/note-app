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
        HStack {
            NoteListChevronButton(direction: .left) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    viewModel.selectPreviousTag()
                }
            }
            Spacer()
            
            Group {
                if let  selectedTag = viewModel.selectedTag {
                    Text(selectedTag.name ?? "No Tag")
                        .font(.system(size: 15))
                        .transition(tagTransition)
                        .id(selectedTag.uuid)
                } else {
                    Text("No Tag")
                        .font(.system(size: 15))
                }
            }
            .frame(width: 100, alignment: .center)
            
            Spacer()
            NoteListChevronButton(direction: .right) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    viewModel.selectNextTag()
                }
            }

        }
        .frame(height: 75)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}
