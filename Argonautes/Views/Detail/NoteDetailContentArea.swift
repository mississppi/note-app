import SwiftUI

struct NoteDetailContentArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        ScrollView {
            Text(viewModel.selectedNote?.content ?? "")
                .font(.body)    
                .padding()
        }
    }
}
