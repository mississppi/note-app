import SwiftUI


struct NoteDetailAddNoteButton: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        Button(action: {
            viewModel.addNewNote()
        }) {
            Image(systemName: "plus.circle")
                .font(.system(size: 24))
                .frame(width: 29, height: 29)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
