import SwiftUI

struct NoteDetailContentArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        TextEditor(text: $viewModel.selectedContent)
            .font(.body)
            .padding()
    }
}
