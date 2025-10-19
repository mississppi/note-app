import SwiftUI

struct NoteDetailTitleArea: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        HStack {
            NoteDetailTitleView(viewModel: viewModel)
            Spacer()
        }
        .padding()
        .background(Color("F2F2F7"))
    }
}
