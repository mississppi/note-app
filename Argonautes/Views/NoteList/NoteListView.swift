import SwiftUI
import CoreData
import Argonautes

struct NoteListView: View {
    @ObservedObject var viewModel: NoteListViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            viewModel.listContentType.view(viewModel: viewModel)
            NoteListTrashArea(viewModel: viewModel)
        }
        .padding(.horizontal, 24)
        .background(Color(hex: "#EFEFEF"))
        .onAppear {
            viewModel.fetchData()
        }
    }
}
