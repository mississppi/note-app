import SwiftUI

struct NoteDetailContentArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        if let selectedNote = viewModel.selectedNote {
            TextEditor(text: $viewModel.selectedContent)
                .font(.body)
                .padding()
        } else {
            Text("No Note")
        }
    }
}
