import SwiftUI

struct NoteDetailContentArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        TextEditor(text: $viewModel.selectedContent)
            .scrollContentBackground(.hidden)
            .background(Color("#F2F2F7"))
            .font(.custom("HiraginoSans-W3", size: 15))
            .padding()
    }
}
