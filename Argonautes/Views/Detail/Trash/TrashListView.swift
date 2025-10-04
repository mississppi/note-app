import SwiftUI

struct TrashListView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        List{
            ForEach(viewModel.notes, id: \.self) { note in
                TrashRowView(viewModel: viewModel, note: note)
            }
        }
        .listStyle(.plain)
        .navigationTitle("ゴミ箱")
    }
}
