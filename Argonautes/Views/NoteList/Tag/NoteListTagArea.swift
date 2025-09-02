import SwiftUI
import CoreData
import Argonautes

struct NoteListTagArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        VStack() {
            NoteListTagView(viewModel: viewModel)
            NoteListAddTagButton()
        }
        .frame(maxWidth: .infinity)
//        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.1))
    }
}
