import SwiftUI

struct TrashDetailView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        VStack(spacing: 0){
            
            TrashListView(viewModel: viewModel)
        }
        .onAppear{
            viewModel.fetchNotes(statusFilter: .archived)
        }
    }
}
