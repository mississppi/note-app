import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = NoteListViewModel(
        noteService: CoreDataNoteService(context: PersistenceController.shared.container.viewContext)
    )
    var body: some View {
        NavigationSplitView {
            NoteListView(viewModel: viewModel)
        } detail: {
            if viewModel.isShowingTrash {
                TrashDetailView(viewModel: viewModel)
            } else {
                NoteDetailView(viewModel: viewModel)
            }
        }
        .modifier(TransparentTitleBarModifier())
    }
}
#Preview {
    ContentView()
}
